import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shreshtlibrary/core/models/models.dart';

class RestrictedFeatureScreen extends StatelessWidget {
  const RestrictedFeatureScreen({
    super.key,
    required this.dashboard,
    required this.feature,
  });

  final StudentDashboard dashboard;
  final String feature;

  @override
  Widget build(BuildContext context) {
    final status = dashboard.membershipStatus;
    final isPending = status == 'PENDING';
    final isSuspended = status == 'SUSPENDED';
    
    final title = dashboard.expiryDialogTitle ?? 'Feature Restricted';
    final message = dashboard.expiryDialogMessage ?? 'You do not have access to this feature.';

    final theme = Theme.of(context);
    
    IconData icon;
    Color color;
    
    if (isPending) {
      icon = Icons.hourglass_top_rounded;
      color = Colors.orange.shade600;
    } else if (isSuspended) {
      icon = Icons.gavel_rounded;
      color = Colors.red.shade800;
    } else {
      icon = Icons.warning_rounded;
      color = theme.colorScheme.error;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFFC),
      appBar: AppBar(
        title: const Text('Access Denied', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: color),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              _buildBenefitsCard(context),
              const SizedBox(height: 32),
              if (!isPending && !isSuspended && !dashboard.restrictedFeatures.contains('payments'))
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context.go('/payments');
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text(
                      'Renew Plan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context) {
    String title = 'Feature Benefits';
    List<String> benefits = [];

    switch (feature) {
      case 'attendance':
        title = 'Attendance Tracker';
        benefits = [
          'Track your daily check-ins and check-outs',
          'Maintain your attendance streak',
          'View your historical attendance records'
        ];
        break;
      case 'study':
        title = 'Study Area & Leaderboard';
        benefits = [
          'Use the smart study timer to focus',
          'Track your deep work sessions',
          'Compete with peers on the leaderboard'
        ];
        break;
      case 'payments':
        title = 'Memberships';
        benefits = [
          'Purchase premium membership plans',
          'Renew your current subscription',
          'View your past payment history'
        ];
        break;
      case 'notifications':
        title = 'Announcements';
        benefits = [
          'Receive real-time library updates',
          'Get important announcements instantly',
          'Stay informed about upcoming events'
        ];
        break;
      case 'library_info':
        title = 'Library Info';
        benefits = [
          'Access library rules and guidelines',
          'View available facilities and services',
          'See contact details and timings'
        ];
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Unlock $title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(b, style: const TextStyle(color: Colors.black54))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

void showRestrictionDialog(BuildContext context, StudentDashboard dashboard) {
  final status = dashboard.membershipStatus;
  final isPending = status == 'PENDING';
  final isSuspended = status == 'SUSPENDED';
  
  final title = dashboard.expiryDialogTitle ?? 'Feature Restricted';
  final message = dashboard.expiryDialogMessage ?? 'You do not have access to this feature.';

  final theme = Theme.of(context);
  
  IconData icon;
  Color color;
  
  if (isPending) {
    icon = Icons.hourglass_top_rounded;
    color = Colors.orange.shade600;
  } else if (isSuspended) {
    icon = Icons.gavel_rounded;
    color = Colors.red.shade800;
  } else {
    icon = Icons.warning_rounded;
    color = theme.colorScheme.error;
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              color: color,
              child: Center(
                child: Icon(icon, size: 56, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (!isPending && !isSuspended) {
                          if (!dashboard.restrictedFeatures.contains('payments')) {
                            context.push('/payments');
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        (!isPending && !isSuspended) ? 'Renew Plan' : 'OK, Got it',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
