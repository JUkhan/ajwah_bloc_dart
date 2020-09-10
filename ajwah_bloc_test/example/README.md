**Here is the [git hub](https://github.com/JUkhan/flutter_test_project) repo to run on your locals!**

## ActionTypes.dart

```dart

abstract class ActionTypes {
  static const ChangeTheme = "change_theme";
  static const FetchTodo = "FetchTodo";
  static const FetchTodos = "FetchTodos";
  static const SaveTodo = "SaveTodo";
  static const UpdateTodo = "UpdateTodo";
}


```

## AsyncData.dart

```dart

enum AsyncStatus { Loading, Loaded, Error }

class AsyncData<T> {
  final T data;
  final AsyncStatus asyncStatus;
  final String error;
  AsyncData({this.data, this.asyncStatus, this.error});

  AsyncData.loaded(T data)
      : this(
          data: data,
          asyncStatus: AsyncStatus.Loaded,
          error: null,
        );

  AsyncData.error(String message)
      : this(
          data: null,
          asyncStatus: AsyncStatus.Error,
          error: message,
        );
  AsyncData.loading()
      : this(
          data: null,
          asyncStatus: AsyncStatus.Loading,
          error: null,
        );
}

String baseUrl = "https://jsonplaceholder.typicode.com/";
```

## Todo.dart

```dart
class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;
  Todo({this.userId, this.id, this.title, this.completed});
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'title': title, 'completed': completed};
  }
}

```

## TodoApi.dart

```dart
import 'package:flutter_test_project/models/Todo.dart';
import 'package:flutter_test_project/utils/AsyncData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoApi {
  http.Client client;

  TodoApi() {
    client = http.Client();
  }
  TodoApi.withMocks({this.client});

  Future<Todo> fetchTodo(String path) {
    return client
        .get(baseUrl + path)
        .then((response) => json.decode(response.body))
        .then((jsond) => Todo.fromJson(jsond));
  }

  Future<List<Todo>> fetchTodos(String path) {
    return client
        .get(baseUrl + path)
        .then((response) => json.decode(response.body) as List<dynamic>)
        .then((data) => data.map((e) => Todo.fromJson(e)).toList());
  }

  Future<Todo> saveTodo(String path, Todo todo) {
    return client
        .post(
          baseUrl + path,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(todo),
        )
        .then((response) => json.decode(response.body))
        .then((json) => Todo.fromJson(json));
  }

  Future<Todo> updateTodo(String path, Todo todo) {
    return client
        .put(
          baseUrl + path,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(todo),
        )
        .then((response) => json.decode(response.body))
        .then((json) => Todo.fromJson(json));
  }
}


```

## TodoState.dart

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter_test_project/models/Todo.dart';
import 'package:flutter_test_project/services/todoApi.dart';
import 'package:flutter_test_project/utils/ActionTypes.dart';
import 'package:flutter_test_project/utils/AsyncData.dart';
import 'package:get_it/get_it.dart';

class TodoModel {
  final AsyncData<Todo> todo;
  final AsyncData<List<Todo>> todos;

  TodoModel({
    this.todo,
    this.todos,
  });

  TodoModel copyWith({
    AsyncData<Todo> todo,
    AsyncData<List<Todo>> todos,
  }) {
    return TodoModel(
      todo: todo ?? this.todo,
      todos: todos ?? this.todos,
    );
  }

  TodoModel.init()
      : this(todo: AsyncData.loading(), todos: AsyncData.loading());
}

class TodoState extends BaseState<TodoModel> {
  TodoState() : super(name: "todo", initialState: TodoModel.init());
  var api = GetIt.I<TodoApi>();
  @override
  Stream<TodoModel> mapActionToState(TodoModel state, Action action, Store store) async* {
    switch (action.type) {
      case ActionTypes.FetchTodo:
        yield state.copyWith(todo: AsyncData.loading());
        try {
          var data = await api.fetchTodo('todos/2');
          yield state.copyWith(todo: AsyncData.loaded(data));
        } catch (ex) {
          yield state.copyWith(todo: AsyncData.error(ex.toString()));
        }
        break;
      default:
        yield getState(store);
    }
  }
}


```

## todo_test.dart

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test_project/services/todoApi.dart';
import 'package:flutter_test_project/store/TodoState.dart';
import 'package:flutter_test_project/utils/ActionTypes.dart';
import 'package:flutter_test_project/utils/AsyncData.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  Store store;
  MockClient client;
  setUpAll(() {
    client = MockClient();
    GetIt.I.registerSingleton<TodoApi>(TodoApi.withMocks(client: client));
    store = createStore(states: [TodoState()]);
  });
  tearDownAll(() {
    store.dispose();
  });
  ajwahTest<TodoModel>(
      "emits a loading state then result state when api call succeeds",
      build: () {
        when(client.get(baseUrl + 'todos/2')).thenAnswer((_) async =>
            http.Response(
                '{"id":2,"userId":1,"title":"learn ajwah_bloc","completed":false}',
                202));

        return store.select("todo");
      },
      skip: 1,
      log: (arr) {
        print(arr[1].todo.data.title);
      },
      act: () => store.dispatch(ActionTypes.FetchTodo),
      expect: [isA<TodoModel>(), isA<TodoModel>()],
      verify: (arr) {
        expect(arr[0].todo.asyncStatus, AsyncStatus.Loading);
        expect(arr[1].todo.asyncStatus, AsyncStatus.Loaded);
        expect(arr[1].todo.data.title, "learn ajwah_bloc");
      });
}

```
