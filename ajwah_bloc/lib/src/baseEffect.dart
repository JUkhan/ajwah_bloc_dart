import 'package:rxdart/rxdart.dart';

import 'action.dart';
import 'actions.dart';
import 'storeContext.dart';

///Every effect class must derived from `BaseEffect` class. And it is optional to pass the
///`effectKey`. But it's mandatory if you want conditionally remove the effects by using
///`store.removeEffectsByKey('effectKey')`
///
///**Example**
///```dart
///class CounterEffect extends BaseEffect {
///   Observable<Action> effectForAsyncInc(Actions action$, StoreContext store$) {
///     return action$
///           .ofType(ActionTypes.AsyncInc)
///           .debounceTime(Duration(milliseconds: 550))
///           .mapTo(Action(type: ActionTypes.Inc));
///  }
///
///    List<Observable<Action>> allEffects(Actions action$, StoreContext store$) {
///       return [effectForAsyncInc(action$, store$)];
///    }
///
///}
///```
abstract class BaseEffect {
  final String effectKey;
  BaseEffect({this.effectKey});
  List<Observable<Action>> allEffects(Actions action$, StoreContext store$);
}
