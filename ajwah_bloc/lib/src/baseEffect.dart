import 'package:rxdart/rxdart.dart';

import 'action.dart';
import 'actions.dart';
import 'storeContext.dart';

abstract class BaseEffect {
  final String effectKey;
  BaseEffect({this.effectKey});
  List<Observable<Action>> allEffects(Actions action$, StoreContext store$);
}
