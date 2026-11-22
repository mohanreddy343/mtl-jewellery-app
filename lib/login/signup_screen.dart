import 'package:flutter/material.dart';

import '../services/register_api_service.dart';
import 'otp_screen.dart';

/// Create-account page for email users. After the form is valid we "send" an
/// OTP to the email and open the shared OTP screen to verify it.
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
class SignupScreen extends StatefulWidget {
  final bool returnResult;
  const SignupScreen({super.key, this.returnResult = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _pink = Color(0xFFFF0080);

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final result = await RegisterApi.register(
        name: _name.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _loading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Sign up with your email and a password.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _name,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 15),
                  decoration: _dec('Full name'),
                  validator: (v) =>
                  (v ?? '').trim().length < 2 ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),

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
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 15),
                  decoration: _dec('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: Colors.black45),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    final t = v ?? '';
                    if (t.isEmpty) return 'Enter a password';
                    if (t.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _confirm,
                  enabled: !_loading,
                  obscureText: _obscure2,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  style: const TextStyle(fontSize: 15),
                  decoration: _dec('Confirm password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure2 ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: Colors.black45),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) =>
                  v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      disabledBackgroundColor: _pink.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                        : const Text('Sign Up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Login',
                          style: TextStyle(
                              color: _pink, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
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