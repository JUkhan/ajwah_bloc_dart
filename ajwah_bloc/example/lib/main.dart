import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:rxdart/rxdart.dart';

void main() {
  registerCounterState();
  runApp(App());
}

final store = AjwahStore();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajwah Store'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CounterWidget(), const Loading()],
        ),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: StreamBuilder<bool>(
        stream: loading$,
        initialData: false,
        builder: (context, snapshot) {
          return snapshot.data ? CircularProgressIndicator() : Container();
        },
      ),
    );
  }
}

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
            onPressed: () => store.dispatch(Action(type: 'inc')),
          ),
          RaisedButton(
            child: Text('async-inc'),
            onPressed: () => store.dispatch(Action(type: 'async-inc')),
          ),
          RaisedButton(
            child: Text('dec'),
            onPressed: () => store.dispatch(Action(type: 'dec')),
          ),
          StreamBuilder(
            stream: counter$,
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

void registerCounterState() {
  store.registerState<int>(
    stateName: 'counter',
    initialState: 0,
    mapActionToState: (state, action, emit) {
      switch (action.type) {
        case 'inc':
          emit(state + 1);
          break;
        case 'dec':
          emit(state - 1);
          break;
        default:
      }
    },
  );
}

final counter$ = store.select<int>('counter');
final asyncInc$ = store.actions.whereType('async-inc');
final loading$ = Rx.merge([
  asyncInc$.map((event) => true),
  asyncInc$.delay(const Duration(seconds: 1)).doOnData((event) {
    store.dispatch(Action(type: 'inc'));
  }).map((event) => false)
]).asBroadcastStream();
