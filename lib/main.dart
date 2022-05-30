import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ToDo());

class ToDo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainUI());
  }
}

class MainUI extends StatefulWidget {
  @override
  _ToDoState createState() => _ToDoState();
}

class _ToDoState extends State<MainUI> {
  // save data
  final List<String> _toDoList = <String>[];

  // text field
  final TextEditingController _createTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getStoredData("todo_storage");
  }

  @override
  Widget build(BuildContext context) {
    // app layout
    return Scaffold(
      appBar: AppBar(title: const Text('To Do')),
      // body: ListView(children: _getToDoTasks()),
      body: bodyContent(),
      // add items to the to-do list
      floatingActionButton: FloatingActionButton(
          onPressed: () => _popCreateTaskDialog(context),
          tooltip: 'Add Item',
          child: const Icon(Icons.add)),
    );
  }

  Widget bodyContent() {
    return ListView.builder(
        itemCount: _toDoList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_toDoList[index]),
              onTap: () => _popDeleteTaskDialog(context, index),
            ),
          );
        });
  }

  // display a dialog for the user to enter items
  Future<void> _popCreateTaskDialog(BuildContext context) async {
    // alter the app state to show a dialog
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add a task to your list'),
            content: TextField(
              controller: _createTaskController,
              decoration: const InputDecoration(hintText: 'Enter task here'),
            ),
            actions: <Widget>[
              // add button
              TextButton(
                child: const Text('ADD'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _addItem(_createTaskController.text);
                  SnackBar snackBar = const SnackBar(content: Text("Task added"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              // Cancel button
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  // display a dialog for the user to delete items
  Future<void> _popDeleteTaskDialog(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Delete a task'),
            content: const Text('Are you sure to delete the task?'),
            actions: <Widget>[
              // add button
              TextButton(
                child: const Text('DELETE'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteItem(index);
                  SnackBar snackBar = const SnackBar(content: Text("Task deleted"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              // Cancel button
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _addItem(String title) {
    setState(() {
      _toDoList.add(title);
    });
    writeToStorage(_toDoList);
    _createTaskController.clear();
  }

  void _deleteItem(int index) {
    setState(() {
      _toDoList.removeAt(index);
    });
    writeToStorage(_toDoList);
  }

  void getStoredData(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _toDoList.addAll(pref.getStringList(key) ?? List.empty());
    });
  }

  Future<void> writeToStorage(List<String> s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todo_storage', s);
  }
}
