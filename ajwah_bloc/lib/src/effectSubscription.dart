import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'action.dart';

class EffectSubscription extends CompositeSubscription {
  final BehaviorSubject<Action> _dispatcher;
  EffectSubscription(this._dispatcher);

  void addEffects(Stream<Action> effect) {
    add(effect.listen(_dispatcher.add));
  }
}
