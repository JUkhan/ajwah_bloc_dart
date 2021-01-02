# ajwah_bloc

A reactive state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow. **[flutter demo](https://api.flutlab.io/res/projects/67131/rr2ma95pubmjmokpmlmi/index.html#/) | [src](https://github.com/JUkhan/ajwahapp.git)**

- **[ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)**

## Declare a state controller.

```dart
class CounterStateController extends StateController<int> {
  CounterStateController() : super(stateName: 'counter', initialState: 2);

  void increment() {
    update((state) => state + 1);
  }

  void decrement() {
    update((state) => state - 1);
  }
}

```

## consuming state

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
          RaisedButton(
            child: Text('inc'),
            onPressed: controller.increment,
          ),
          RaisedButton(
            child: Text('dec'),
            onPressed: controller.decrement,
          ),
          StreamBuilder(
            stream: controller.stream$,
            initialData: 0,
            builder: (context, snapshot) {
              return Container(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(snapshot.data.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}

```

**Testing:** We need to add the testing dependency `ajwah_bloc_test`

**Testing counter state**

```dart

void main() {
  CounterStateController controller;
  setUp(() {
    controller = CounterStateController();
  });

  tearDown(() {});

  ajwahTest<int>(
    'Initial state value should be 2',
    build: () => controller.stream$,
    expect: [isA<int>()],
    verify: (state) {
      expect(2, state[0]);
    },
  );

  ajwahTest<int>(
    'increment',
    build: () => controller.stream$,
    act: () => controller.increment(),
    expect: [isA<int>()],
    verify: (state) {
      expect(3, state[0]);
    },
  );

  ajwahTest<int>(
    'decrement',
    build: () => controller.stream$,
    act: () => controller.decrement(),
    expect: [isA<int>()],
    verify: (state) {
      expect(1, state[0]);
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
void registerEffects(String effectKey, Iterable<EffectCallback> callbackList)
void unregisterEffects({@required String effectKey})
Actions get actions
T getState<T>({@required String stateName})
Stream<List<dynamic>> exportState()
void importState(Map<String, dynamic> state)
void dispose()
```
