import 'package:equatable/equatable.dart';
import '../../models/todo.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final bool loading;
  final String? errorMessage;

  const TodoState({
    this.todos = const [],
    this.loading = false,
    this.errorMessage,
  });

  TodoState copyWith({
    List<Todo>? todos,
    bool? loading,
    String? errorMessage,
  }) =>
      TodoState(
        todos: todos ?? this.todos,
        loading: loading ?? this.loading,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [todos, loading, errorMessage];
}
