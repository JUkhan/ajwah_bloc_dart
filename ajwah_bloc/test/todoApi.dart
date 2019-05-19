import 'TodoState.dart';
import 'dart:async';

class TodoApi {
  static String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  static Future<List<Todo>> getTodos({int limit = 5}) async {
    return [
      Todo(id: 201, title: 'todo.title', completed: false),
      Todo(id: 2011, title: 'todo.title', completed: false),
      Todo(id: 2012, title: 'todo.title', completed: false),
      Todo(id: 2013, title: 'todo.title', completed: false),
      Todo(id: 2014, title: 'todo.title', completed: false)
    ];
  }

  static Future<Todo> addTodo(Todo todo) async {
    return Todo(id: 201, title: todo.title, completed: todo.completed);
  }

  static Future<Todo> updateTodo(Todo todo) async {
    return todo;
  }

  static Future<Todo> removeTodo(Todo todo) async {
    return todo;
  }
}
