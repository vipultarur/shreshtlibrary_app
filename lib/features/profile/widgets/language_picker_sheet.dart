import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';
import 'package:shreshtlibrary/core/services/locale_provider.dart';

class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.profile_select_language,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildLanguageOption(
              context,
              ref,
              label: 'English',
              code: 'en',
              isActive: activeLocale.languageCode == 'en',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context,
              ref,
              label: 'हिन्दी',
              code: 'hi',
              isActive: activeLocale.languageCode == 'hi',
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context,
              ref,
              label: 'ગુજરાતી',
              code: 'gu',
              isActive: activeLocale.languageCode == 'gu',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String code,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.dividerColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle, color: theme.colorScheme.primary)
            else
              const SizedBox(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
