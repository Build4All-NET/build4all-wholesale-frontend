import 'dart:async';

import 'package:build4all_wholesale_frontend/core/ai/ai_availability_cubit.dart';
import 'package:build4all_wholesale_frontend/core/ai/ai_availability_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ai_test_fakes.dart';

/// The cubit decides whether the whole app shows AI, so the cases that matter
/// are the ones where showing it by mistake would be wrong: before the server
/// has answered, after the session has ended, and when an old answer arrives late.
void main() {
  Future<bool> Function() answering(bool value) =>
      () async => value;

  const on = AiAvailabilityState(enabled: true);
  const off = AiAvailabilityState.disabled();

  /// Lets the event queue run so a started refresh can finish.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('starts with AI off, before anything has been asked', () {
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(answering(true)),
      session: newSession(),
    );

    expect(cubit.state, off);
    addTearDown(cubit.close);
  });

  test('does not ask while nobody is signed in', () async {
    final api = FakeAiStatusApiService(answering(true));
    final cubit = AiAvailabilityCubit(apiService: api, session: newSession());
    addTearDown(cubit.close);

    await cubit.refresh();

    expect(api.calls, 0);
    expect(cubit.state, off);
  });

  test('asks once a session is active and turns AI on when the store has it', () async {
    final session = newSession();
    final api = FakeAiStatusApiService(answering(true));
    final cubit = AiAvailabilityCubit(apiService: api, session: session);
    addTearDown(cubit.close);

    session.onLogin(role: 'SUPPLIER', profileCompleted: true);
    await settle();

    expect(api.calls, 1);
    expect(cubit.state, on);
  });

  test('asks straight away when the session was already active', () async {
    final api = FakeAiStatusApiService(answering(true));
    final cubit = AiAvailabilityCubit(
      apiService: api,
      session: signedInSession(role: 'RETAILER'),
    );
    addTearDown(cubit.close);

    await settle();

    expect(api.calls, 1);
    expect(cubit.state, on);
  });

  test('keeps AI off when the store has none', () async {
    final session = newSession();
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(answering(false)),
      session: session,
    );
    addTearDown(cubit.close);

    session.onLogin(role: 'RETAILER', profileCompleted: true);
    await settle();

    expect(cubit.state, off);
  });

  test('turns AI off the moment the user signs out', () async {
    final session = signedInSession();
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(answering(true)),
      session: session,
    );
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state, on);

    await session.signOut();

    expect(cubit.state, off);
  });

  test('turns AI off when the session expires', () async {
    final session = signedInSession();
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(answering(true)),
      session: session,
    );
    addTearDown(cubit.close);
    await settle();

    session.onSessionExpired();

    expect(cubit.state, off);
  });

  test('the next person to sign in does not inherit the last answer', () async {
    final session = signedInSession();
    final answers = <bool>[true, false];
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(() async => answers.removeAt(0)),
      session: session,
    );
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state, on);

    await session.signOut();
    session.onLogin(role: 'RETAILER', profileCompleted: true);
    await settle();

    expect(cubit.state, off);
  });

  test('an answer that arrives after the session ended is ignored', () async {
    final session = signedInSession();
    final pending = Completer<bool>();
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(() => pending.future),
      session: session,
    );
    addTearDown(cubit.close);

    await session.signOut();
    pending.complete(true);
    await settle();

    expect(cubit.state, off);
  });

  test('picks up a plan change when asked again', () async {
    final session = signedInSession();
    final api = FakeAiStatusApiService(answering(true));
    final cubit = AiAvailabilityCubit(apiService: api, session: session);
    addTearDown(cubit.close);
    await settle();
    expect(cubit.state, on);

    api.answer = answering(false);
    await cubit.refresh();

    expect(cubit.state, off);
  });

  test('does not ask again for session changes that are not a sign-in or out', () async {
    final session = newSession()..onLogin(role: 'SUPPLIER', profileCompleted: false);
    final api = FakeAiStatusApiService(answering(true));
    final cubit = AiAvailabilityCubit(apiService: api, session: session);
    addTearDown(cubit.close);
    await settle();
    expect(api.calls, 1);

    session.markProfileCompleted();
    await settle();

    expect(api.calls, 1);
  });

  test('stops listening to the session once closed', () async {
    final session = newSession();
    final api = FakeAiStatusApiService(answering(true));
    final cubit = AiAvailabilityCubit(apiService: api, session: session);

    await cubit.close();
    session.onLogin(role: 'SUPPLIER', profileCompleted: true);
    await settle();

    expect(api.calls, 0);
  });
}
