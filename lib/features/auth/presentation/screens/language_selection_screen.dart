import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/locale_provider.dart';
import '../widgets/auth_layout.dart';

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

    // We display dual language titles/subtitles on this screen to ensure it is clear to all speakers before selection.
    final title = l10n?.lang_select_title ?? "Choose Language\nभाषा चुनें";
    final subtitle = l10n?.lang_select_subtitle ?? "Select your preferred language to continue\nआगे बढ़ने के लिए अपनी पसंदीदा भाषा चुनें";
    final btnText = l10n?.btn_continue ?? "Continue";

    return AuthLayout(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _onContinuePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              btnText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : (isDark ? theme.dividerColor : Colors.grey.shade300),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Flag/Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? theme.dividerColor : Colors.grey.shade200,
                ),
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
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
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
                child: Icon(
                  Icons.check,
                  color: theme.colorScheme.onPrimary,
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
                    color: isDark ? theme.dividerColor : Colors.grey.shade300,
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