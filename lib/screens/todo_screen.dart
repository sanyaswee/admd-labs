import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _items = <Todo>[
    const Todo(userId: 1, id: 1, title: 'Task #1', completed: false),
    const Todo(userId: 1, id: 2, title: 'Task #2', completed: false),
    const Todo(userId: 1, id: 3, title: 'Task #3', completed: false),
  ];
  final _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
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
      ),
      body: Column(
        children: [
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
          const SizedBox(height: 8),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No todos yet!'))
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
