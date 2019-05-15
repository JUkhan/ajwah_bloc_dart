import 'package:meta/meta.dart';

class Action<T> {
  final String type;
  final T payload;
  Action({@required this.type, this.payload});
}
