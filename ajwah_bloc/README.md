# ajwah_bloc

Rx based state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow.

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**

Declare your store as a global variable or enable `exposeApiGlobally:true`.

```dart
final store = createStore();
//or
createStore( exposeApiGlobally:true);
```

Now register states as much as you want and consume them where ever you want in your app.

```dart
final store = createStore();

store.registerState<int>(
  stateName: 'counter',
  initialState: 0,
  mapActionToState: (state, action, emit) {
    if (action.type == 'inc') emit(state + 1);
  },
);

store.select('counter').listen((state) => print(state)); // 0, 1
store.dispatch(Action(type: 'inc'));
```

**Using state in wigets**

```dart
StreamBuilder<CounterModel>(
    stream: select<CounterModel>('counter'),
    builder:(context, snapshot) {
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

## Effects

```dart
 store.registerEffect(
      (action$, store$) => action$
          .whereType('asyncInc')
          .debounceTime(Duration(milliseconds: 500))
          .map((event) => store.Action(type: 'inc')),
      effectKey: 'effect-key',
    );

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
