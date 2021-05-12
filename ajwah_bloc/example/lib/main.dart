import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'package:flutter/material.dart' hide Action;
import 'package:rxdart/rxdart.dart';
import 'StreamConsumer.dart';

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
  const CounterPage({Key? key}) : super(key: key);

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
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: StreamConsumer<bool>(
        stream: controller.loading$,
        builder: (context, isLoadding) {
          return isLoadding != null && isLoadding
              ? CircularProgressIndicator()
              : Container();
        },
      ),
    );
  }
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text('inc'),
            onPressed: () => dispatch(Action(type: 'inc')),
          ),
          ElevatedButton(
            child: const Text('async-inc'),
            onPressed: controller.asyncInc,
          ),
          ElevatedButton(
            child: const Text('dec'),
            onPressed: controller.decrement,
          ),
          StreamConsumer<int>(
            stream: controller.select((state) => state),
            builder: (context, count) {
              return Container(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(count.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CounterStateController extends StateController<int> {
  CounterStateController() : super(2);
  @override
  void onAction(int state, Action action) async {
    print(action);
    switch (action.type) {
      case 'inc':
        emit(state + 1);
        var rs = await remoteState<CounterStateController, int>();
        print('remote state: $rs');
        break;
      case 'dec':
        emit(state - 1);
        break;

      default:
    }
  }

  void increment() {
    emit(state + 1);
  }

  void decrement() {
    emit(state - 1);
  }

  void asyncInc() async {
    dispatch(Action(type: 'async-inc'));
    await Future.delayed(const Duration(milliseconds: 1000));
    dispatch(Action(type: 'async-inc-done'));
    increment();
  }

  Stream<bool> get loading$ {
    final asyncInc$ = action$.whereType('async-inc');
    final asyncIncDone$ = action$.whereType('async-inc-done');
    return Rx.merge([
      asyncInc$.map((event) => true),
      asyncIncDone$.map((event) => false)
    ]).asBroadcastStream();
  }

  @override
  void onInit() {
    print('init' + state.toString());
    registerEffects([
      action$
          .whereType('async-inc')
          .debounceTime(const Duration(seconds: 2))
          .mapTo(Action(type: 'dec')),
      action$
          .whereType('async-inc-done')
          .debounceTime(const Duration(seconds: 2))
          .mapTo(Action(type: 'inc'))
    ]);
  }
}
