///In `Action<T>` generic **T** used for pauload.
class Action<T> {
  final String type;
  final T payload;
  Action({this.type, this.payload});
}
