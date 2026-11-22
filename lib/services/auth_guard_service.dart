import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Adjust this path to where your login screen lives
import '../login/login_screen.dart';
/// Use this before any action that needs an account (for example Proceed
/// in the cart):
///
///   if (!await AuthGuard.ensureLoggedIn(context)) return;
class AuthGuard {
  AuthGuard._();

  /// True when a login token is saved on this device.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  /// Returns true if the user is logged in, or becomes logged in through the
  /// login screen. Returns false if the user cancels.
  static Future<bool> ensureLoggedIn(BuildContext context) async {
    if (await isLoggedIn()) return true;
    if (!context.mounted) return false;

    final goLogin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login required'),
        content: const Text('Please log in to place your order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Login'),
          ),
        ],
      ),
    );
    if (goLogin != true || !context.mounted) return false;

    // The login screen is pushed ON TOP of the cart, so the cart stays as it is.
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(returnResult: true)),
    );
    return result == true && await isLoggedIn();
  }
}