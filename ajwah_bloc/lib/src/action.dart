import 'package:meta/meta.dart';

///In `Action<T>` generic **T** used for pauload.
class Action<T> {
  final String type;
  final T payload;
  Action({@required this.type, this.payload});
}
