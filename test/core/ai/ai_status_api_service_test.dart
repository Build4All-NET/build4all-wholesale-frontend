import 'package:build4all_wholesale_frontend/core/ai/ai_status_api_service.dart';
import 'package:build4all_wholesale_frontend/core/network/api_client.dart';
import 'package:build4all_wholesale_frontend/core/network/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ai_test_fakes.dart';

/// The app shows AI options only on a clear "yes" from the server, so every
/// other kind of answer has to read as "no".
void main() {
  late FakeHttpAdapter adapter;

  AiStatusApiService serviceAnswering(FakeHttpAdapter fake) {
    adapter = fake;
    final client = ApiClient(FakeAuthStorage(), baseUrl: 'http://wholesale.test/api');
    client.dio.httpClientAdapter = adapter;
    return AiStatusApiService(client);
  }

  test('asks the AI status endpoint', () async {
    final service = serviceAnswering(
      FakeHttpAdapter((_) => FakeHttpAdapter.json({AiStatusApiService.enabledKey: true})),
    );

    await service.fetchAiEnabled();

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, ApiConfig.aiStatus);
  });

  test('is enabled only when the server says so', () async {
    final service = serviceAnswering(
      FakeHttpAdapter((_) => FakeHttpAdapter.json({AiStatusApiService.enabledKey: true})),
    );

    expect(await service.fetchAiEnabled(), isTrue);
  });

  test('is disabled when the server says the store has no AI', () async {
    final service = serviceAnswering(
      FakeHttpAdapter((_) => FakeHttpAdapter.json({AiStatusApiService.enabledKey: false})),
    );

    expect(await service.fetchAiEnabled(), isFalse);
  });

  test('is disabled when the answer is not what was asked for', () async {
    for (final body in <Object>[
      <String, Object>{},
      {AiStatusApiService.enabledKey: 'true'},
      {AiStatusApiService.enabledKey: null},
      ['aiEnabled'],
      'yes',
    ]) {
      final service = serviceAnswering(FakeHttpAdapter((_) => FakeHttpAdapter.json(body)));

      expect(await service.fetchAiEnabled(), isFalse, reason: 'for $body');
    }
  });

  test('is disabled when the server refuses', () async {
    final service = serviceAnswering(
      FakeHttpAdapter((_) => FakeHttpAdapter.json({'error': 'no'}, status: 403)),
    );

    expect(await service.fetchAiEnabled(), isFalse);
  });
}
