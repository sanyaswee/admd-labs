import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:labs/models/todo.dart';
import 'package:labs/todos/todo_repository.dart';
import 'package:labs/todos/bloc/todo_bloc.dart';
import 'package:labs/todos/bloc/todo_event.dart';
import 'package:labs/todos/bloc/todo_state.dart';

class FakeTodoRepository extends Mock implements TodoRepository {}

void main() {
  final repo = FakeTodoRepository();

  blocTest<TodoBloc, TodoState>(
    'add then toggle emits two states in order',
    build: () => TodoBloc(repo),
    act: (bloc) => bloc
      ..add(const AddTodo('Milk'))
      ..add(const ToggleTodo(1)),
    expect: () => const [
      TodoState(todos: [Todo(userId: 1, id: 1, title: 'Milk', completed: false)]),
      TodoState(todos: [Todo(userId: 1, id: 1, title: 'Milk', completed: true)]),
    ],
  );
}
