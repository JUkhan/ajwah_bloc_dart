import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart';

class AppStateProvider extends InheritedWidget {
  AppStateProvider({Key key, this.child, this.store})
      : super(key: key, child: child);

  final Widget child;
  final Store store;

  static Store of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AppStateProvider)
            as AppStateProvider)
        .store;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) {
    return true;
  }
}
