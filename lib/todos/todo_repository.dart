import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/todo.dart';

class TodoRepository {
  final Dio _dio;
  static const String _url = 'https://jsonplaceholder.typicode.com/todos';
  static const String _invalidUrl = 'https://jsonplaceholder.typicode.com/nope';

  TodoRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches todos from the network with exponential backoff & jitter retry handling
  Future<List<Todo>> fetchTodos({
    bool useInvalidPath = false,
    int maxAttempts = 4,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
  }) async {
    final targetUrl = useInvalidPath ? _invalidUrl : _url;
    final random = Random();
    int attempt = 1;
    Duration currentDelay = initialDelay;

    while (true) {
      try {
        debugPrint('[TodoRepository] Attempt #$attempt: GET $targetUrl');
        final response = await _dio.get(targetUrl);
        final List<dynamic> data = response.data;
        return data.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
      } catch (error) {
        if (attempt >= maxAttempts) {
          debugPrint('[TodoRepository] Max attempts ($maxAttempts) reached. Request failed.');
          rethrow;
        }

        final double jitterMs = random.nextDouble() * (currentDelay.inMilliseconds * 0.5);
        final Duration delayWithJitter = currentDelay + Duration(milliseconds: jitterMs.toInt());

        final String errorStr = error is DioException
            ? 'HTTP ${error.response?.statusCode ?? error.type.name}'
            : error.toString();

        debugPrint(
          '[TodoRepository Backoff] Attempt #$attempt failed ($errorStr). Retrying in ${delayWithJitter.inMilliseconds}ms...',
        );

        await Future.delayed(delayWithJitter);

        attempt++;
        currentDelay = Duration(milliseconds: (currentDelay.inMilliseconds * backoffFactor).toInt());
      }
    }
  }
}
