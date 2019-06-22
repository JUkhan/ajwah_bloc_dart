# ajwah_bloc
Rx based state management library. Manage your application's states, effects, and actions easy way.

## States
Every state class must derived from `BaseState<T>` class. And it is mandatory to pass the
state `name` and `initialState`. The `BaseState<T>` class has one abstract method `T reduce(T state, Action action);`. This method should be invoked by sysytem passing current state and action. You should mutate the state based on action.

#### Example
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  int count;
  bool isLoading;

  CounterModel({this.count, this.isLoading});

  static clone(CounterModel obj) {
    return CounterModel(count: obj.count, isLoading: obj.isLoading);
  }

  CounterModel.init() : this(count: 10, isLoading: false);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  CounterModel reduce(CounterModel state, Action action) {
    switch (action.type) {
      case ActionTypes.Inc:
        state.count++;
        state.isLoading = false;
        return CounterModel.clone(state);
      case ActionTypes.Dec:
        state.count--;
        state.isLoading = false;
        return CounterModel.clone(state);
      case ActionTypes.AsyncInc:
        state.isLoading = true;
        return CounterModel.clone(state);

      default:
        return state;
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
