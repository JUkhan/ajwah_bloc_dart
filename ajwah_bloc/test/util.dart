import 'dart:async';

Future<bool> delay(int milli) {
  return Future<bool>.delayed(Duration(milliseconds: milli), () => true);
}
