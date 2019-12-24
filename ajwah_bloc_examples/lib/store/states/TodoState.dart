import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_examples/actionTypes.dart';
import 'package:ajwah_bloc_examples/todoApi.dart';

class Todo {
  final int id;
  final String title;
  bool completed;
  Todo({this.id, this.title, this.completed});
  factory Todo.fromJson(dynamic json) {
    return Todo(
        id: json['id'] as int,
        title: json['title'] as String,
        completed: json['completed'] as bool);
  }
  dynamic toJson() {
    return {'id': id, 'title': title, 'completed': completed};
  }
}

class TodoModel {
  String message;
  List<Todo> todoList = [];
  TodoModel({this.message, this.todoList});
  TodoModel copyWith({String message, List<Todo> todoList}) {
    return TodoModel(
        message: message ?? this.message, todoList: todoList ?? this.todoList);
  }
}

class TodoState extends BaseState<TodoModel> {
  TodoState()
      : super(name: 'todo', initialState: TodoModel(message: '', todoList: []));

  Stream<TodoModel> mapActionToState(TodoModel state, Action action) async* {
    try {
      switch (action.type) {
        case ActionTypes.LoadingTodos:
          yield state.copyWith(message: 'Loading todos.');
          state.todoList = await TodoApi.getTodos();
          yield state.copyWith(message: '');
          break;
        case ActionTypes.AddTodo:
          yield state.copyWith(message: 'Adding todo.');
          var todo = await TodoApi.addTodo(action.payload);
          state.todoList = List.from(state.todoList)..insert(0, todo);
          yield state.copyWith(message: '');
          break;
        case ActionTypes.UpdateTodo:
          yield state.copyWith(message: 'Updating todo.');
          await TodoApi.updateTodo(action.payload);
          state.todoList = List<Todo>.from(state.todoList);
          yield state.copyWith(message: '');
          break;
        case ActionTypes.RemoveTodo:
          yield state.copyWith(message: 'Removing todo.');
          var todo = await TodoApi.removeTodo(action.payload);
          state.todoList =
              state.todoList.where((it) => it.id != todo.id).toList();
          yield state.copyWith(message: '');
          break;
        default:
          yield state;
      }
    } catch (err) {
      yield state.copyWith(message: err.toString());
    }
  }
}
