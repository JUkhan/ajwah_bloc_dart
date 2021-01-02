import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'package:flutter/material.dart' hide Action;
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(App());
}

final controller = CounterStateController();

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
        stream: controller.loading$,
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
            onPressed: controller.increment,
          ),
          RaisedButton(
            child: Text('async-inc'),
            onPressed: controller.asyncInc,
          ),
          RaisedButton(
            child: Text('dec'),
            onPressed: controller.decrement,
          ),
          StreamBuilder(
            stream: controller.stream$,
            initialData: controller.currentState,
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

class CounterStateController extends StateController<int> {
  CounterStateController()
      : super(stateName: 'counter', initialState: 2, store: null);

  void increment() {
    update((state) => state + 1);
  }

  void decrement() {
    update((state) => state - 1);
  }

  void asyncInc() async {
    dispatch(Action(type: 'async-inc'));
    await Future.delayed(const Duration(milliseconds: 1000));
    dispatch(Action(type: 'async-inc-done'));
    increment();
  }

  Stream<bool> get loading$ {
    final asyncInc$ = actions.whereType('async-inc');
    final asyncIncDone$ = actions.whereType('async-inc-done');
    return Rx.merge([
      asyncInc$.map((event) => true),
      asyncIncDone$.map((event) => false)
    ]).asBroadcastStream();
  }
}
