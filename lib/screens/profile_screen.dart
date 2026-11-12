import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/login_sscreen.dart';
import '../saved_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _accent = Color(0xFFFFA000); // orange used in the design
  static const Color _titleColor = Color(0xFF2B3138);
  static const Color _subtitleColor = Color(0xFF757575);

  bool _loggedIn = false;
  String _userId = '';
  int _addressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _loggedIn = prefs.getBool('logged_in') ?? false;
      _userId = prefs.getString('user_id') ?? '';
      _addressCount = prefs.getStringList(kSavedAddressesKey)?.length ?? 0;
    });
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (yes != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in');
    await prefs.remove('user_id');

    if (!mounted) return;
    _goToLogin();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_loggedIn && _userId.isNotEmpty)
              Text(
                _userId,
                style: const TextStyle(
                  color: _subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _loggedIn ? 'Logout' : 'Login',
            onPressed: _loggedIn ? _confirmLogout : _goToLogin,
            icon: Icon(
              _loggedIn ? Icons.logout : Icons.login,
              color: _loggedIn ? const Color(0xFFE02020) : _accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ---- Fixed header: Orders | Wishlist | Support ----
          _buildTopActions(context),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

          // ---- Scrollable content ----
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _sectionTitle('YOUR INFORMATION'),
                _tile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  subtitle: _addressCount == 0
                      ? 'No Addresses'
                      : '$_addressCount saved',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedAddressesScreen(),
                      ),
                    );
                    _loadUser(); // refresh the count when coming back
                  },
                ),
                _tile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {},
                  showDivider: false,
                ),
                const SizedBox(height: 20),
                _sectionTitle('OTHER INFORMATION'),
                _tile(
                  icon: Icons.favorite_border,
                  title: 'Your Wishlist',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet Balance',
                  subtitle: '₹0 available',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.card_giftcard_outlined,
                  title: 'Rewards',
                  subtitle: 'Tap to check points',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {},
                ),
                _tile(
                  icon: Icons.lock_outline,
                  title: 'Privacy Policy',
                  onTap: () {},
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Orders / Wishlist / Support in one horizontal line
  Widget _buildTopActions(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _topAction(Icons.shopping_bag_outlined, 'Orders', () {}),
            _verticalDivider(),
            _topAction(Icons.favorite_border, 'Wishlist', () {}),
            _verticalDivider(),
            _topAction(Icons.chat_bubble_outline, 'Support', () {}),
          ],
        ),
      ),
    );
  }

  Widget _topAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _accent, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: _accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() =>
      VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade200);

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _subtitleColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: _accent, size: 24),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          color: _titleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _subtitleColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 60,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}