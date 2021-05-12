import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';
import 'package:test/test.dart';
import 'package:ajwah_bloc/ajwah_bloc.dart';

import 'actionTypes.dart';
import 'counterController.dart';

void main() {
  hello_fn();
}

void hello_fn() {
  var controller = CounterController();

  setUp(() {});
  tearDown(() {
    controller.dispose();
  });
  group('counter', () {
    ajwahTest<CounterModel>(
      'initial state',
      build: () {
        return controller.stream$;
      },
      act: () {
        dispatch(Action(type: ActionTypes.Inc));
      },
      expect: [isA<CounterModel>(), isA<CounterModel>()],
      log: (models) async {
        print(models);
        final m =
            await controller.remoteState<CounterController, CounterModel>();
        print(m);
      },
    );
  });
}
