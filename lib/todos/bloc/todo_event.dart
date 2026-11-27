import 'package:equatable/equatable.dart';
import '../../models/todo.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {
  final bool useInvalidPath;

  const LoadTodos({this.useInvalidPath = false});

  @override
  List<Object?> get props => [useInvalidPath];
}

class AddTodo extends TodoEvent {
  final String title;

  const AddTodo(this.title);

  @override
  List<Object?> get props => [title];
}

class ToggleTodo extends TodoEvent {
  final int id;

  const ToggleTodo(this.id);

  @override
  List<Object?> get props => [id];
}

class RemoveTodo extends TodoEvent {
  final int id;

  const RemoveTodo(this.id);

  @override
  List<Object?> get props => [id];
}

class RestoreTodo extends TodoEvent {
  final int index;
  final Todo todo;

  const RestoreTodo(this.index, this.todo);

  @override
  List<Object?> get props => [index, todo];
}
