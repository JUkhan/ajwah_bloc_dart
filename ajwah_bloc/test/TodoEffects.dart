import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'actionTypes.dart';
import 'TodoState.dart';
import 'package:rxdart/rxdart.dart';

import 'todoApi.dart';

class TodoEffects extends BaseEffect {
  effectForLoadTodos(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.LoadingTodos)
        .flatMap((action) => Stream.fromFuture(TodoApi.getTodos()))
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  effectForAddTodos(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.AddTodo)
        .flatMap((action) => Stream.fromFuture(TodoApi.addTodo(action.payload)))
        .withLatestFrom<TodoModel, List<Todo>>(
            store$.select('todo'), (a, b) => b.todoList..insert(0, a))
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  effectForUpdateTodos(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.UpdateTodo)
        .flatMap(
            (action) => Stream.fromFuture(TodoApi.updateTodo(action.payload)))
        .withLatestFrom<TodoModel, List<Todo>>(
            store$.select('todo'), (a, b) => b.todoList)
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  effectForRemoveTodos(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.RemoveTodo)
        .flatMap(
            (action) => Stream.fromFuture(TodoApi.removeTodo(action.payload)))
        .withLatestFrom<TodoModel, List<Todo>>(
            store$.select('todo'), (todo, b) => b.todoList..remove(todo))
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  List<Stream<Action>> registerEffects(Actions action$, Store store$) {
    return [
      effectForLoadTodos(action$, store$),
      effectForAddTodos(action$, store$),
      effectForUpdateTodos(action$, store$),
      effectForRemoveTodos(action$, store$)
    ];
  }
}
