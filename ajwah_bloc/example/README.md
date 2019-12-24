[Please have a look at here for progressive examples](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_bloc_examples)

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
  int count;
  bool isLoading;

  CounterModel({this.count, this.isLoading});

  copyWith({int count, bool isLoading}) {
    return CounterModel(
        count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  }

  CounterModel.init() : this(count: 10, isLoading: false);
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, Action action) async* {
    switch (action.type) {
      case ActionTypes.Inc:
        state.count++;
        yield state.copyWith(isLoading: false);
        break;
      case ActionTypes.Dec:
        state.count--;
        yield state.copyWith(isLoading: false);
        break;
      case ActionTypes.AsyncInc:
        yield state.copyWith(isLoading: true);
        yield await getCount(state.count);
        break;
      default:
        yield state;
    }
  }

  Future<CounterModel> getCount(int count) {
    return Future.delayed(Duration(milliseconds: 500),
        () => CounterModel(count: count + 1, isLoading: false));
  }
}


```

## CounterComponent.dart
```dart

import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'actionTypes.dart';
import 'counterState.dart';
import 'package:flutter/material.dart';

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
          stream: store().select<CounterModel>('counter'),
          initialData: CounterModel.init(),
          builder:
              (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
                
            if (snapshot.data.isLoading) {
              return CircularProgressIndicator();
            }
            return Text(
              snapshot.data.count.toString(),
              style: Theme.of(context).textTheme.title,
            );
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
import 'counterState.dart';
import 'package:flutter/material.dart';

void main(){
  createStore(states: [CounterState()]]);
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ajwah_bloc Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: CounterComponent());
  }
}

```