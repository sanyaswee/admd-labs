import 'package:flutter/material.dart';
import '../api/todo_api.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Todo> _items = [];
  final TodoApi _api = TodoApi();

  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTodos(useInvalidPath: false);
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTodos({required bool useInvalidPath}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (useInvalidPath) {
        _items.clear();
      }
    });

    try {
      final todos = await _api.fetchTodos(
        useInvalidPath: useInvalidPath,
        maxAttempts: 4,
      );

      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(todos);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _add() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _items.add(Todo(
        userId: 1,
        id: DateTime.now().millisecondsSinceEpoch,
        title: text,
        completed: false,
      ));
    });
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

  void _removeTodo(int index, Todo todo) {
    setState(() {
      _items.removeWhere((t) => t.id == todo.id);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${todo.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index, todo);
            });
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
            onPressed: () => _fetchTodos(useInvalidPath: false),
          ),
          IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.redAccent),
            tooltip: 'Test Invalid Path (/nope)',
            onPressed: () => _fetchTodos(useInvalidPath: true),
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
                    onPressed: _isLoading ? null : () => _fetchTodos(useInvalidPath: false),
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
                    onPressed: _isLoading ? null : () => _fetchTodos(useInvalidPath: true),
                    icon: const Icon(Icons.error),
                    label: const Text('404'),
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
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _add,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // Main Content List or Error State
          Expanded(
            child: _isLoading && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null && _items.isEmpty
                    ? Center(
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
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _fetchTodos(useInvalidPath: false),
                                child: const Text('Retry /todos'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _items.isEmpty
                        ? const Center(child: Text('No todos available!'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _removeTodo(index, item),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: TodoTile(
                                  todo: item,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        _items[index] = item.copyWith(completed: value);
                                      });
                                    }
                                  },
                                  onDelete: () => _removeTodo(index, item),
                                ),
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
