import 'action.dart';

typedef FilterActionCallback = bool Function(Action action);
typedef EmitStateCallback<S> = void Function(S state);
typedef MapActionToStateCallback<S> = void Function(
  S state,
  Action action,
  EmitStateCallback<S> emit,
);
typedef StateUpdate<S> = S Function(S state);
