import 'package:flutter/material.dart';
import 'package:shreshtlibrary/common/widgets/widgets.dart';
import 'package:shreshtlibrary/common/widgets/status_badge.dart';
import 'package:shreshtlibrary/core/l10n/app_localizations.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PageScaffold(
      title: l10n.settings_instructions,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _buildHeaderBanner(context, isDark, l10n),
            const SizedBox(height: 16),
            
            _InstructionAccordion(
              index: '01',
              icon: Icons.home_filled,
              iconColor: Colors.blue,
              title: l10n.inst_home,
              subtitle: l10n.inst_home_subtitle,
              expandedContent: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(text: l10n.inst_home_part1),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(color: const Color(0xFF7B66D9), borderRadius: BorderRadius.circular(16)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.qr_code_scanner, color: Color(0xFF0F172A), size: 14), const SizedBox(width: 6), Text(l10n.inst_home_scan_btn, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13))]),
                        ),
                      ),
                      TextSpan(text: l10n.inst_home_part2),
                    ],
                  ),
                ),
              ),
            ),
            
            _InstructionAccordion(
              index: '02',
              icon: Icons.qr_code_scanner,
              iconColor: Colors.green,
              title: l10n.inst_attendance,
              subtitle: l10n.inst_attendance_subtitle,
              expandedContent: _buildQRAttendanceContent(context, isDark, l10n),
            ),
            
            _InstructionAccordion(
              index: '03',
              icon: Icons.calendar_month,
              iconColor: Colors.purple,
              title: l10n.inst_calendar,
              subtitle: l10n.inst_calendar_subtitle,
              expandedContent: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.inst_calendar_desc,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            
            _InstructionAccordion(
              index: '04',
              icon: Icons.palette,
              iconColor: Colors.orange,
              title: l10n.inst_colors,
              subtitle: l10n.inst_colors_subtitle,
              expandedContent: _buildAttendanceColorsContent(context, l10n),
            ),
            
            _InstructionAccordion(
              index: '05',
              icon: Icons.person,
              iconColor: Colors.teal,
              title: l10n.inst_status,
              subtitle: l10n.inst_status_subtitle,
              expandedContent: _buildStudentStatusContent(context, l10n),
            ),
            
            _InstructionAccordion(
              index: '06',
              icon: Icons.menu_book,
              iconColor: Colors.redAccent,
              title: l10n.inst_study,
              subtitle: l10n.inst_study_subtitle,
              expandedContent: _buildStudyAreaContent(context, isDark, l10n),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFFE8EFFF), const Color(0xFFF3F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.blue.withValues(alpha: 0.05),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.inst_welcome_to,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.blue.shade200 : const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.inst_shresht_library,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.inst_header_title,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0, bottom: 0),
                  child: Image.asset(
                    'assets/images/inst_header_boy.png',
                    height: 150,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRAttendanceContent(BuildContext context, bool isDark, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final bgColor = isDark ? Colors.green.withValues(alpha: 0.1) : Colors.green.shade50;
    
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/images/inst_qr_scan.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.inst_qr_desc,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          
          // Timing Box
          Container(
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.inst_qr_timing,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l10n.inst_qr_dynamic,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeCol(l10n.inst_qr_start_time, '09:00 AM', Colors.green),
                    _buildTimeCol(l10n.inst_qr_allowed_time, '09:00 - 09:30 AM', Colors.orange),
                    _buildTimeCol(l10n.inst_qr_end_time, '10:00 PM', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildRuleItem(context, Icons.check_circle, Colors.green, l10n.inst_qr_rule1_title, Text(l10n.inst_qr_rule1_desc, style: const TextStyle(fontSize: 12))),
          _buildRuleItem(context, Icons.schedule, Colors.orange, l10n.inst_qr_rule2_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(text: l10n.inst_qr_rule2_desc1),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Transform.scale(scale: 0.8, child: const StatusBadge(status: 'ABSENT')),
                  ),
                  TextSpan(text: l10n.inst_qr_rule2_desc2),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.error_outline, Colors.redAccent, l10n.inst_qr_rule3_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(text: l10n.inst_qr_rule3_desc1),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Transform.scale(scale: 0.8, child: const StatusBadge(status: 'LATE')),
                  ),
                  TextSpan(text: l10n.inst_qr_rule3_desc2),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.info, Colors.blue, l10n.inst_qr_rule4_title, const SizedBox()),
          
          const SizedBox(height: 20),
          
          // How to Scan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.inst_qr_how_to,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
                const SizedBox(height: 12),
                _buildStep(context, 1, Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      TextSpan(text: l10n.inst_qr_step1_1),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(color: const Color(0xFF7B66D9), borderRadius: BorderRadius.circular(16)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.qr_code_scanner, color: Color(0xFF0F172A), size: 14), const SizedBox(width: 6), Text(l10n.inst_home_scan_btn, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13))]),
                        ),
                      ),
                      TextSpan(text: l10n.inst_qr_step1_2),
                    ],
                  ),
                )),
                _buildStep(context, 2, Text(l10n.inst_qr_step2, style: const TextStyle(fontSize: 13))),
                _buildStep(context, 3, Text(l10n.inst_qr_step3, style: const TextStyle(fontSize: 13))),
                _buildStep(context, 4, Text(l10n.inst_qr_step4, style: const TextStyle(fontSize: 13))),
                _buildStep(context, 5, Text(l10n.inst_qr_step5, style: const TextStyle(fontSize: 13))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCol(String label, String time, Color timeColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: timeColor)),
      ],
    );
  }

  Widget _buildRuleItem(BuildContext context, IconData icon, Color color, String title, Widget subtitleWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                subtitleWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int step, Widget textWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text('$step', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(child: textWidget),
        ],
      ),
    );
  }

  Widget _buildStudyAreaContent(BuildContext context, bool isDark, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final bgColor = isDark ? Colors.redAccent.withValues(alpha: 0.1) : Colors.red.shade50;
    
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/inst_study_girl.png',
              width: double.infinity,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.inst_study_desc_main,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          _buildStudyRuleItem(context, Icons.play_circle_outline, l10n.inst_study_start_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(text: l10n.inst_study_start_1),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.play_arrow, color: Colors.white, size: 14), const SizedBox(width: 4), Text(l10n.inst_study_start_btn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
                    ),
                  ),
                  TextSpan(text: l10n.inst_study_start_2),
                ],
              ),
            )
          ),
          _buildStudyRuleItem(context, Icons.pause_circle_outline, l10n.inst_study_pause_title, Text(l10n.inst_study_pause_desc, style: const TextStyle(fontSize: 12))),
          _buildStudyRuleItem(context, Icons.timelapse, l10n.inst_study_break_title, Text(l10n.inst_study_break_desc, style: const TextStyle(fontSize: 12))),
          _buildStudyRuleItem(context, Icons.stop_circle_outlined, l10n.inst_study_end_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(text: l10n.inst_study_end_1),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade100)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.stop, color: Colors.red, size: 14), const SizedBox(width: 4), Text(l10n.inst_study_end_btn, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))]),
                    ),
                  ),
                  TextSpan(text: l10n.inst_study_end_2),
                ],
              ),
            )
          ),
          _buildStudyRuleItem(context, Icons.bar_chart, l10n.inst_study_analytics_title, Text(l10n.inst_study_analytics_desc, style: const TextStyle(fontSize: 12))),
          _buildStudyRuleItem(context, Icons.local_fire_department_outlined, l10n.inst_study_streak_title, Text(l10n.inst_study_streak_desc, style: const TextStyle(fontSize: 12))),
          
          const SizedBox(height: 16),
          
          // Tips Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent.withValues(alpha: 0.2), Colors.redAccent.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.inst_tips, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      const SizedBox(height: 8),
                      _buildBullet(l10n.inst_tip1),
                      _buildBullet(l10n.inst_tip2),
                      _buildBullet(l10n.inst_tip3),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/inst_target.png',
                  width: 60,
                  height: 60,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyRuleItem(BuildContext context, IconData icon, String title, Widget subtitleWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                subtitleWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildAttendanceColorsContent(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleItem(context, Icons.check_circle, Colors.green, l10n.inst_color_present_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'PRESENT', time: '09:00 AM'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_color_present_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.schedule, Colors.orange, l10n.inst_color_late_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'LATE', time: '09:00 AM'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_color_late_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.cancel, Colors.red, l10n.inst_color_absent_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'ABSENT'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_color_absent_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.beach_access, Colors.blue, l10n.inst_color_holiday_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'HOLIDAY'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_color_holiday_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.hourglass_empty, Colors.grey, l10n.inst_color_pending_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'PENDING'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_color_pending_desc),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStatusContent(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleItem(context, Icons.verified_user, Colors.green, l10n.inst_status_live_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'LIVE'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_status_live_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.hourglass_empty, Colors.orange, l10n.inst_status_pending_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'PENDING'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_status_pending_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.block, Colors.red, l10n.inst_status_suspended_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'SUSPENDED'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_status_suspended_desc),
                ],
              ),
            )
          ),
          _buildRuleItem(context, Icons.error_outline, Colors.red, l10n.inst_status_expired_title, 
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 4.0),
                      child: StatusBadge(status: 'EXPIRED'),
                    ),
                  ),
                  TextSpan(text: l10n.inst_status_expired_desc),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}

class _InstructionAccordion extends StatefulWidget {
  final String index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget expandedContent;

  const _InstructionAccordion({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.expandedContent,
  });

  @override
  State<_InstructionAccordion> createState() => _InstructionAccordionState();
}

class _InstructionAccordionState extends State<_InstructionAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final borderColor = _isExpanded ? widget.iconColor : theme.dividerColor.withValues(alpha: 0.1);
    final headerBgColor = _isExpanded ? widget.iconColor.withValues(alpha: 0.05) : (isDark ? theme.colorScheme.surface : Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: _isExpanded ? 1.5 : 1),
        boxShadow: [
          if (!_isExpanded)
            BoxShadow(
              color: isDark ? Colors.black12 : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                color: headerBgColor,
                child: Row(
                  children: [
                    // Index
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _isExpanded ? widget.iconColor : (isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.index,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isExpanded ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                    ),
                    
                    // Chevron or Expanded Icon
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.chevron_right,
                      color: _isExpanded ? widget.iconColor : (isDark ? Colors.white54 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            
            // Expanded Content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: widget.expandedContent,
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
