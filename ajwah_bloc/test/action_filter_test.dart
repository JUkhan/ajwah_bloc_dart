import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:test/test.dart';

class TestFilterAction extends Action {}

class Increment extends TestFilterAction {}

class Decrement extends TestFilterAction {}

void setState(AjwahStore store) {
  store.registerState<int>(
    stateName: 'test',
    initialState: 0,
    filterActions: (action) => action.type != 'dec',
    mapActionToState: (state, action, emit) {
      print(action.type);
      if (action.type == 'inc') {
        emit(state + 1);
      } else if (action.type == 'dec') {
        emit(state - 1);
      }
    },
  );
}

void main() async {
  final store = AjwahStore();
  setState(store);
  store.select('test').listen(print);
  store.dispatch(Action(type: 'inc'));
  store.dispatch(Action(type: 'dec'));
  test('hello', () {
    expect(0, 0);
  });
  await Future.delayed(const Duration(milliseconds: 50));
  store.dispose();
}
