import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/session_manager.dart';
import 'ai_availability_state.dart';
import 'ai_status_api_service.dart';

/// Single source of truth for "does this store have AI", for both the supplier
/// and the retailer side of the app.
///
/// Starts off, so nothing AI-related flashes up before the server has answered.
/// Follows the session: asked when one becomes active, and switched back off the
/// moment it ends, so the next person to sign in never inherits the last one's
/// answer.
class AiAvailabilityCubit extends Cubit<AiAvailabilityState> {
  final AiStatusApiService apiService;
  final SessionManager session;

  AuthStatus _lastStatus;

  AiAvailabilityCubit({required this.apiService, required this.session})
    : _lastStatus = session.status,
      super(const AiAvailabilityState.disabled()) {
    session.addListener(_onSessionChanged);

    if (_lastStatus == AuthStatus.authenticated) {
      refresh();
    }
  }

  /// Asks the server again. Cheap enough to call when a screen that depends on
  /// the answer opens, because the plan can change while the app is open.
  Future<void> refresh() async {
    if (session.status != AuthStatus.authenticated) {
      _switchOff();
      return;
    }

    final enabled = await apiService.fetchAiEnabled();

    // The session may have ended while the request was in flight.
    if (isClosed || session.status != AuthStatus.authenticated) return;

    emit(AiAvailabilityState(enabled: enabled));
  }

  void _onSessionChanged() {
    final status = session.status;
    if (status == _lastStatus) return;
    _lastStatus = status;

    if (status == AuthStatus.authenticated) {
      refresh();
    } else {
      _switchOff();
    }
  }

  void _switchOff() {
    if (isClosed) return;
    emit(const AiAvailabilityState.disabled());
  }

  @override
  Future<void> close() {
    session.removeListener(_onSessionChanged);
    return super.close();
  }
}
