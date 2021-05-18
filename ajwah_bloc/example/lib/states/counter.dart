import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:example/widgets/StreamConsumer.dart';
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

  Stream<SCResponse> get count$ => Rx.merge([
        action$.whereType('asyncInc').mapTo(SCLoading()),
        stream$.map((data) => SCData<String>('$data')),
      ]);
}
