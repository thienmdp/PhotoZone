import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.config.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/avatar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;

  // Add user info map
  Map<String, String>? userInfo = {
    'avatarId': 'avatar7',
    'fullName': 'NeihT Dev',
    'email': 'thienmai1312@gmail.com',
  };

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _toggleBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!_isBiometricEnabled) {
        final List<BiometricType> availableBiometrics =
            await _localAuth.getAvailableBiometrics();

        if (availableBiometrics.isEmpty) {
          if (!mounted) return;
          _showError('Device does not support biometric authentication');
          return;
        }

        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable biometric login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (didAuthenticate) {
          await prefs.setBool('biometric_enabled', true);
          if (!mounted) return;
          setState(() => _isBiometricEnabled = true);
        }
      } else {
        await prefs.setBool('biometric_enabled', false);
        setState(() => _isBiometricEnabled = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Could not authenticate: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Account Settings',
                  items: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'Update your information',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Security',
                      subtitle: 'Password and authentication',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: themeProvider.isDarkMode ? 'On' : 'Off',
                      showArrow: false,
                      onTap: () => themeProvider.toggleTheme(),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeColor: AppTheme.primary,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.fingerprint,
                      title: 'Biometric Login',
                      subtitle: _isBiometricEnabled ? 'On' : 'Off',
                      showArrow: false,
                      onTap: _toggleBiometric,
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: _isBiometricEnabled,
                          onChanged: (_) => _toggleBiometric(),
                          activeColor: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'More',
                  items: [
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.logout,
                      iconColor: AppTheme.error,
                      title: 'Logout',
                      showArrow: false,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Avatar(
              avatarId: userInfo?['avatarId'],
              size: 60,
              isOnline: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo?['fullName'] ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  userInfo?['email'] ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : AppTheme.borderColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showArrow = true,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary.withOpacity(0.6),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // TODO: Add logout logic
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
