[Please have a look at here for progressive examples](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_block_examples)

## actionTypes.dart
```dart
class ActionTypes {
  static const String Inc = 'inc';
  static const String Dec = 'dec';
  static const String AsyncInc = 'AsyncInc';
}

```
## counterState.dart
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'actionTypes.dart';

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
## counterEffects.dart
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'actionTypes.dart';

class CounterEffects extends BaseEffect {
  Observable<Action> effectForAsyncInc(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.AsyncInc)
        .debounceTime(Duration(milliseconds: 550))
        .mapTo(Action(type: ActionTypes.Inc));
  }

  List<Observable<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForAsyncInc(action$, store$)];
  }
}

```
## CounterComponent.dart
```dart

import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'actionTypes.dart';
import 'counterState.dart';
import 'counterState.dart';
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
## main.dart
```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'counterComponent.dart';
import 'counterEffect.dart';
import 'package:flutter_web/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    createStore(
        states: [CounterState(), SearchState(), TodoState()],
        effects: [CounterEffect(), SearchEffect(), TodoEffects()]
    );
    /*store().exportState().listen((arr) {
      print((arr[0] as Action).type);
      print(arr[1]);
    });
    store()
        .addState(SearchState())
        .removeStateByStateName('counter')
        .addState(CounterState());*/
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home:CounterComponent()
    );
  }
}


```