import 'TodoState.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:async';

class TodoApi {
  static String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  static Future<List<Todo>> getTodos({int limit = 5}) async {
    var response = await http.get(TodoApi.baseUrl + '?_limit=${limit}');
    var jsonResponse = convert.jsonDecode(response.body);

    return (jsonResponse as List)
        .cast<Map<String, dynamic>>()
        .map<Todo>((json) => Todo.fromJson(json))
        .toList();
  }

  static Future<Todo> addTodo(Todo todo) async {
    var response =
        await http.post(TodoApi.baseUrl, body: convert.jsonEncode(todo));
    var jsonResponse = convert.jsonDecode(response.body);

    return Todo(
        id: (jsonResponse['id'] as int),
        title: todo.title,
        completed: todo.completed);
  }

  static Future<Todo> updateTodo(Todo todo) async {
    var response = await http.put(TodoApi.baseUrl + '/${todo.id}',
        body: convert.JsonCodec().encode(todo));
    //var jsonResponse = convert.jsonDecode(response.body);
    print(response.body);
    return todo;
  }

  static Future<Todo> removeTodo(Todo todo) async {
    await http.delete(TodoApi.baseUrl + '/${todo.id}');
    return todo;
  }
}
