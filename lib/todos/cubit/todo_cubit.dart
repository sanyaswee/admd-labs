import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/todo_api.dart';
import '../../models/todo.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoApi _api;

  TodoCubit({TodoApi? api})
      : _api = api ?? TodoApi(),
        super(const TodoState());

  Future<void> load({bool useInvalidPath = false}) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final todos = await _api.fetchTodos(useInvalidPath: useInvalidPath);
      emit(TodoState(todos: todos, loading: false));
    } catch (e) {
      emit(TodoState(todos: const [], loading: false, errorMessage: e.toString()));
    }
  }

  void add(String title) {
    final text = title.trim();
    if (text.isEmpty) return;
    final newTodo = Todo(
      userId: 1,
      id: DateTime.now().millisecondsSinceEpoch,
      title: text,
      completed: false,
    );
    emit(state.copyWith(todos: [...state.todos, newTodo]));
  }

  void toggle(int id) {
    emit(state.copyWith(todos: [
      for (final t in state.todos)
        if (t.id == id) t.copyWith(completed: !t.completed) else t,
    ]));
  }

  void remove(int id) {
    emit(state.copyWith(todos: state.todos.where((t) => t.id != id).toList()));
  }

  void restore(int index, Todo todo) {
    final updated = List<Todo>.from(state.todos);
    if (index >= 0 && index <= updated.length) {
      updated.insert(index, todo);
    } else {
      updated.add(todo);
    }
    emit(state.copyWith(todos: updated));
  }
}
