///This is a base action class
class Action {
  final String type;
  Action({this.type = ''});

  @override
  String toString() => '$runtimeType(type: $type)';
}
