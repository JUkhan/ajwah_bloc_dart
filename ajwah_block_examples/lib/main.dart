import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/appStateProvider.dart';
import 'package:ajwah_block_examples/counter/components/counterComponent.dart';
import 'package:ajwah_block_examples/counter/store/counterEffect.dart';
import 'package:ajwah_block_examples/counter/store/counterState.dart';
import 'package:ajwah_block_examples/todo/components/todoContainer.dart';
import 'package:ajwah_block_examples/todo/store/TodoEffects.dart';
import 'package:ajwah_block_examples/todo/store/TodoState.dart';
import 'package:ajwah_block_examples/wikiSearch/components/searchComponent.dart';
import 'package:ajwah_block_examples/wikiSearch/store/SearchState.dart';
import 'package:ajwah_block_examples/wikiSearch/store/searchEffect.dart';
import 'package:flutter_web/material.dart';

void main() => runApp(App(
    store: createStore(
        states: [CounterState(), SearchState(), TodoState()],
        effects: [CounterEffect(), SearchEffect(), TodoEffects()])));

class App extends StatefulWidget {
  App({Key key, this.store}) : super(key: key);
  final Store store;
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
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
          '/todo': (_) => TodoContainer()
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
