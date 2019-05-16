import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../actionTypes.dart';

class CounterEffect extends BaseEffect {
  Observable<Action> effectForAsyncInc(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.AsyncInc)
        .debounceTime(Duration(milliseconds: 550))
        .mapTo(Action(type: ActionTypes.Inc));
  }

  List<Observable<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForAsyncInc(action$, store$)];
  }
}
