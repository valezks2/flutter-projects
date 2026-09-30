import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> _todos = [];

  final TextEditingController _textController = TextEditingController();

  bool _isSearching = false;

  String _searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();

    final String? todosJson = prefs.getString('todo_list');

    if (todosJson != null) {
      setState(() {
        _todos = Todo.decode(todosJson);
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedData = Todo.encode(_todos);

    await prefs.setString('todo_list', encodedData);
  }

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      _todos.add(Todo(id: DateTime.now().toString(), title: title.trim()));
    });

    _saveTodos();

    _textController.clear();
  }

  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((item) => item.id == id);

      todo.isDone = !todo.isDone;
    });

    _saveTodos();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((item) => item.id == id);
    });

    _saveTodos();
  }

  void _clearCompleted() {
    setState(() {
      _todos.removeWhere((item) => item.isDone);
    });

    _saveTodos();
  }

  void _confirmDelete({
    required String title,

    required String message,

    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),

            side: BorderSide(color: Colors.grey.shade200),
          ),

          title: Text(
            title,

            style: const TextStyle(
              fontWeight: FontWeight.w700,

              color: Color(0xFF111827),
            ),
          ),

          content: Text(
            message,

            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text(
                'Cancel',

                style: TextStyle(
                  color: Colors.grey,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                onConfirm();

                Navigator.pop(context);
              },

              child: const Text(
                'Delete',

                style: TextStyle(
                  color: Colors.redAccent,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openAddDialog() {
    _textController.clear();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),

            side: BorderSide(color: Colors.grey.shade200),
          ),

          title: const Text(
            'Add New Task',

            style: TextStyle(
              fontWeight: FontWeight.w700,

              color: Color(0xFF111827),
            ),
          ),

          content: TextField(
            controller: _textController,

            autofocus: true,

            style: const TextStyle(fontSize: 16),

            decoration: InputDecoration(
              hintText: 'Type task title...',

              hintStyle: TextStyle(color: Colors.grey.shade400),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),

              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),

            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _addTodo(value);

                Navigator.pop(context);
              }
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            TextButton(
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _addTodo(_textController.text);

                  Navigator.pop(context);
                }
              },

              child: const Text(
                'Add',

                style: TextStyle(
                  color: Colors.black,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openEditDialog(Todo todo) {
    final editController = TextEditingController(text: todo.title);

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),

            side: BorderSide(color: Colors.grey.shade200),
          ),

          title: const Text(
            'Edit Task',

            style: TextStyle(
              fontWeight: FontWeight.w700,

              color: Color(0xFF111827),
            ),
          ),

          content: TextField(
            controller: editController,

            autofocus: true,

            decoration: InputDecoration(
              hintText: 'Update task title...',

              hintStyle: TextStyle(color: Colors.grey.shade400),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),

              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),

            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _updateTodo(todo.id, value, todo.isDone);

                Navigator.pop(context);
              }
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            TextButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  _updateTodo(todo.id, editController.text, todo.isDone);

                  Navigator.pop(context);
                }
              },

              child: const Text(
                'Save',

                style: TextStyle(
                  color: Colors.black,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateTodo(String id, String newTitle, bool isDone) {
    setState(() {
      final index = _todos.indexWhere((element) => element.id == id);

      if (index != -1) {
        _todos[index] = Todo(id: id, title: newTitle.trim(), isDone: isDone);
      }
    });

    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _todos.where((todo) {
      return todo.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final completedCount = _todos.where((todo) => todo.isDone).length;

    return PopScope(
      canPop: !_isSearching,

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_isSearching) {
          setState(() {
            _isSearching = false;
            _searchQuery = "";
            _searchController.clear();
          });
          return;
        }

        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,

          elevation: 0,

          scrolledUnderElevation: 0,

          title: !_isSearching
              ? const Text(
                  'Tasks',

                  style: TextStyle(
                    fontWeight: FontWeight.w800,

                    color: Color(0xFF111827),

                    fontSize: 28,

                    letterSpacing: -0.5,
                  ),
                )
              : TextField(
                  controller: _searchController,

                  autofocus: true,

                  style: const TextStyle(
                    fontSize: 18,

                    color: Color(0xFF111827),
                  ),

                  decoration: InputDecoration(
                    isDense: true,

                    contentPadding: const EdgeInsets.symmetric(vertical: 10),

                    prefixIcon: Icon(
                      Icons.search,

                      color: Colors.grey.shade400,

                      size: 22,
                    ),

                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,

                      minHeight: 22,
                    ),

                    hintText: 'Search tasks...',

                    hintStyle: TextStyle(color: Colors.grey.shade400),

                    border: InputBorder.none,
                  ),

                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

          actions: [
            if (!_isSearching && completedCount > 0)
              IconButton(
                icon: Icon(
                  Icons.cleaning_services_outlined,

                  color: Colors.grey.shade600,

                  size: 22,
                ),

                tooltip: 'Clear Completed ($completedCount)',

                onPressed: () => _confirmDelete(
                  title: 'Clear Completed Tasks',

                  message:
                      'Are you sure you want to remove all completed tasks?',

                  onConfirm: _clearCompleted,
                ),
              ),

            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,

                color: Colors.grey.shade600,

                size: 24,
              ),

              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;

                    _searchQuery = "";

                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),

            const SizedBox(width: 12),
          ],
        ),

        body: SafeArea(
          child: filteredTodos.isEmpty
              ? Center(
                  child: Text(
                    _isSearching ? 'No match found.' : 'All done for today.',

                    style: TextStyle(
                      color: Colors.grey.shade400,

                      fontSize: 15,

                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,

                    vertical: 16,
                  ),

                  itemCount: filteredTodos.length,

                  separatorBuilder: (context, index) => const Divider(
                    height: 1,

                    thickness: 1,

                    color: Color(0xFFF3F4F6),
                  ),

                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),

                      child: ListTile(
                        contentPadding: EdgeInsets.zero,

                        onTap: () => _toggleTodo(todo.id),

                        leading: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),

                          width: 22,

                          height: 22,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),

                            color: todo.isDone
                                ? const Color(0xFF111827)
                                : Colors.transparent,

                            border: Border.all(
                              color: todo.isDone
                                  ? const Color(0xFF111827)
                                  : Colors.grey.shade300,

                              width: 1.5,
                            ),
                          ),

                          child: todo.isDone
                              ? const Icon(
                                  Icons.check,

                                  size: 14,

                                  color: Colors.white,
                                )
                              : null,
                        ),

                        title: Text(
                          todo.title,

                          style: TextStyle(
                            fontSize: 16,

                            fontWeight: FontWeight.w400,

                            color: todo.isDone
                                ? Colors.grey.shade400
                                : const Color(0xFF111827),

                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,

                                color: Colors.grey.shade400,

                                size: 20,
                              ),

                              onPressed: () => _openEditDialog(todo),

                              splashRadius: 20,
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,

                                color: Colors.grey.shade400,

                                size: 20,
                              ),

                              onPressed: () => _confirmDelete(
                                title: 'Delete Task',

                                message:
                                    'Are you sure you want to delete this task?',

                                onConfirm: () => _deleteTodo(todo.id),
                              ),

                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _openAddDialog,

          backgroundColor: const Color(0xFF111827),

          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: const Icon(Icons.add, size: 26),
        ),
      ),
    );
  }
}
