import 'package:rxdart/rxdart.dart';

import 'action.dart';
import 'actions.dart';
import 'store.dart';

///Every effect class must derived from `BaseEffect` class. And it is optional to pass the
///`effectKey`. But it's mandatory if you want conditionally remove the effects by using
///`store.removeEffectsByKey('effectKey')`
///
///**Example**
///```dart
///class CounterEffect extends BaseEffect {
///   Observable<Action> effectForAsyncInc(Actions action$, Store store$) {
///     return action$
///           .ofType(ActionTypes.AsyncInc)
///           .debounceTime(Duration(milliseconds: 550))
///           .mapTo(Action(type: ActionTypes.Inc));
///    }
///
///    List<Observable<Action>> registerEffects(Actions action$, Store store$) {
///       return [effectForAsyncInc(action$, store$)];
///    }
///
///}
///```
abstract class BaseEffect {
  final String effectKey;

  ///takes **String effectKey** param
  BaseEffect({this.effectKey});

  ///This function should be invoked by system passing reference of Actions and Store classes.
  ///Please keep in mind that effects should not work until you register them.
  ///Here is the example how to register **effectForAsyncInc** effect.
  ///
  ///**Example**
  ///```dart
  ///    List<Observable<Action>> registerEffects(Actions action$, Store store$) {
  ///       return [effectForAsyncInc(action$, store$)];
  ///    }
  /// ```
  List<Observable<Action>> registerEffects(Actions action$, Store store$);
}
