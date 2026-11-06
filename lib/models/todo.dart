class Todo {
  final String id;
  String title;
  bool done;

  Todo(this.title, {this.done = false, String? id})
      : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
}
