import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_availability_cubit.dart';

extension AiAvailabilityContext on BuildContext {
  /// Whether this store has AI. Rebuilds the caller when the answer changes, and is safe to call from the builder callbacks of lists and layouts.
  ///
  /// Every AI option in the app is guarded by this: when it is false the option
  /// is not rendered at all, rather than shown disabled.
  bool get isAiEnabled =>
      watch<AiAvailabilityCubit>().state.enabled;
}
