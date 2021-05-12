**main.dart**

```dart
import 'dart:async';
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:rxdart/rxdart.dart';

void main() {
  createStore(exposeApiGlobally: true);
  registerThemeState();
  runApp(App());
}


```
