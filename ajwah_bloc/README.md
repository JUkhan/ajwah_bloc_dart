# ajwah_bloc
Rx based state management library. Manage your application's states, effects, and actions easy way.

## States
Every state class must derived from `BaseState<T>` class. And it is mandatory to pass the
state `name` and `initialState`. The `BaseState<T>` class has an abstract method `Stream<T> mapActionToState(T state, Action action);`. This method should be invoked by sysytem passing current state and action. You should mutate the state based on action.

#### Example CounterState
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  int count;
  bool isLoading;

  CounterModel({this.count, this.isLoading});

  copyWith({int count, bool isLoading}) {
    return CounterModel(
        count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  }

  CounterModel.init() : this(count: 10, isLoading: false);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, Action action) async* {
    switch (action.type) {
      case ActionTypes.Inc:
        state.count++;
        yield state.copyWith(isLoading: false);
        break;
      case ActionTypes.Dec:
        state.count--;
        yield state.copyWith(isLoading: false);
        break;
      case ActionTypes.AsyncInc:
        yield state.copyWith(isLoading: true);
        yield await getCount(state.count);
        break;
      default:
        yield state;
    }
  }

  Future<CounterModel> getCount(int count) {
    return Future.delayed(Duration(milliseconds: 500),
        () => CounterModel(count: count + 1, isLoading: false));
  }
}

```
#### Example TodoState
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/todoApi.dart';

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

```

## Effects
Every effect class must derived from `BaseEffect` class. And it is optional to pass the
`effectKey`. But it's mandatory if you want conditionally remove the effects by using
`store.removeEffectsByKey('effectKey')`. The `BaseEffect` class has one abstract method `List<Observable<Action>> registerEffects(Actions action$, Store store$);`. This function should be invoked by system passing reference of Actions and Store classes. Please keep in mind that effects should not work until you register them.

#### Example
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../actionTypes.dart';

class CounterEffect extends BaseEffect {
  Observable<Action> effectForAsyncInc(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.AsyncInc)
        .debounceTime(Duration(milliseconds: 500))
        .mapTo(Action(type: ActionTypes.Inc));
  }

  List<Observable<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForAsyncInc(action$, store$)];
  }
}

```


## Using state in components
Ajwah provides a comfortable way to use states in components and dispatching actions.

Just call the `createStore(states:[], effects:[])` method from `main()` function. Now `store` instance should be available by the helper function `store()` throughout the application.

Note:  `createStore(...)` method return store instance so that you can make a sate provider class(InheritedWidget) as your convenient.

We can use `select` method to get `state` data (passing state name): `select('counter')`. or `select2(...)`.
These methods return `Observable<T>`. Now pass this Observable inside a StreamBuilder to make a reactive widget.

### Example

```dart
StreamBuilder<CounterModel>(
    stream: select<CounterModel>('counter'),
    builder:(BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
        if (snapshot.data.isLoading) {
          return CircularProgressIndicator();
        }
        return Text(
            snapshot.data.count.toString(),
            style: Theme.of(context).textTheme.title,
          );
    },
)        
```

And also for dispatching state's action - we can use `dispatch(...)` or `store().dispatch(Action(type:'any', payload:any))` method.



[Please have a look at here for progressive examples](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_block_examples)
