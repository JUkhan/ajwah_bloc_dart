import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:example/widgets/StreamConsumer.dart';
import 'package:rxdart/rxdart.dart';

class CounterState extends StateController<int> {
  CounterState() : super(0);
  void inc() => emit(state + 1);

  void dec() => emit(state - 1);

  asyncInc() async {
    dispatch(Action(type: 'asyncInc'));
    await Future.delayed(const Duration(seconds: 1));
    inc();
  }

  Stream<SCResponse> get count$ => Rx.merge([
        action$.whereType('asyncInc').mapTo(SCLoading()),
        stream$.map((data) => data > 10
            ? SCError('Counter is out of the range.')
            : SCData('$data')),
      ]);
}
