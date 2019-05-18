import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

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
  final String message;
  final List<Todo> todoList;
  TodoModel({this.message, this.todoList});
}

class TodoState extends BaseState<TodoModel> {
  TodoState()
      : super(name: 'todo', initialState: TodoModel(message: '', todoList: []));

  TodoModel reduce(TodoModel state, Action action) {
    switch (action.type) {
      case ActionTypes.LoadingTodos:
        return TodoModel(message: 'Loading todos.', todoList: []);
      case ActionTypes.TodosData:
        return TodoModel(message: '', todoList: action.payload);
      case ActionTypes.AddTodo:
        return TodoModel(message: 'Adding todo.', todoList: state.todoList);
      case ActionTypes.UpdateTodo:
        return TodoModel(message: 'Updating todo.', todoList: state.todoList);
      case ActionTypes.RemoveTodo:
        return TodoModel(message: 'Removing todo.', todoList: state.todoList);
      case ActionTypes.TodoError:
        return TodoModel(message: action.payload, todoList: state.todoList);
      default:
        return state;
    }
  }
}
