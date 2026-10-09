import 'package:build4all_wholesale_frontend/core/ai/ai_availability_cubit.dart';
import 'package:build4all_wholesale_frontend/core/ai/ai_availability_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ai_test_fakes.dart';

/// Every AI option in the app is guarded by `context.isAiEnabled`, including
/// ones built inside list and layout callbacks.
void main() {
  const aiOption = 'Ask AI';

  Widget app(AiAvailabilityCubit cubit) {
    return MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          body: Column(
            children: [
              Builder(
                builder: (context) =>
                    context.isAiEnabled ? const Text(aiOption) : const SizedBox.shrink(),
              ),
              // Inside a builder callback, the way the product lists use it.
              SizedBox(
                height: 50,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, _) =>
                      context.isAiEnabled ? const Text('$aiOption in list') : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('shows nothing while the store has no AI', (tester) async {
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(() async => false),
      session: signedInSession(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(app(cubit));
    await tester.pump();

    expect(find.text(aiOption), findsNothing);
    expect(find.text('$aiOption in list'), findsNothing);
  });

  testWidgets('shows the option once the store has AI, and removes it again when it loses it', (tester) async {
    final api = FakeAiStatusApiService(() async => true);
    final cubit = AiAvailabilityCubit(apiService: api, session: signedInSession());
    addTearDown(cubit.close);

    await tester.pumpWidget(app(cubit));
    await tester.pump();

    expect(find.text(aiOption), findsOneWidget);
    expect(find.text('$aiOption in list'), findsOneWidget);

    api.answer = () async => false;
    await cubit.refresh();
    // One frame for the cubit's state stream to deliver, one to rebuild.
    await tester.pump();
    await tester.pump();

    expect(find.text(aiOption), findsNothing);
    expect(find.text('$aiOption in list'), findsNothing);
  });

  testWidgets('shows nothing before the first answer', (tester) async {
    final cubit = AiAvailabilityCubit(
      apiService: FakeAiStatusApiService(() async => true),
      session: newSession(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(app(cubit));

    expect(find.text(aiOption), findsNothing);
  });
}
