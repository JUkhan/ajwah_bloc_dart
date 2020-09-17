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

**Consuming state in wigets**

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

You can make your app more declaretive simply dispatching the action, here you see an example of conditionaly rendering a widged having taps on two buttons [Show Widget] and [Hide Widget], and consuming those actions as you needed.

```dart
storeInstance()
  .actions
  .whereTypes(['show-widget', 'hide-widget'])
  .map((action) => action.type)
```

```dart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: () =>
                    store.dispatch(store.Action(type: 'show-widget')),
                child: Text("Show Widget"),
              ),
              RaisedButton(
                onPressed: () =>
                    store.dispatch(store.Action(type: 'hide-widget')),
                child: Text("Hide Widget"),
              ),
            ],
          ),
          StreamBuilder<String>(
            stream: storeInstance()
                .actions
                .whereTypes(['show-widget', 'hide-widget'])
                .map((action) => action.type),
            initialData: 'hide-widget',
            builder: (context, snapshot) {
              return snapshot.data == 'show-widget'
                  ? DynamicWidget()
                  : Container();
            },
          ),
```

Effects are optional. You can do everything of it's into `mapActionToState` callback function. As per your application is growing caught on difficult cases - it might be handy.

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
