# ajwah_bloc

Rx based state management library. Manage your application's states, effects, and actions easy way.
Make apps more scalable with a unidirectional data-flow.

**Learn more about testing `ajwah_bloc` with [ajwah_bloc_test](https://pub.dev/packages/ajwah_bloc_test)!**

**States**

Every state class must derived from `StateBase<T>` class. The `StateBase<T>` class has an abstract function `mapActionToState(T state, Action action, Store store)`. This method should be invoked whenever any `action` dispatched to the store. You should return a new state based on the `action`. Keep in mind that if you mutate the state, it does not notify (it's listeners) the widget/s for rerendering.

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

**Using state in components**

Declare your store as a global variable or enable `exposeApiGlobally:true`.

```dart
var store = createStore(states:[CounterState()]);
```

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

**Action Dispatching**

```dart
dispatch(Action(type:'Inc'));
```

## Effects

Every effect class must derived from `EffectBase` class. And it is optional to pass the
`effectKey`. But it's mandatory if you want conditionally remove the effects by using
`removeEffectsByKey('effectKey')`. The `EffectBase` class has an abstract method `registerEffects(Actions action$, Store store$)`. Please keep in mind that effects should not work until you register them.

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
