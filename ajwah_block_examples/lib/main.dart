import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/counter/components/counterComponent.dart';
import 'package:ajwah_block_examples/counter/store/counterEffect.dart';
import 'package:ajwah_block_examples/counter/store/counterState.dart';
import 'package:ajwah_block_examples/wikiSearch/components/searchComponent.dart';
import 'package:ajwah_block_examples/wikiSearch/store/SearchState.dart';
import 'package:ajwah_block_examples/wikiSearch/store/searchEffect.dart';
import 'package:flutter_web/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    createStore(
        states: [CounterState(), SearchState()],
        effects: [CounterEffect(), SearchEffect()]);
    store().exportState().listen((arr) {
      print((arr[0] as Action).type);
      print(arr[1]);
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ajwah - '),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  void menuSelect(String value) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: menuSelect,
            itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'Counter',
                    child: ListTile(
                      title: Text('Counter'),
                    ),
                  )
                ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CounterComponent(),
            Expanded(child: SearchComponent())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.replay),
        onPressed: () {
          store().importState(
              {'counter': CounterModel(count: 101, isLoading: false)});
        },
      ),
    );
  }
}
