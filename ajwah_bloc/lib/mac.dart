import 'package:ajwah_bloc/ajwah_bloc.dart';

main() {
  final store = createStore();
  store.registerState<int>(
    stateName: 'counter',
    initialState: 0,
    mapActionToState: (state, action, emit) {
      if (action.type == 'inc') emit(state + 1);
    },
  );
  store.select('counter').listen((state) => print(state)); // 0, 1
  store.dispatch(Action(type: 'inc'));
}
