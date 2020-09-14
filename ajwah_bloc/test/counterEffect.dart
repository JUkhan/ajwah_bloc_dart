import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'actionTypes.dart';

class CounterEffect extends EffectBase {
  CounterEffect() : super(effectKey: 'counterEffect');
  Stream<Action> effectForAsyncInc(Actions action$, Store store$) {
    return action$
        .whereType(ActionTypes.AsyncInc)
        .debounceTime(Duration(milliseconds: 2))
        .mapTo(Action(type: ActionTypes.Inc));
  }

  List<Stream<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForAsyncInc(action$, store$)];
  }
}
