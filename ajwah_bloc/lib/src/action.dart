///In `Action<T>` generic **T** used for pauload action.
class Action<T> {
  final String type;
  final T payload;
  Action({this.type, this.payload});
}
