import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';
import "package:test/test.dart";
import "package:ajwah_bloc/src/action.dart";
import 'actionTypes.dart';
import 'counterState.dart';
import 'TodoState.dart';
import 'util.dart';
//pub run test test/ajwah_test.dart
//dart --pause-isolates-on-exit --enable_asserts --enable-vm-service   test/.test_coverage.dart

storeFactoty() {
  return createStore(states: [CounterState()], block: true);
}

void main() {
  Store store = storeFactoty();
  tearDownAll(() {
    store.dispose();
  });
  test("initial store should be:{count:0, isLoading:false}", () async {
    store.select<CounterModel>('counter').take(1).listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after addState(TodoState()) todo state should be:{message:'', todoList:[]}",
      () async {
    store.addState(TodoState());
    store.select<TodoModel>('todo').skip(1).take(1).listen((todoModel) {
      print(todoModel);
      expect(todoModel.message, equals(''));
      expect(todoModel.todoList, equals([]));
    });
  });
  test(
      "after dispatch(actionType: ActionTypes.Dec) counter state should be:{count:-1, isLoading:false}",
      () async {
    store.dispatch(Action(type: ActionTypes.Dec));
    await delay(20);
    store
        .select<CounterModel>('counter')
        .skip(1)
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(-1));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after dispatch(actionType: ActionTypes.LoadingTodos) todo state should be:{message:'Loading todos.',todoList:[]}",
      () async {
    store.dispatch(Action(type: ActionTypes.LoadingTodos));
    await delay(20);
    store.select<TodoModel>('todo').skip(1).take(1).listen((todoModel) {
      expect(todoModel.message, equals('Loading todos.'));
    });
  });

  test(
      "after removeStateByStateName('counter') - actionType: 'remove_state(counter)' should be dispatched.",
      () async {
    store.exportState().skip(1).take(1).listen((arr) {
      expect((arr[0] as Action).type, equals('remove_state(counter)'));
    });
    store.removeStateByStateName('counter');
  });
}
