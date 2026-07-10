import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool hasConnection = !results.contains(ConnectivityResult.none);
    if (_isConnected != hasConnection) {
      setState(() {
        _isConnected = hasConnection;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (!_isConnected)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (ctx) {
                              final l10n = AppLocalizations.of(ctx);
                              return Text(
                                l10n?.err_no_internet ?? 'No Internet Connection',
                                style: Theme.of(ctx).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              );
                            }
                          ),
                          const SizedBox(height: 24),
                          Builder(
                            builder: (ctx) {
                              final l10n = AppLocalizations.of(ctx);
                              return ElevatedButton.icon(
                                onPressed: () {
                                  _checkInitialConnection();
                                },
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n?.btn_retry ?? 'Retry'),
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
