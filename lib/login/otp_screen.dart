import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/otp_api_service.dart';

/// Why we are asking for an OTP.
enum OtpPurpose { mobileLogin, emailSignup }

/// Saves the logged-in session locally. Used by login + OTP screens.
Future<void> saveSession(String userId, {String? name}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    await prefs.setString('user_id', userId);
    if (name != null && name.isNotEmpty) {
      await prefs.setString('user_name', name);
    }
  } catch (_) {}
}

/// Separate OTP page, used for:
///  - Mobile login  (target = phone number, e.g. "+965 55512345")
///  - Email signup  (target = email address)
class OtpScreen extends StatefulWidget {
  final OtpPurpose purpose;

  /// Phone ("+965 5xxxxxxx") or email the OTP was sent to.
  final String target;

  /// Only for signup – name entered on the signup form.
  final String? name;

  const OtpScreen({
    super.key,
    required this.purpose,
    required this.target,
    this.name,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _pink = Color(0xFFFF0080);
  static const _length = 6;
  static const _resendSeconds = 30;

  final _otp = TextEditingController();
  final _focus = FocusNode();

  Timer? _timer;
  int _seconds = _resendSeconds;
  bool _loading = false;
  String? _error;

  bool get _isEmail => widget.purpose == OtpPurpose.emailSignup;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _otp.addListener(() {
      if (_error != null && _otp.text.isNotEmpty) _error = null;
      setState(() {});
      if (_otp.text.length == _length) _verify();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => _seconds = _seconds > 0 ? _seconds - 1 : 0);
    });
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _verify() async {
    if (_loading) return;
    if (_otp.text.length != _length) {
      setState(() => _error = 'Enter the 6-digit OTP');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    // Email signup is not connected to the backend yet, so it keeps the demo flow.
    if (_isEmail) {
      await Future.delayed(const Duration(milliseconds: 700));
      await saveSession(widget.target, name: widget.name);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      return;
    }

    // Mobile login: verify the OTP with the backend
    try {
      final result = await OtpApi.verify(widget.target, _otp.text);
      await OtpApi.saveToken(result.token);
      await saveSession(result.userId, name: result.name);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on OtpApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
      _otp.clear();
      _focus.requestFocus();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0 || _loading) return;
    try {
      await OtpApi.resend(widget.target);
    } on OtpApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (!mounted) return;
    _otp.clear();
    _startTimer();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('OTP resent')));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _pink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isEmail ? Icons.mark_email_read_outlined : Icons.sms_outlined,
                  color: _pink,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Verify OTP',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                  children: [
                    TextSpan(
                        text: _isEmail
                            ? 'We sent a 6-digit code to your email\n'
                            : 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: widget.target,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _otpBoxes(),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
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
                      : Text(_isEmail ? 'Verify & Create Account' : 'Verify & Login',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: _seconds > 0
                    ? Text(
                  'Resend OTP in 0:${_seconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600),
                )
                    : TextButton(
                  onPressed: _loading ? null : _resend,
                  child: const Text('Resend OTP',
                      style: TextStyle(
                          color: _pink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: Text(
                    _isEmail ? 'Change email' : 'Change number',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 6 boxes driven by one hidden TextField (supports paste + SMS autofill) ─
  Widget _otpBoxes() {
    final text = _otp.text;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(_focus),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_length, (i) {
              final filled = i < text.length;
              final active = i == text.length && _focus.hasFocus;
              return Container(
                width: 48,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled ? _pink.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _error != null
                        ? Colors.red.shade400
                        : (active || filled)
                        ? _pink
                        : Colors.grey.shade300,
                    width: active ? 1.8 : 1.2,
                  ),
                ),
                child: Text(
                  filled ? text[i] : '',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
              );
            }),
          ),
          // Invisible field that actually receives the input.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _otp,
                focusNode: _focus,
                autofocus: true,
                enabled: !_loading,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                enableInteractiveSelection: false,
                showCursor: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_length),
                ],
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}