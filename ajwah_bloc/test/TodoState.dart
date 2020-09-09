import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'actionTypes.dart';

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

  Stream<TodoModel> mapActionToState(
      TodoModel state, Action action, Store store) async* {
    switch (action.type) {
      case ActionTypes.LoadingTodos:
        yield TodoModel(message: 'Loading todos.', todoList: []);
        break;
      case ActionTypes.TodosData:
        yield TodoModel(message: '', todoList: action.payload);
        break;
      case ActionTypes.AddTodo:
        yield TodoModel(message: 'Adding todo.', todoList: state.todoList);
        break;
      case ActionTypes.UpdateTodo:
        yield TodoModel(message: 'Updating todo.', todoList: state.todoList);
        break;
      case ActionTypes.RemoveTodo:
        yield TodoModel(message: 'Removing todo.', todoList: state.todoList);
        break;
      case ActionTypes.TodoError:
        yield TodoModel(message: action.payload, todoList: state.todoList);
        break;
      default:
        yield getState(store);
    }
  }
}
