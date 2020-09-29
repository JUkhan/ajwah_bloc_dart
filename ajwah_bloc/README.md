# ajwah_bloc

A reactive state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow. **[flutter demo](https://api.flutlab.io/res/projects/31087/itbjnv5f4wrwwd0uahuc/index.html#/) | [src](https://github.com/JUkhan/ajwahapp.git)**

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**

Declare your store as a global variable or enable `exposeApiGlobally:true`.

```dart
final store = createStore();
//or
createStore( exposeApiGlobally:true);
```

Now register states as much as you want and consume them where ever you want in your app.

```dart
//register [counter] state
store.registerState<int>(
    stateName: 'counter',
    initialState: 0,
    mapActionToState: (state, action, emit) {
      switch (action.type) {
        case 'inc':
          emit(state + 1);
          break;
        case 'dec':
          emit(state - 1);
          break;
        default:
      }
    },
  );

  //consuming
  store.select('counter').listen(print); // 0,1,0,1

  //dispatching actions
  store.dispatch(Action(type: 'inc'));
  store.dispatch(Action(type: 'dec'));
  store.dispatch(Action(type: 'inc'));
```

You can easily filter out actions using the optional `filterActions:(action)=>bool` param of `registerState` method.

For filtering out the `dec` action from the `counter` state:

```dart
//register [counter] state
store.registerState<int>(
    stateName: 'counter',
    initialState: 0,
    filterActions: (action) => action.type != 'dec',
    mapActionToState: (state, action, emit) {
      switch (action.type) {
        case 'inc':
          emit(state + 1);
          break;
        case 'dec':
          emit(state - 1);
          break;
        default:
      }
    },
  );

  //consuming
  store.select('counter').listen(print); // 0,1,2

  //dispatching actions
  store.dispatch(Action(type: 'inc'));
  store.dispatch(Action(type: 'dec'));
  store.dispatch(Action(type: 'inc'));

```

Now `dec` action is useless. Let's add an `effect` on `dec` action:

```dart
store.registerEffect(
      (action$, store) =>
          action$.whereType('dec')
          .map((event) => Action(type: 'inc')),
      effectKey: 'test');

```

Here we are capturing the `dec` action using `whereType` and then map the action as `inc` action

```dart
//register [counter] state
store.registerState<int>(
    stateName: 'counter',
    initialState: 0,
    filterActions: (action) => action.type != 'dec',
    mapActionToState: (state, action, emit) {
      switch (action.type) {
        case 'inc':
          emit(state + 1);
          break;
        case 'dec':
          emit(state - 1);
          break;
        default:
      }
    },
  );

  //consuming
  store.select('counter').listen(print); // 0,1,2,3

  //effect on dec action - so that it works as inc
  store.registerEffect(
      (action$, store) =>
          action$.whereType('dec').map((event) => Action(type: 'inc')),
      effectKey: 'test');

  //dispatching actions
  store.dispatch(Action(type: 'inc'));
  store.dispatch(Action(type: 'dec'));
  store.dispatch(Action(type: 'inc'));

```

If you want to log all the action and state changed - just use the `exportState()` function. Call this function just after your `createStore()` function.

```dart
var store = createStore();
store.exportState().listen(print);
```

output looks like:

```sh
[Action(type: @@INIT), {counter: 0}]
[Action(type: registerState(counter)), {counter: 0}]
0
[Action(type: registerEffect(test)), {counter: 0}]
[Action(type: inc), {counter: 1}]
1
[Action(type: dec), {counter: 1}]
[Action(type: inc), {counter: 2}]
2
[Action(type: inc), {counter: 3}]
3
```

You can import state also:

```dart
store.importState({'counter': 100});
```

We have covered the basic of ajwah_bloc. Now we see:

- how to consume states in the flutter widget.
- how to make your app a way more declaratives.
- how to combine multiple states and make a single stream.
- testing ajwah_bloc

Consuming `counter` state through `StreamBuilder` widget:

```dart
StreamBuilder<int>(
    stream: store.select('counter'),
    initialData: 0,
    builder:(context, snapshot) => Text(snapshot.data.count.toString()),
),
Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
        RaisedButton(
            onPressed: () => store.dispatch(store.Action(type: 'inc')),
            child: Text('Inc'),
        ),
        RaisedButton(
            onPressed: () => sstore.dispatch(store.Action(type: 'dec')),
            child: Text('Dec'),
        ),
    ],
),
```

Make your app a way more declaretives simply dispatching the action, here you see an example of conditionaly rendering a widged having taps on two buttons [Show] and [Hide], and consuming those actions as you needed.

```dart
Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
        RaisedButton(
            onPressed: () => store.dispatch(store.Action(type: 'show-widget')),
            child: Text('Show'),
        ),
        RaisedButton(
            onPressed: () => sstore.dispatch(store.Action(type: 'hide-whiget')),
            child: Text('Hide'),
        ),
    ],
),
StreamBuilder<String>(
    stream: store.actions
            .whereTypes(['show-widget', 'hide-widget'])
            .map((action) => action.type),
    initialData: '',
    builder:(context, snapshot) =>
      snapshot.data == 'show-widget' ? DynamicWidget() : Container(),
),
```

Now we declare two states:

- `todo`
- `search-category`

And then consume them combining as a single stream. So that we get the latest filtered result on `todo` as well as `search-category` states.

```dart
class Todo {
  Todo({
    this.description,
    this.completed = false,
    this.id,
  });

  final String id;
  final String description;
  final bool completed;

}
class TodoAction extends Action {
  String description;
  String id;
  TodoAction({
    @required String type,
    this.id,
    this.description,
  }) : super(type: type);
}

class TodoFilterAction extends Action {
  TodoFilterAction({@required String type}) : super(type: type);
}

abstract class TodoActionTypes {
  static const all = 'todo-all';
  static const active = 'todo-active';
  static const completed = 'todo-completed';
  static const add = 'todo-add';
  static const update = 'todo-update';
  static const toggle = 'todo-toggle';
  static const remove = 'todo-remove';
}
//register [todo] state
store.registerState<List<Todo>>(
    stateName: 'todo',
    initialState: [
        Todo(id: 'todo-0', description: 'hi'),
        Todo(id: 'todo-1', description: 'hello'),
        Todo(id: 'todo-2', description: 'learn reactive programming'),
      ],
    mapActionToState: (state, action, emit) {
        if (action is TodoAction) {
            switch (action.type) {
            case TodoActionTypes.add:
                emit([
                ...state,
                Todo(description: action.description)
                ]);
                break;
            case TodoActionTypes.update:
                emit([
                for (var item in state)
                    if (item.id == action.id)
                    Todo(
                        id: item.id,
                        completed: item.completed,
                        description: action.description)
                    else
                    item,
                ]);
                break;
            case TodoActionTypes.toggle:
                emit([
                for (var item in state)
                    if (item.id == action.id)
                    Todo(
                        id: item.id,
                        completed: !item.completed,
                        description: item.description)
                    else
                    item,
                ]);
                break;
            case TodoActionTypes.remove:
                emit(state
                        .where((item) => item.id != action.id)
                        .toList());
                break;
            }
        }
    },
  );

//register [search-category] state
store.registerState<String>(
    stateName: 'search-category',
    initialState: TodoActionTypes.all,
    mapActionToState: (state, action, emit) {
        if (action is TodoFilterAction) {
          emit(action.type);
        }
    },
  );

```

**Combining two states**

- do not forget - `import 'package:rxdart/rxdart.dart';`

```dart
Stream<List<Todo>> getFilteredTodos() => CombineLatestStream([
      select('search-category'),
      select('todo'),
    ], (values) {
      final todos = values[1] as List<Todo>;
      switch (values[0]) {
        case TodoActionTypes.active:
          return todos.where((todo) => !todo.completed).toList();
        case TodoActionTypes.completed:
          return todos.where((todo) => todo.completed).toList();
        default:
          return todos;
      }
    });
```

**Testing:** We need to add the testing dependency `ajwah_bloc_test` then here you go:

**todo_test.dart**

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  AjwahStore store;
  setUp(() {
    store = createStore(exposeApiGlobally: true);
    registerTodoStates();
  });
  tearDown(() {
    store.dispose();
  });
  ajwahTest<List<Todo>>(
    'Render the default todos',
    build: () => getFilteredTodos(),
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect(3, models[0].length);
    },
  );
  ajwahTest<List<Todo>>(
    'Editing the todo on done',
    build: () => getFilteredTodos(),
    act: () =>
        store.dispatch(TodoAction(type: TodoActionTypes.toggle, id: 'todo-0')),
    skip: 1,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect(true, models[0][0].completed);
    },
  );
  ajwahTest<List<Todo>>(
    'Add new todo',
    build: () => getFilteredTodos(),
    act: () => store.dispatch(
        TodoAction(type: TodoActionTypes.add, description: 'new todo')),
    skip: 1,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect('new todo', models[0][3].description);
    },
  );
  ajwahTest<List<Todo>>(
    'removing the first todo',
    build: () => getFilteredTodos(),
    act: () =>
        store.dispatch(TodoAction(type: TodoActionTypes.remove, id: 'todo-0')),
    skip: 1,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect('todo-1,todo-2', models[0].map((e) => e.id).join(','));
    },
  );

  ajwahTest<List<Todo>>(
    'show only uncomplete todos',
    build: () => getFilteredTodos(),
    act: () {
      store.dispatch(TodoAction(type: TodoActionTypes.toggle, id: 'todo-0'));
      store.dispatch(TodoFilterAction(type: TodoActionTypes.active));
    },
    skip: 2,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect(2, models[0].length);
    },
  );
}

```

### Api

```dart
dispatch(Action action)
Stream<T> select<T>(String stateName)
Stream<T> selectMany<T>(T callback(Map<String, dynamic> state))
void registerState<S>(
      {@required String stateName,
      @required S initialState,
      @required MapActionToStateCallback<S> mapActionToState})
void unregisterState({@required String stateName})
void registerEffect(EffectCallback callback, {@required String effectKey})
void unregisterEffect({@required String effectKey})
BehaviorSubject<Action> get dispatcher
Actions get actions
T getState<T>({@required String stateName})
Stream<List<dynamic>> exportState()
void importState(Map<String, dynamic> state)
void dispose()
```
