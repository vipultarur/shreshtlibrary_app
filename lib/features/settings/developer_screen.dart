import 'package:flutter/material.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PageScaffold(
      title: l10n.dev_info_title,
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      child: Center(
                        child: Text(
                          'VT',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Name & Role
                Text(
                  'Vipul Tarur',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Founder, Tarur Infotech',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Tagline
                Text(
                  '"Building applications that make people\'s lives easier."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),
                
                // CTA
                Text(
                  'Want to build an app or website?\nConnect with us below!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      context: context,
                      icon: Icons.email_rounded,
                      label: 'Email',
                      color: Colors.redAccent,
                      onTap: () => _launchUrl('mailto:tarurinfotech@gmail.com'),
                    ),
                    _buildSocialButton(
                      context: context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Instagram',
                      color: Colors.purpleAccent.shade400,
                      onTap: () => _launchUrl('https://instagram.com/vipultarur'),
                    ),
                    _buildSocialButton(
                      context: context,
                      icon: Icons.work_rounded,
                      label: 'LinkedIn',
                      color: Colors.blue.shade700,
                      onTap: () => _launchUrl('https://www.linkedin.com/in/vipul-tarur-155a7824b/'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Icon(icon, color: isDark ? color.withValues(alpha: 0.9) : color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
