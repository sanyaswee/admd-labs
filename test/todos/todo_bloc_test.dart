import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:labs/models/todo.dart';
import 'package:labs/todos/todo_repository.dart';
import 'package:labs/todos/bloc/todo_bloc.dart';
import 'package:labs/todos/bloc/todo_event.dart';
import 'package:labs/todos/bloc/todo_state.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  group('TodoBloc', () {
    late TodoRepository repository;

    setUp(() {
      repository = MockTodoRepository();
    });

    test('initial state is TodoState()', () {
      expect(TodoBloc(repository).state, const TodoState());
    });

    blocTest<TodoBloc, TodoState>(
      'emits [loading, todos] when LoadTodos succeeds',
      build: () {
        when(() => repository.fetchTodos(useInvalidPath: false)).thenAnswer(
          (_) async => const [Todo(userId: 1, id: 1, title: 'Test Todo', completed: false)],
        );
        return TodoBloc(repository);
      },
      act: (bloc) => bloc.add(const LoadTodos()),
      expect: () => const [
        TodoState(loading: true),
        TodoState(
          loading: false,
          todos: [Todo(userId: 1, id: 1, title: 'Test Todo', completed: false)],
        ),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits updated todos when ToggleTodo is added',
      build: () => TodoBloc(repository),
      seed: () => const TodoState(
        todos: [Todo(userId: 1, id: 1, title: 'Test Todo', completed: false)],
      ),
      act: (bloc) => bloc.add(const ToggleTodo(1)),
      expect: () => const [
        TodoState(
          todos: [Todo(userId: 1, id: 1, title: 'Test Todo', completed: true)],
        ),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits updated todos when RemoveTodo is added',
      build: () => TodoBloc(repository),
      seed: () => const TodoState(
        todos: [Todo(userId: 1, id: 1, title: 'Test Todo', completed: false)],
      ),
      act: (bloc) => bloc.add(const RemoveTodo(1)),
      expect: () => const [
        TodoState(todos: []),
      ],
    );
  });
}
