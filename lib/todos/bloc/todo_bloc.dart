import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/todo.dart';
import '../todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repo;

  TodoBloc(this._repo) : super(const TodoState()) {
    on<LoadTodos>(_onLoad);
    on<AddTodo>(_onAdd);
    on<ToggleTodo>(_onToggle);
    on<RemoveTodo>(_onRemove);
    on<RestoreTodo>(_onRestore);
  }

  Future<void> _onLoad(LoadTodos event, Emitter<TodoState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final todos = await _repo.fetchTodos(useInvalidPath: event.useInvalidPath);
      emit(TodoState(todos: todos, loading: false));
    } catch (e) {
      emit(TodoState(todos: const [], loading: false, errorMessage: e.toString()));
    }
  }

  void _onAdd(AddTodo event, Emitter<TodoState> emit) {
    final text = event.title.trim();
    if (text.isEmpty) return;
    final newTodo = Todo(
      userId: 1,
      id: DateTime.now().millisecondsSinceEpoch,
      title: text,
      completed: false,
    );
    emit(state.copyWith(todos: [...state.todos, newTodo]));
  }

  void _onToggle(ToggleTodo event, Emitter<TodoState> emit) {
    emit(state.copyWith(todos: [
      for (final t in state.todos)
        if (t.id == event.id) t.copyWith(completed: !t.completed) else t,
    ]));
  }

  void _onRemove(RemoveTodo event, Emitter<TodoState> emit) {
    emit(state.copyWith(todos: state.todos.where((t) => t.id != event.id).toList()));
  }

  void _onRestore(RestoreTodo event, Emitter<TodoState> emit) {
    final updated = List<Todo>.from(state.todos);
    if (event.index >= 0 && event.index <= updated.length) {
      updated.insert(event.index, event.todo);
    } else {
      updated.add(event.todo);
    }
    emit(state.copyWith(todos: updated));
  }
}
