import 'package:flutter/material.dart';
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_examples/appStateProvider.dart';
import 'package:ajwah_bloc_examples/counter/components/counterComponent.dart';
import 'package:ajwah_bloc_examples/store/effects/searchEffect.dart';
import 'package:ajwah_bloc_examples/store/states/SearchState.dart';
import 'package:ajwah_bloc_examples/store/states/TodoState.dart';
import 'package:ajwah_bloc_examples/store/states/counterState.dart';
import 'package:ajwah_bloc_examples/todo/components/todoContainer.dart';
import 'package:ajwah_bloc_examples/widgets/dynamicStateAndEffect.dart';
import 'package:ajwah_bloc_examples/wikiSearch/components/searchComponent.dart';

void main() => runApp(App(
    store: createStore(
        states: [CounterState(), SearchState(), TodoState()],
        effects: [SearchEffect()])));

class App extends StatefulWidget {
  App({Key key, this.store}) : super(key: key);
  final Store store;
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    store().exportState().listen((arr) {
      print(arr[0].type);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      store: widget.store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          '/': (_) => CounterComponent(),
          '/search': (_) => SearchComponent(),
          '/todo': (_) => TodoContainer(),
          '/dynamicse': (_) => DynamicStateAndEffectWidget()
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.store.dispose();
    super.dispose();
  }
}