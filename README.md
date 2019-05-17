# ajwah_bloc
Rx based state management library for Dart. Manage your application's states, effects, and actions easy way.

## States
Every state class must derived from `BaseState<T>` class. And it is mandatory to pass the
state `name` and `initialState`. The `BaseState<T>` class has one abstract method `T reduce(T state, Action action);`. This method should be invoked by sysytem passing current state and action. You should mutate the state based on action.

#### Example
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 0, isLoading: false);
  CounterModel.countData(int count) : this(count: count, isLoading: false);
  CounterModel.loading(int count) : this(count: count, isLoading: true);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  CounterModel reduce(CounterModel state, Action action) {
    switch (action.type) {
      case ActionTypes.Inc:
        return CounterModel.countData(state.count + 1);
      case ActionTypes.Dec:
        return CounterModel.countData(state.count - 1);
      case ActionTypes.AsyncInc:
        return CounterModel.loading(state.count);

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


## Applied in components
Ajwah provides a comfortable way to use states in components and dispatching state actions.

First of all we need to call `createStore(states:[], effects:[])` method. So that `store` object exposed throughout the application.

We can use `select` method to get `state` data (passing state name): `store().select(stateName: 'counter')`.
This method return a `Observable<T>` type data. Now we can use `StreamBuilder` class for a reactive widget.
And also for dispatching state's action - we will use `dispatch(actionType:'Inc')` method.

### Example

```dart
StreamBuilder<CounterModel>(
    stream: store().select(stateName: 'counter'),
    builder:(BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
        if (snapshot.hasData) {
            if (snapshot.data.isLoading) {
                return CircularProgressIndicator();
            }
            return Text(
                snapshot.data.count.toString(),
                style: Theme.of(context).textTheme.title,
            );
        } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
        }
        return CircularProgressIndicator();
    },
)            
```
## CounterComponent
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/counter/store/counterState.dart';
import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/material.dart';

class CounterComponent extends StatelessWidget {
  const CounterComponent({Key key}) : super(key: key);

  void increment() {
    dispatch(actionType: ActionTypes.Inc);
  }

  void decrement() {
    dispatch(actionType: ActionTypes.Dec);
  }

  void asyncIncrement() {
    dispatch(actionType: ActionTypes.AsyncInc);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
          RaisedButton(
            textColor: Colors.white,
            color: Colors.blue,
            child: Icon(Icons.add),
            onPressed: increment,
          ),
          new RaisedButton(
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('Async(+)'),
            onPressed: asyncIncrement,
          ),
          RaisedButton(
            textColor: Colors.white,
            color: Colors.blue,
            child: Icon(Icons.remove),
            onPressed: decrement,
          )
        ]),
        SizedBox(
          width: 10.0,
        ),
        StreamBuilder<CounterModel>(
          stream: store().select(stateName: 'counter'),
          builder:
              (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isLoading) {
                return CircularProgressIndicator();
              }
              return Text(
                snapshot.data.count.toString(),
                style: Theme.of(context).textTheme.title,
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return CircularProgressIndicator();
          },
        )
      ],
    );
  }
}

```
[Please have a look at here for progressive examples](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_block_examples)
