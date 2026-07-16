import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';

final idCardProvider = StreamProvider.autoDispose<StudentIdCard?>((ref) {
  return ref.watch(studentApiProvider).idCardStream();
});

class DigitalIdCardWidget extends ConsumerWidget {
  const DigitalIdCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idCardAsync = ref.watch(idCardProvider);
    final dash = ref.watch(dashboardProvider).value;
    final isExpired = dash?.membershipStatus == 'EXPIRED';

    if (isExpired) {
      return const PremiumBuyContainer();
    }

    return idCardAsync.when(
      data: (idCard) {
        if (idCard == null) return const Center(child: Text('idCard is null!'));
        return _buildCard(context, idCard, dash);
      },
      loading: () => const Center(child: Text('Loading ID Card...')),
      error: (err, stack) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to load ID Card. Please check your connection.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    StudentIdCard idCard,
    StudentDashboard? dash,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section: Image + Name Pill
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : const Color(0xFFFDE4E4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      (idCard.photoUrl != null && idCard.photoUrl!.isNotEmpty)
                      ? Image.network(
                          idCard.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network(
                                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(idCard.fullName)}&background=random&size=200',
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.network(
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(idCard.fullName)}&background=random&size=200',
                          fit: BoxFit.cover,
                        ),
                ),
                // Name Pill overlapping the bottom
                Positioned(
                  bottom: -16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHigh
                          : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      idCard.fullName.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bottom section: Info and QR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Info Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoRow(
                            context,
                            'ID Number',
                            idCard.studentId.toString(),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(context, 'Goal', idCard.goal),
                          const SizedBox(height: 12),
                          _buildInfoRow(context, 'Mobile', idCard.mobile),

                          if (dash != null &&
                              !dash.restrictedFeatures.contains('study')) ...[
                            const SizedBox(height: 12),
                            _buildSeatInfo(context, dash),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right QR Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: idCard.qrData,
                              version: QrVersions.auto,
                              size: 100.0,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            idCard.studentId.toString(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark
                                  ? theme.colorScheme.onSurfaceVariant
                                  : Colors.black87,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? theme.colorScheme.onSurface : Colors.black87,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSeatInfo(BuildContext context, StudentDashboard dash) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasSeat = dash.assignedSeat.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seat',
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hasSeat
              ? (dash.assignedSeatFloor.isNotEmpty
                    ? '${dash.assignedSeat} (${dash.assignedSeatFloor})'
                    : dash.assignedSeat)
              : 'Unassigned',
          style: theme.textTheme.bodySmall?.copyWith(
            color: hasSeat
                ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                : (isDark ? Colors.orange.shade300 : Colors.orange.shade700),
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 480,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
