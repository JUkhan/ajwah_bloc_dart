///In `Action` generic **T** used for pauload action.
class Action {
  final String type;
  Action({this.type});
  @override
  String toString() {
    return 'Action(type: $type)';
  }
}
