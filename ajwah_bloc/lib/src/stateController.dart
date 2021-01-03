import 'actions.dart';
import 'types.dart';
import 'ajwahStore.dart';
import 'package:meta/meta.dart';
import 'action.dart';

abstract class StateController<S> {
  String _stateName;
  S _currentState;
  EmitStateCallback<S> _emit;
  AjwahStore _store;

  StateController({
    @required String stateName,
    @required S initialState,
    AjwahStore store,
  })  : assert(stateName != null),
        assert(initialState != null) {
    _currentState = initialState;
    _stateName = stateName;
    _store = store ?? AjwahStore();

    _store.registerState<S>(
        stateName: _stateName,
        initialState: _currentState,
        mapActionToState: (state, action, emit) {
          _currentState = state;
          _emit = emit;
          onAction(state, action);
        });
  }

  void update(StateUpdate<S> callback) {
    _currentState = callback(_currentState);
    _emit(_currentState);
  }

  void dispatch(Action action) {
    _store.dispatch(action);
  }

  void dispose() {
    _store.dispose();
  }

  void onAction(S state, Action action) {}

  S get currentState => _currentState;

  Actions get actions => _store.actions;

  Stream<S> get stream$ => _store.select(_stateName);

  AjwahStore get store => _store;
}
