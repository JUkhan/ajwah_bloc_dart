# ajwah_bloc

Rx based state management library. Manage your application's states, effects, and actions easy way.

**Learn more about testing `ajwah_bloc` with [ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)!**

## States

Every state class must derived from `BaseState<T>` class. And it is mandatory to pass the
state `name` and `initialState`. The `BaseState<T>` class has an abstract method `Stream<T> mapActionToState(T state, Action action);`. This method should be invoked by sysytem passing current state and action. You should mutate the state based on action.

#### Example CounterState

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 10, isLoading: false);
  CounterModel copyWith({int count, bool isLoading}) => CounterModel(
      count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, Action action, Store store) async* {
    switch (action.type) {
      case ActionTypes.Inc:
        yield state.copyWith(count: state.count + 1, isLoading: false);
        break;
      case ActionTypes.Dec:
        yield state.copyWith(count: state.count - 1, isLoading: false);
        break;
      case ActionTypes.AsyncInc:
        yield state.copyWith(isLoading: true);
        yield await getCount(state.count);
        break;
      default:
        yield getState(store);
    }
  }

  Future<CounterModel> getCount(int count) {
    return Future.delayed(Duration(milliseconds: 500),
        () => CounterModel(count: count + 1, isLoading: false));
  }
}

```

## Using state in components

Ajwah provides a comfortable way to use states in components and dispatching actions.

Just call the `createStore(states:[], /*effects:[] optional*/)` method and there you go.

We can use `select` method to get `state` data (passing state name): `select('counter')`. or `select2(...)`.
These methods return `Stream<T>`. Now pass this Stream inside a StreamBuilder to make a reactive widget.

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

Also for dispatching state's action - we can use `dispatch(...)`

## Effects (optional)

Every effect class must derived from `BaseEffect` class. And it is optional to pass the
`effectKey`. But it's mandatory if you want conditionally remove the effects by using
`store.removeEffectsByKey('effectKey')`. The `BaseEffect` class has one abstract method `List<Stream<Action>> registerEffects(Actions action$, Store store$);`. This function should be invoked by system passing reference of Actions and Store classes. Please keep in mind that effects should not work until you register them.

#### Example

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../actionTypes.dart';

class CounterEffect extends BaseEffect {
  Stream<Action> effectForAsyncInc(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.AsyncInc)
        .debounceTime(Duration(milliseconds: 500))
        .mapTo(Action(type: ActionTypes.Inc));
  }

  List<Stream<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForAsyncInc(action$, store$)];
  }
}

```

### Api

```dart
dispatch(String actionType, [dynamic payload])
Stream<T> select<T>(String stateName)
Stream<T> selectMany<T>(T callback(Map<String, dynamic> state))
addState(BaseState stateInstance)
removeStateByStateName(String stateName)
addEffects(BaseEffect effectInstance)
removeEffectsByKey(String effectKey)
Stream<List<dynamic>> exportState()
importState(Map<String, dynamic> state)
addEffect(EffectCallback callback, {String effectKey})

```
