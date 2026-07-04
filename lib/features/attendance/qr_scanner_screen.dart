import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/services/providers.dart';
import 'package:shreshtlibrary/features/home/home_screen.dart'; // dashboardProvider
import 'package:shreshtlibrary/common/widgets/status_badge.dart';

import 'package:shreshtlibrary/features/attendance/attendance_screen.dart'; // attendanceLogsProvider
import 'scanner_overlay.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _busy = false;
  
  // Custom states
  String? _errorTitle;
  String? _errorMessage;
  bool _isSuccess = false;
  String? _successStatus;
  String? _successTime;
  
  // Mobile scanner controller to handle camera states if needed
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _showError(String title, String message) {
    setState(() {
      _errorTitle = title;
      _errorMessage = message;
      _busy = false;
    });
  }

  Future<void> _submit(String value) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorTitle = null;
      _errorMessage = null;
    });
    
    try {
      final result = await ref.read(studentApiProvider).scanQr(value.trim());
      ref.invalidate(attendanceLogsProvider);
      ref.invalidate(dashboardProvider);
      
      if (!mounted) return;
      setState(() {
        _isSuccess = true;
        _busy = false;
        
        // Use result fields for the status badge
        String st = 'Present';
        if (result.lateMark) {
            st = 'Present (Arrived Late)';
        }
        _successStatus = st;
        _successTime = result.timeIn;
      });
      
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      
      final msg = failure.message.toLowerCase();
      String title = "Something Went Wrong";
      String message = "An unexpected error occurred. Please try again later.";
      
      if (msg.contains('invalid') || msg.contains('not valid')) {
        title = "Invalid QR Code";
        message = "This QR code is not valid. Please scan the QR code displayed by your library.";
      } else if (msg.contains('expire')) {
        title = "QR Code Expired";
        message = "This QR code has expired. Please scan the latest QR code.";
      } else if (msg.contains('not found')) {
        title = "QR Code Not Found";
        message = "Unable to verify the QR code. Please try again with the current library QR code.";
      } else if (msg.contains('already marked') || msg.contains('duplicate')) {
        title = "Attendance Already Recorded";
        message = "Your attendance has already been recorded. Multiple scans are not allowed.";
      } else if (msg.contains('window closed') || msg.contains('not allowed')) {
        title = "Attendance Closed";
        message = "Attendance can no longer be marked because the attendance window has ended.";
      } else if (msg.contains('holiday')) {
        title = "Library Holiday";
        message = "Attendance is not available today because the library is closed for a holiday.";
      } else if (msg.contains('inactive')) {
        title = "Attendance Not Allowed";
        message = "Your account is currently inactive. Please contact the library administrator.";
      } else if (msg.contains('used')) {
        title = "QR Code Already Used";
        message = "This QR code has already been used for your attendance today.";
      } else if (msg.contains('unavailable') || msg.contains('server')) {
        title = "Server Unavailable";
        message = "We're unable to process your attendance right now. Please try again shortly.";
      } else if (msg.contains('internet') || msg.contains('connection')) {
        title = "No Internet Connection";
        message = "Please check your internet connection and try again.";
      } else {
        title = "Scan Failed";
        message = failure.message;
      }
      
      _showError(title, message);
    } catch (e) {
      if (!mounted) return;
      _showError("Something Went Wrong", "An unexpected error occurred. Please try again later.");
    }
  }

  Widget _buildMessageCard(String title, String message, {IconData? icon, Color? color, Widget? extra}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 64, color: color ?? Colors.grey),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (extra != null) ...[
              const SizedBox(height: 32),
              extra,
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                if (_isSuccess || 
                    title == "Attendance Closed" || 
                    title == "Library Holiday" || 
                    title == "Attendance Already Recorded" || 
                    title == "Attendance Already Marked") {
                  context.pop();
                } else {
                  setState(() {
                    _errorTitle = null;
                    _errorMessage = null;
                    _isSuccess = false;
                    _scannerController.start();
                  });
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(_isSuccess ? 'Done' : 'Try Again / Back'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Attendance QR')),
      body: dashAsync.when(
        data: (dash) {
          if (dash.isHoliday) {
            return _buildMessageCard(
              "Library Holiday",
              "Attendance is not available today because the library is closed for a holiday.",
              icon: Icons.beach_access,
              color: Colors.blue,
            );
          }
          if (dash.markedAttendanceToday) {
            return _buildMessageCard(
              "Attendance Already Marked",
              "Your attendance has already been marked for today.",
              icon: Icons.check_circle,
              color: Colors.green,
            );
          }
          if (!dash.allowQrScan) {
            return _buildMessageCard(
              "Attendance Closed",
              "Attendance can no longer be marked because the attendance window has ended.",
              icon: Icons.timer_off,
              color: Colors.red,
            );
          }
          
          if (_isSuccess) {
            return _buildMessageCard(
              "Attendance Marked",
              "Your attendance has been marked successfully.",
              icon: Icons.check_circle,
              color: Colors.green,
              extra: _successStatus != null ? StatusBadge(
                status: _successStatus!,
                time: _successTime,
              ) : null,
            );
          }
          
          if (_errorTitle != null) {
            return _buildMessageCard(
              _errorTitle!,
              _errorMessage!,
              icon: Icons.error_outline,
              color: Colors.red,
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                width: double.infinity,
                child: Text(
                  _busy ? "Marking Attendance" : "Ready to Scan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.surface,
                width: double.infinity,
                child: Text(
                  _busy 
                      ? "Please wait while we verify your QR code and mark your attendance."
                      : "Scan the QR code displayed by the library to mark your attendance.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final value = capture.barcodes.firstOrNull?.rawValue;
                        if (value != null && !_busy) _submit(value);
                      },
                      errorBuilder: (context, error) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  "Camera Unavailable",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Unable to access the camera. Please restart the app or try again, or check camera permissions.",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    CustomPaint(
                      painter: ScannerOverlayPainter(
                        borderColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (_busy) 
                      Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 24),
                              Text("Scanning...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text("Please hold your phone steady while we scan.", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildMessageCard("Server Unavailable", "We're unable to process your attendance right now. Please try again shortly.", icon: Icons.wifi_off),
      ),
    );
  }
}
