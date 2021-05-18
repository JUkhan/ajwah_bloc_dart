import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

class CounterState extends StateController<int> {
  CounterState() : super(0);
  inc() {
    emit(state + 1);
  }

  dec() {
    emit(state - 1);
  }

  asyncInc() async {
    dispatch(Action(type: 'asyncInc'));
    await Future.delayed(const Duration(seconds: 1));
    inc();
  }

  Stream<String> get count$ => Rx.merge([
        action$.whereType('asyncInc').mapTo('loading...'),
        stream$.map((data) => '$data'),
      ]);
}
