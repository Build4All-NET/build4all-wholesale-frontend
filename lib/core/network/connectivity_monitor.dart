import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// Watches for network changes (Wi-Fi <-> mobile data) and immediately drops
/// the pooled HTTP connections of every [ApiClient], so the next request opens
/// a fresh socket on the new interface instead of hanging on a dead one left
/// over from the previous network.
class ConnectivityMonitor {
  final List<ApiClient> clients;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult>? _last;

  ConnectivityMonitor(this.clients, {Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  void start() {
    _subscription ??= _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (Object error) {
        debugPrint('ConnectivityMonitor error: $error');
      },
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    // Ignore duplicate events that report the same interface set.
    if (_last != null && _listEquals(_last!, result)) {
      return;
    }
    _last = result;

    for (final client in clients) {
      client.resetConnections();
    }
  }

  bool _listEquals(List<ConnectivityResult> a, List<ConnectivityResult> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
