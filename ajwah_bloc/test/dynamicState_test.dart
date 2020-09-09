import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc/src/createStore.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import "package:test/test.dart";
import "package:ajwah_bloc/src/action.dart";
import 'actionTypes.dart';
import 'counterState.dart';
import 'TodoState.dart';

void main() {
  Store store;

  setUpAll(() {
    store = createStore(states: [CounterState()]);
  });

  tearDownAll(() {
    store.dispose();
  });

  ajwahTest("initial store should be:{count:0, isLoading:false}",
      build: () => store.select('counter'), expect: [CounterModel.init()]);

  ajwahTest(
    "after addState(TodoState()) todo state should be:{message:'', todoList:[]}",
    build: () {
      store.addState(TodoState());
      return store.select('todo');
    },
    skip: 1,
    expect: [isA<TodoModel>()],
  );

  ajwahTest(
      "after dispatch(actionType: ActionTypes.Dec) counter state should be:{count:-1, isLoading:false}",
      build: () => store.select<CounterModel>('counter'),
      act: () => store.dispatch(Action(type: ActionTypes.Dec)),
      skip: 1,
      expect: [CounterModel(count: -1, isLoading: false)]);

  test(
      "after dispatch(actionType: ActionTypes.LoadingTodos) todo state should be:{message:'Loading todos.',todoList:[]}",
      () {
    store.dispatch(Action(type: ActionTypes.LoadingTodos));
    // await delay(20);
    store.select<TodoModel>('todo').skip(1).take(1).listen((todoModel) {
      expect(todoModel.message, equals('Loading todos.'));
    });
  });

  test(
      "after removeStateByStateName('counter') - actionType: 'remove_state(counter)' should be dispatched.",
      () async {
    store.exportState().take(1).listen((arr) {
      expect((arr[0] as Action).type, equals('remove_state(counter)'));
    });
    store.removeStateByStateName('counter');
  });
}
