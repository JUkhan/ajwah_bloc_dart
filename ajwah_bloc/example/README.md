[example lib/main.dart](https://github.com/JUkhan/ajwah_bloc_dart/tree/master/ajwah_bloc_examples/lib/main.dart)

```dart
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ajwah_bloc/ajwah_bloc.dart' as store;

void main() {
  createStore(states: [CounterState()]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajwah Store'),
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          StateOnDemand(),
          Counter(),
          ExportState(),
        ],
      )),
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () => dispatch('Inc'),
          child: Text('+'),
        ),
        RaisedButton(
          onPressed: () => dispatch('Dec'),
          child: Text('-'),
        ),
        RaisedButton(
          onPressed: () => dispatch('AsyncInc'),
          child: Text('Async +'),
        ),
        StreamBuilder<CounterModel>(
          stream: select('counter'),
          builder:
              (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      '  ${snapshot.data.count}',
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                    );
            }
            return Container();
          },
        ),
      ],
    );
  }
}

class StateOnDemand extends StatelessWidget {
  const StateOnDemand({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () => removeStateByStateName('counter'),
          child: Text('Remove State'),
        ),
        RaisedButton(
          onPressed: () => addState(CounterState()),
          child: Text('Add State'),
        ),
        RaisedButton(
          onPressed: () => importState(
              {'counter': CounterModel(count: 999, isLoading: false)}),
          child: Text('Import State'),
        ),
      ],
    );
  }
}

class ExportState extends StatelessWidget {
  const ExportState({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: exportState(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          var state = snapshot.data[1].length > 0
              ? snapshot.data[1]['counter']?.toString() ?? ''
              : 'empty';
          return Container(
            child: Text.rich(
              TextSpan(text: 'Export State\n', children: [
                TextSpan(
                    text: 'actionType:${snapshot.data[0].type} \nstate:$state',
                    style: TextStyle(color: Colors.purple, fontSize: 24))
              ]),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.indigo, fontSize: 20),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 10, isLoading: false);
  CounterModel copyWith({int count, bool isLoading}) => CounterModel(
      count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  @override
  String toString() {
    return '{coun:$count, isLoading:$isLoading}';
  }
}

class CounterState extends BaseState<CounterModel> {
  CounterState() : super(name: 'counter', initialState: CounterModel.init());

  Stream<CounterModel> mapActionToState(
      CounterModel state, store.Action action) async* {
    switch (action.type) {
      case 'Inc':
        yield state.copyWith(count: state.count + 1, isLoading: false);
        break;
      case 'Dec':
        yield state.copyWith(count: state.count - 1, isLoading: false);
        break;
      case 'AsyncInc':
        yield state.copyWith(isLoading: true);
        await Future.delayed(Duration(seconds: 1));
        dispatch('Inc');
        break;
      default:
        yield latestState(this);
    }
  }
}


```
