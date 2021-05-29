# ajwah_bloc

A dart package that helps implement the BLoC pattern. Every `StateController` has the following features:

- Dispatching actions
- Filtering actions
- Adding effects
- Communications among Controllers
- RxDart full features

Please go through the [example](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_bloc/example) . The example contains `counter` and `todos` pages those demonstrate all the features out of the box.

`CounterState`

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:example/widgets/StreamConsumer.dart';
import 'package:rxdart/rxdart.dart';

class CounterState extends StateController<int> {
  CounterState() : super(0);

  @override
  void onInit() {
    mapActionToState([
      action$
          .whereType('asyncInc')
          .delay(const Duration(seconds: 1))
          .map((event) => state + 1),
    ]);
  }

  void inc() => emit(state + 1);

  void dec() => emit(state - 1);

  Stream<SCResponse> get count$ => Rx.merge([
        action$.whereType('asyncInc').mapTo(SCLoading()),
        stream$.map((data) => data > 10
            ? SCError('Counter is out of the range.')
            : SCData('$data')),
      ]);
}

```

`ToodoState`

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../api/todoApi.dart';
import './searchCategory.dart';

class TodoState extends StateController<List<Todo>> {
  TodoState() : super([]);

  @override
  void onInit() {
    loadTodos();
    /**
     * Effect for todo search input. For each key strokes AddTodo widget dispatching
     * SearchInputAction. But effect throttles it for 320 mills to collect the subsequent
     * actions and then finally dispatching SearchTodoAction.
     */
    registerEffects([
      action$
          .isA<SearchInputAction>()
          .debounceTime(const Duration(milliseconds: 320))
          .map((action) => SearchTodoAction(action.searchText))
    ]);
  }

  void loadTodos() {
    getTodos().listen((todos) {
      emit(todos);
    });
  }

  void add(String description) {
    addTodo(Todo(description: description))
        .listen((todo) => emit([...state, todo]));
  }

  void update(Todo todo) {
    updateTodo(todo).listen(
        (todo) => emit([
              for (var item in state)
                if (item.id == todo.id) todo else item,
            ]), onError: (error) {
      dispatch(TodoErrorAction(error));
    });
  }

  void remove(Todo todo) {
    removeTodo(todo).listen(
        (todo) => emit(state.where((item) => item.id != todo.id).toList()));
  }

  Stream<String> get activeTodosInfo$ => stream$
      .map((todos) => todos.where((todo) => !todo.completed).toList())
      .map((todos) => '${todos.length} items left');

  ///combining multiplle controllers(TodoState, SearchCategoryState)
  ///with SearchTodoAction and returns single todos stream.
  Stream<List<Todo>> get todo$ =>
      Rx.combineLatest3<List<Todo>, SearchCategory, String, List<Todo>>(
          stream$,
          remoteStream<SearchCategoryState, SearchCategory>(),
          action$
              .isA<SearchTodoAction>()
              .map<String>((action) => action.searchText)
              .doOnData((event) {
            print('searchText: ' + event);
          }).startWith(''), (todos, category, searchText) {
        if (searchText.isNotEmpty)
          todos = todos
              .where((todo) => todo.description
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
              .toList();
        switch (category) {
          case SearchCategory.Active:
            return todos.where((todo) => !todo.completed).toList();
          case SearchCategory.Completed:
            return todos.where((todo) => todo.completed).toList();
          default:
            return todos;
        }
      });
}

class TodoErrorAction extends Action {
  final dynamic error;
  TodoErrorAction(this.error);
}

class SearchTodoAction extends Action {
  final String searchText;
  SearchTodoAction(this.searchText);
}

class SearchInputAction extends Action {
  final String searchText;
  SearchInputAction(this.searchText);
}

```

`SearchCategoryState`

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';

enum SearchCategory { All, Active, Completed }

class SearchCategoryState extends StateController<SearchCategory> {
  SearchCategoryState() : super(SearchCategory.All);

  void setCategory(SearchCategory category) => emit(category);
}

```

### Consuming State

```dart

final controller = CounterStateController();

class CounterWidget extends StatelessWidget {
  const CounterWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text('inc'),
            onPressed: controller.inc,
          ),
          ElevatedButton(
            child: Text('dec'),
            onPressed: controller.dec,
          ),
          ElevatedButton(
            child: Text('async(+)'),
            onPressed: controller.asyncInc,
          ),
          StreamBuilder(
            stream: controller.count$,
            initialData: '',
            builder: (context, snapshot) =>Text(snapshot.data)
          ),
        ],
      ),
    );
  }
}

```

### Testing

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**

```dart

void main() {
  CounterStateController? controller;
  setUp(() {
    controller = CounterStateController();
  });

  tearDown(() {
    controller?.dispose();
  });

  ajwahTest<int>(
    'Initial state',
    build: () => controller!.stream$,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], 0);
    },
  );

  ajwahTest<int>(
    'increment',
    build: () => controller!.stream$,
    act: () => controller?.increment(),
    skip: 1,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], 1);
    },
  );

  ajwahTest<int>(
    'decrement',
    build: () => controller!.stream$,
    act: () => controller?.decrement(),
    skip: 1,
    expect: [isA<int>()],
    verify: (state) {
      expect(state[0], -1);
    },
  );
}

```

### Api

```dart

  Actions get action$
  void dispatch(Action action)
  void onAction(Action action)
  void onInit()
  S get state
  Stream<S> get stream$
  Stream<T> select<T>(T Function(S state) mapCallback)
  void emit(S newState)
  void registerEffects(Iterable<Stream<Action>> callbackList)
  void importState(S state)
  Stream<Controller> remoteController<Controller>()
  Future<State> remoteState<Controller, State>()
  Stream<S> remoteStream<Controller, S>()
  void mapActionToState(Iterable<Stream<S>> callbackList)
  void dispose()
```
