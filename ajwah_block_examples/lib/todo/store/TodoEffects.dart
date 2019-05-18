import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/todo/store/TodoState.dart';
import 'package:rxdart/rxdart.dart';

import '../todoApi.dart';

class TodoEffects extends BaseEffect {
  effectForLoadTodos(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.LoadingTodos)
        .flatMap((action) => Observable.fromFuture(TodoApi.getTodos()))
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  effectForAddTodos(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.AddTodo)
        .flatMap(
            (action) => Observable.fromFuture(TodoApi.addTodo(action.payload)))
        .withLatestFrom<TodoModel, List<Todo>>(store$.select(stateName: 'todo'),
            (a, b) => b.todoList..insert(0, a))
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  effectForUpdateTodos(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.UpdateTodo)
        .flatMap((action) =>
            Observable.fromFuture(TodoApi.updateTodo(action.payload)))
        .withLatestFrom<TodoModel, List<Todo>>(
            store$.select(stateName: 'todo'), (a, b) => b.todoList)
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  effectForRemoveTodos(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.RemoveTodo)
        .flatMap((action) =>
            Observable.fromFuture(TodoApi.removeTodo(action.payload)))
        .withLatestFrom<TodoModel, List<Todo>>(store$.select(stateName: 'todo'),
            (todo, b) => b.todoList..remove(todo))
        .map((data) => Action(type: ActionTypes.TodosData, payload: data))
        .doOnError((error, stacktrace) => store$.dispatch(
            Action(type: ActionTypes.TodoError, payload: error.toString())));
  }

  List<Observable<Action>> registerEffects(Actions action$, Store store$) {
    return [
      effectForLoadTodos(action$, store$),
      effectForAddTodos(action$, store$),
      effectForUpdateTodos(action$, store$),
      effectForRemoveTodos(action$, store$)
    ];
  }
}
