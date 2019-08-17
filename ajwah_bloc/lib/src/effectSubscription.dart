import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'action.dart';
import 'dispatcher.dart';

class EffectSubscription extends CompositeSubscription {
  final Dispatcher _dispatcher;
  EffectSubscription(this._dispatcher);

  void addEffects(Stream<Action> effect) {
    add(effect.listen(_dispatcher.dispatch));
  }
}
