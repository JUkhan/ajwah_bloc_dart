import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';

import "package:test/test.dart";

import 'TodoEffects.dart';
import 'TodoState.dart';
import 'actionTypes.dart';
import 'counterState.dart';

//pub run test test/ajwah_test.dart

dynamic storeFactoty() {
  return createStore(
      states: [CounterState(), TodoState()],
      //effects: [TodoEffects()],
      block: true);
}

void main() {
  Store store = storeFactoty();
  tearDownAll(() {
    store.dispose();
  });
  //delay(1000);
  test("select distinct", () {
    int count = 0;
    store.select<CounterModel>('counter').listen((counterModel) {
      expect(counterModel.count, equals(count));
      expect(counterModel.isLoading, equals(false));
      count++;
    });
    bool isOnce = true;
    store.select<TodoModel>('todo').listen((counterModel) {
      expect(isOnce, equals(true));
      expect(counterModel.message, equals(''));
      expect(counterModel.todoList.length, equals(0));
      isOnce = false;
    });
    store.dispatch(Action(type: ActionTypes.Inc));
  });
}
