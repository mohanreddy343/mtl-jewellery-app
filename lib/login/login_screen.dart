import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_api.dart';
import '../services/login_sent_otp_service.dart';
import '../services/register_api_service.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

/// Login page with Mobile (OTP on a separate page) and Email (password) tabs,
/// a "Sign Up" link for new email users, and Skip.
///
/// NOTE: there is no backend yet. Replace the TODOs with your real API calls.
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
class LoginScreen extends StatefulWidget {
  /// true when opened from the cart: close with a result after login
  /// instead of going to the home screen.
  final bool returnResult;
  const LoginScreen({super.key, this.returnResult = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _pink = Color(0xFFFF0080);

  bool _isMobile = true;
  bool _obscure = true;
  bool _loading = false;

  final _mobileKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormState>();

  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  // void _skip() {
  //   // Guest mode: nothing is saved, so the login page shows again next launch.
  //   Navigator.pushReplacementNamed(context, '/home');
  // }
  void _skip() {
    if (widget.returnResult) {
      Navigator.pop(context, false); // back to the cart as a guest
      return;
    }
    // Guest mode: nothing is saved, so the login page shows again next launch.
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _sendOtp() async {
    if (!_mobileKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    // No spaces: the backend rejects them, and the OTP screen needs this same string
    final mobile = '+965${_phone.text.trim()}';

    try {
      await AuthApi.sendOtp(mobile);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => OtpScreen(
  //         purpose: OtpPurpose.mobileLogin,
  //         target: mobile,
  //       ),
  //     ),
  //   );
  // }
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          purpose: OtpPurpose.mobileLogin,
          target: mobile,
          returnResult: widget.returnResult,
        ),
      ),
    );
    if (ok == true && widget.returnResult && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _submitEmail() async {
    if (!_emailKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final result = await RegisterApi.login(
        email: _email.text.trim(),
        password: _password.text,
      );

      await RegisterApi.saveToken(result.token);
      await saveSession(result.userId,
          name: result.name, contact: result.email);


      if (!mounted) return;
      if (widget.returnResult) {
        Navigator.pop(context, true);
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on RegisterApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openSignup() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(returnResult: widget.returnResult),
      ),
    );
    if (ok == true && widget.returnResult && mounted) {
      Navigator.pop(context, true);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                child: TextButton(
                  onPressed: _loading ? null : _skip,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Skip',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right,
                          size: 20, color: Colors.black87),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                          color: _pink, shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 20),
                    const Text('Welcome!',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Log in to track orders and checkout faster.',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 24),

                    _modeToggle(),
                    const SizedBox(height: 20),

                    _isMobile ? _mobileForm() : _emailForm(),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'By continuing you agree to our Terms of Use\nand Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile / Email toggle ──────────────────────────────────────────────────
  Widget _modeToggle() {
    Widget tab(String label, IconData icon, bool mobile) {
      final selected = _isMobile == mobile;
      return Expanded(
        child: GestureDetector(
          onTap: _loading ? null : () => setState(() => _isMobile = mobile),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18, color: selected ? _pink : Colors.black54),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? _pink : Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          tab('Mobile', Icons.phone_android, true),
          tab('Email', Icons.mail_outline, false),
        ],
      ),
    );
  }

  // ── Mobile form (OTP is on a separate page) ────────────────────────────────
  Widget _mobileForm() {
    return Form(
      key: _mobileKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _phone,
            enabled: !_loading,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendOtp(),
            style: const TextStyle(fontSize: 15),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: _dec(
              'Mobile number',
              prefix: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text('+965',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
              ),
            ),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Enter your mobile number';
              if (t.length != 8) return 'Enter 8 digits';
              if (!RegExp(r'^[2569]').hasMatch(t)) {
                return 'Kuwait numbers start with 2, 5, 6 or 9';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _primaryButton('Send OTP', _sendOtp),
        ],
      ),
    );
  }

  // ── Email form ─────────────────────────────────────────────────────────────
  Widget _emailForm() {
    return Form(
      key: _emailKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _email,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            style: const TextStyle(fontSize: 15),
            decoration: _dec('Email address'),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Enter your email';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            enabled: !_loading,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 15),
            onFieldSubmitted: (_) => _submitEmail(),
            decoration: _dec('Password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20, color: Colors.black45),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              final t = v ?? '';
              if (t.isEmpty) return 'Enter your password';
              if (t.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _primaryButton('Login', _submitEmail),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?",
                  style: TextStyle(color: Colors.grey.shade600)),
              TextButton(
                onPressed: _loading ? null : _openSignup,
                child: const Text('Sign Up',
                    style:
                    TextStyle(color: _pink, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _pink,
          disabledBackgroundColor: _pink.withOpacity(0.6),
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _dec(String label, {Widget? prefix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      prefix: prefix,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      enabledBorder: border(Colors.grey.shade300),
      focusedBorder: border(_pink, 1.5),
      errorBorder: border(Colors.red.shade400),
      focusedErrorBorder: border(Colors.red.shade400, 1.5),
      disabledBorder: border(Colors.grey.shade200),
    );
  }
}