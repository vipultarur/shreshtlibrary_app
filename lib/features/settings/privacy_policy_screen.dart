import 'package:flutter/material.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PageScaffold(
      title: l10n.settings_privacy_policy,
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            l10n.privacy_policy_intro,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16),
        _buildPolicySection(
          context,
          title: l10n.privacy_data_collection,
          description: l10n.privacy_data_collection_desc,
        ),
        _buildPolicySection(
          context,
          title: l10n.privacy_data_usage,
          description: l10n.privacy_data_usage_desc,
        ),
        _buildPolicySection(
          context,
          title: l10n.privacy_data_security,
          description: l10n.privacy_data_security_desc,
        ),
        _buildPolicySection(
          context,
          title: l10n.privacy_contact,
          description: l10n.privacy_contact_desc,
          isLast: true,
        ),
        const SizedBox(height: 24),
      ],
      ),
    );
  }

  Widget _buildPolicySection(BuildContext context, {required String title, required String description, bool isLast = false}) {
    return Card(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: isLast ? 0 : 16),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
