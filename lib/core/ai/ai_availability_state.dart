import 'package:equatable/equatable.dart';

/// Whether the store has AI. Nothing AI-related is shown unless [enabled].
class AiAvailabilityState extends Equatable {
  final bool enabled;

  const AiAvailabilityState({required this.enabled});

  /// Before the first answer, and whenever there is no active session.
  const AiAvailabilityState.disabled() : enabled = false;

  @override
  List<Object?> get props => [enabled];
}
