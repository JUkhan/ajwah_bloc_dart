import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:example/widgets/StreamConsumer.dart';
import 'package:rxdart/rxdart.dart';

class CounterState extends StateController<int> {
  CounterState() : super(0);

  @override
  void onInit() {
    mapActionToState([
      action$
          .whereType('asyncInc')
          .delay(const Duration(seconds: 1))
          .map((event) => state + 1),
    ]);
  }

  void inc() => emit(state + 1);

  void dec() => emit(state - 1);

  Stream<SCResponse> get count$ => Rx.merge([
        action$.whereType('asyncInc').mapTo(SCLoading()),
        stream$.map((data) => data > 10
            ? SCError('Counter is out of the range.')
            : SCData('$data')),
      ]);
}
