import 'dart:async';
import 'dart:convert';

import 'package:build4all_wholesale_frontend/core/ai/ai_status_api_service.dart';
import 'package:build4all_wholesale_frontend/core/auth/session_manager.dart';
import 'package:build4all_wholesale_frontend/core/storage/auth_storage.dart';
import 'package:build4all_wholesale_frontend/features/auth/data/services/auth_service.dart';
import 'package:dio/dio.dart';

/// Credentials storage that holds nothing: the tests drive the session directly.
class FakeAuthStorage implements AuthStorage {
  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> clearSession() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SessionManager newSession() =>
    SessionManager(authStorage: FakeAuthStorage(), authService: FakeAuthService());

/// A session that is already signed in as [role].
SessionManager signedInSession({String role = 'SUPPLIER'}) =>
    newSession()..onLogin(role: role, profileCompleted: true);

/// Answers like the server, one canned answer per call, and counts the calls.
class FakeAiStatusApiService implements AiStatusApiService {
  FakeAiStatusApiService(this.answer);

  /// Decides each answer. Replace it to hold a request in flight.
  Future<bool> Function() answer;

  int calls = 0;

  @override
  Future<bool> fetchAiEnabled() {
    calls++;
    return answer();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A Dio transport that answers with whatever [respond] returns.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody json(Object body, {int status = 200}) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
