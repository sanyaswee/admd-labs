import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/todo.dart';
import '../todos/cubit/todo_cubit.dart';
import '../todos/cubit/todo_state.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAdd(BuildContext context) {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    context.read<TodoCubit>().add(text);
    _input.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleRemove(BuildContext context, int index, Todo todo) {
    context.read<TodoCubit>().remove(todo.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${todo.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<TodoCubit>().restore(index, todo);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Fetch /todos',
            onPressed: () => context.read<TodoCubit>().load(useInvalidPath: false),
          ),
          IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.redAccent),
            tooltip: 'Test Invalid Path (/nope)',
            onPressed: () => context.read<TodoCubit>().load(useInvalidPath: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Buttons Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<TodoCubit>().load(useInvalidPath: false),
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Fetch /todos'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                    onPressed: () => context.read<TodoCubit>().load(useInvalidPath: true),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test /nope'),
                  ),
                ),
              ],
            ),
          ),

          // Manual Add Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      labelText: 'New Todo Title',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _handleAdd(context),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _handleAdd(context),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // Main Content List or Error State managed by BlocBuilder
          Expanded(
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state.loading && state.todos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null && state.todos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to fetch todos:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<TodoCubit>().load(useInvalidPath: false),
                            child: const Text('Retry /todos'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.todos.isEmpty) {
                  return const Center(child: Text('No todos available!'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final item = state.todos[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _handleRemove(context, index, item),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: TodoTile(
                        todo: item,
                        onChanged: (_) => context.read<TodoCubit>().toggle(item.id),
                        onDelete: () => _handleRemove(context, index, item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: onChanged,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: todo.completed ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                todo.completed ? 'Done' : 'Pending',
                style: TextStyle(
                  fontSize: 10,
                  color: todo.completed ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
