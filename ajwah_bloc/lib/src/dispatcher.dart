import 'action.dart';
import 'package:rxdart/rxdart.dart';

class Dispatcher {
  final BehaviorSubject<Action> _subject =
      BehaviorSubject<Action>.seeded(Action(type: '@INIT'));

  void dispatch(Action action) {
    _subject.add(action);
  }

  BehaviorSubject<Action> get streamController => _subject;

  void dispose() {
    _subject.close();
  }
}
