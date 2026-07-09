import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String _selectedLangCode = 'en';

  @override
  void initState() {
    super.initState();
    // Pre-select active locale if already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeLocale = ref.read(localeProvider);
      setState(() {
        _selectedLangCode = activeLocale.languageCode;
      });
    });
  }

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLangCode = code;
    });
    // Immediately update active locale in the provider
    ref.read(localeProvider.notifier).setLocale(code);
  }

  void _onContinuePressed() {
    // If the student never tapped a language card, _selectedLangCode is still
    // its default value ('en'), so this guarantees a locale is always applied
    // before moving on.
    ref.read(localeProvider.notifier).setLocale(_selectedLangCode);
    // Proceed to home (router will handle authentication check and redirect to login if needed)
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // We display dual language titles/subtitles on this screen to ensure it is clear to all speakers before selection.
    final title = l10n?.lang_select_title ?? "Choose Language / भाषा चुनें";
    final subtitle = l10n?.lang_select_subtitle ?? "Select your preferred language to continue / आगे बढ़ने के लिए अपनी पसंदीदा भाषा चुनें";
    final btnText = l10n?.btn_continue ?? "Continue";

    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 24,
              left: 30,
              right: 30,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildLanguageCard(
                              label: 'English',
                              nativeLabel: 'English',
                              code: 'en',
                              flag: '🇺🇸',
                            ),
                            const SizedBox(height: 16),
                            _buildLanguageCard(
                              label: 'Hindi',
                              nativeLabel: 'हिन्दी',
                              code: 'hi',
                              flag: '🇮🇳',
                            ),
                            const SizedBox(height: 16),
                            _buildLanguageCard(
                              label: 'Gujarati',
                              nativeLabel: 'ગુજરાતી',
                              code: 'gu',
                              flag: '🇮🇳',
                            ),
                          ],
                        ),
                      ),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onContinuePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            btnText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required String label,
    required String nativeLabel,
    required String code,
    required String flag,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedLangCode == code;
    return InkWell(
      onTap: () => _onLanguageSelected(code),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag/Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 16),
            // Text Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? theme.textTheme.bodyLarge?.color : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white54 : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            // Selected Check Indicator
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}