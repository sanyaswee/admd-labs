import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/todo.dart';

class RetryLog {
  final int attempt;
  final Duration delay;
  final String message;
  final DateTime timestamp;

  RetryLog(this.attempt, this.delay, this.message) : timestamp = DateTime.now();
}

class TodoApi {
  final Dio _dio;
  static const String validUrl = 'https://jsonplaceholder.typicode.com/todos';
  static const String invalidUrl = 'https://jsonplaceholder.typicode.com/nope';

  TodoApi({Dio? dio}) : _dio = dio ?? Dio();

  /// Executes an async action with exponential backoff, random jitter, and retry attempts.
  Future<T> withRetry<T>(
    Future<T> Function() action, {
    int maxAttempts = 4,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    void Function(RetryLog log)? onAttemptLog,
  }) async {
    final random = Random();
    int attempt = 1;
    Duration currentDelay = initialDelay;

    while (true) {
      try {
        final log = RetryLog(
          attempt,
          attempt == 1 ? Duration.zero : currentDelay,
          '[TodoApi] Attempt #$attempt: Sending request...',
        );
        if (onAttemptLog != null) onAttemptLog(log);
        debugPrint(log.message);

        return await action();
      } catch (error) {
        if (attempt >= maxAttempts) {
          final failLog = RetryLog(
            attempt,
            Duration.zero,
            '[TodoApi] Attempt #$attempt failed: ${error is DioException ? error.message ?? error.toString() : error}. Max attempts ($maxAttempts) reached.',
          );
          if (onAttemptLog != null) onAttemptLog(failLog);
          debugPrint(failLog.message);
          rethrow;
        }

        // Calculate exponential backoff with random jitter
        final double jitterMs = random.nextDouble() * (currentDelay.inMilliseconds * 0.5);
        final Duration delayWithJitter = currentDelay + Duration(milliseconds: jitterMs.toInt());

        final String errorStr = error is DioException 
            ? 'HTTP ${error.response?.statusCode ?? error.type.name}' 
            : error.toString();

        final logMsg =
            '[TodoApi Backoff] Attempt #$attempt failed ($errorStr). Retrying in ${delayWithJitter.inMilliseconds}ms (base: ${currentDelay.inMilliseconds}ms + jitter)...';

        final log = RetryLog(attempt, delayWithJitter, logMsg);
        if (onAttemptLog != null) onAttemptLog(log);
        debugPrint(log.message);

        await Future.delayed(delayWithJitter);

        attempt++;
        currentDelay = Duration(milliseconds: (currentDelay.inMilliseconds * backoffFactor).toInt());
      }
    }
  }

  /// Fetch todos from API using valid or invalid endpoint
  Future<List<Todo>> fetchTodos({
    bool useInvalidPath = false,
    int maxAttempts = 4,
    void Function(RetryLog log)? onAttemptLog,
  }) async {
    final url = useInvalidPath ? invalidUrl : validUrl;

    return withRetry<List<Todo>>(
      () async {
        final response = await _dio.get(url);
        final List<dynamic> data = response.data;
        return data.map((item) => Todo.fromJson(item as Map<String, dynamic>)).toList();
      },
      maxAttempts: maxAttempts,
      onAttemptLog: onAttemptLog,
    );
  }
}
