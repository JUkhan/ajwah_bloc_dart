import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc/src/store.dart';
import "package:test/test.dart";
import "package:ajwah_bloc/src/action.dart";
import 'actionTypes.dart';
import 'counterState.dart';
import 'TodoState.dart';
//pub run test test/ajwah_test.dart

Store storeFactoty() {
  return createStore(states: [CounterState()]);
}

void main() {
  final store = storeFactoty();
  var isFirst = true;
  setUp(() {
    isFirst = true;
  });

  test("initial store should be:{count:0, isLoading:false}", () {
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(0));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after store.addState(TodoState()) todo state should be:{message:'', todoList:[]}",
      () {
    store.addState(TodoState());
    store.select<TodoModel>(stateName: 'todo').take(1).listen((todoModel) {
      expect(todoModel.message, equals(''));
      expect(todoModel.todoList, equals([]));
    });
  });
  test(
      "after dispatch(actionType: ActionTypes.Dec) counter state should be:{count:-1, isLoading:false}",
      () {
    dispatch(actionType: ActionTypes.Dec);
    store
        .select<CounterModel>(stateName: 'counter')
        .take(1)
        .listen((counterModel) {
      expect(counterModel.count, equals(-1));
      expect(counterModel.isLoading, equals(false));
    });
  });

  test(
      "after dispatch(actionType: ActionTypes.LoadingTodos) todo state should be mutated two times: first time:{message:'Loading todos.',todoList:[]} and second time:{message:'',todoList:[5 items...]}",
      () {
    dispatch(actionType: ActionTypes.LoadingTodos);

    store.select<TodoModel>(stateName: 'todo').take(2).listen((todoModel) {
      if (isFirst) {
        expect(todoModel.message, equals('Loading todos.'));
      } else {
        expect(todoModel.todoList.length, equals(5));
      }
      isFirst = false;
    });
  });

  test(
      "after store.removeStateByStateName('counter') - actionType: 'remove_state(counter)' should be dispatched.",
      () {
    store.exportState().take(1).listen((arr) {
      expect((arr[0] as Action).type, equals('remove_state(counter)'));
    });
    store.removeStateByStateName('counter');
  });
}
