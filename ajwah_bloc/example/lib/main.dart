import 'dart:async';
import 'package:ajwah_bloc/ajwah_bloc.dart' as store;
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  createStore(exposeApiGlobally: true);
  registerCounterState();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajwah Store'),
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          StateOnDemand(),
          Counter(),
          ExportState(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: () =>
                    store.dispatch(store.Action(type: 'show-widget')),
                child: Text("Show Widget"),
              ),
              RaisedButton(
                onPressed: () =>
                    store.dispatch(store.Action(type: 'hide-widget')),
                child: Text("Hide Widget"),
              ),
            ],
          ),
          StreamBuilder<String>(
            stream: store.storeInstance().actions.whereTypes(
                ['show-widget', 'hide-widget']).map((action) => action.type),
            initialData: 'hide-widget',
            builder: (context, snapshot) {
              return snapshot.data == 'show-widget'
                  ? DynamicWidget()
                  : Container();
            },
          ),
        ],
      )),
    );
  }
}

class DynamicWidget extends StatefulWidget {
  DynamicWidget({Key key}) : super(key: key);

  @override
  _DynamicWidgetState createState() => _DynamicWidgetState();
}

class _DynamicWidgetState extends State<DynamicWidget> {
  final _effectKey = "effectKey";
  var msg = '';
  _addEffectForAsyncInc() {
    storeInstance().registerEffect(
      (action$, store$) => action$
          .whereType('AsyncInc')
          .debounceTime(Duration(milliseconds: 500))
          .map((event) => store.Action(type: 'Dec')),
      effectKey: _effectKey,
    );
    setState(() {
      msg =
          "Effect added successfully.\nNow click on the [Async +] button and see it's not working as expected.";
    });
  }

  _removeEffect([bool isDisposing = false]) {
    storeInstance().unregisterEffect(effectKey: _effectKey);
    if (!isDisposing)
      setState(() {
        msg = 'Effect removed';
      });
  }

  @override
  void dispose() {
    _removeEffect(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: _addEffectForAsyncInc,
                child: Text("Add Effect on AsyncInc action"),
              ),
              RaisedButton(
                onPressed: _removeEffect,
                child: Text("Remove effect"),
              )
            ],
          ),
          Text(msg, style: TextStyle(fontSize: 20, color: Colors.white70)),
        ],
      ),
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () => store.dispatch(store.Action(type: 'Inc')),
          child: Text('+'),
        ),
        RaisedButton(
          onPressed: () => store.dispatch(store.Action(type: 'Dec')),
          child: Text('-'),
        ),
        StreamBuilder<String>(
          stream: store.storeInstance().actions.whereTypes([
            'registerEffect(effectKey)',
            'unregisterEffect(effectKey)'
          ]).map((action) => action.type),
          initialData: 'effect-removed',
          builder: (context, snapshot) => RaisedButton(
            onPressed: () => store.dispatch(store.Action(type: 'AsyncInc')),
            child: Text(
              'Async +',
              style: TextStyle(
                  color: snapshot.data == 'registerEffect(effectKey)'
                      ? Colors.red
                      : null),
            ),
          ),
        ),
        StreamBuilder<CounterModel>(
          stream: select('counter'),
          builder:
              (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      '  ${snapshot.data.count}',
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                    );
            }
            return Container();
          },
        ),
      ],
    );
  }
}

class StateOnDemand extends StatelessWidget {
  const StateOnDemand({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: () =>
              store.storeInstance().unregisterState(stateName: 'counter'),
          child: Text('Remove State'),
        ),
        RaisedButton(
          onPressed: registerCounterState,
          child: Text('Add State'),
        ),
        RaisedButton(
          onPressed: () => storeInstance().importState(
              {'counter': CounterModel(count: 999, isLoading: false)}),
          child: Text('Import State'),
        ),
      ],
    );
  }
}

class ExportState extends StatelessWidget {
  const ExportState({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: store.storeInstance().exportState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var state = snapshot.data[1].length > 0
              ? snapshot.data[1]['counter']?.toString() ?? ''
              : 'empty';
          return Container(
            child: Text.rich(
              TextSpan(text: 'Export State\n', children: [
                TextSpan(
                    text: 'actionType:${snapshot.data[0].type} \nstate:$state',
                    style: TextStyle(color: Colors.purple, fontSize: 24))
              ]),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.indigo, fontSize: 20),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class CounterModel {
  final int count;
  final bool isLoading;
  CounterModel({this.count, this.isLoading});
  CounterModel.init() : this(count: 10, isLoading: false);
  CounterModel copyWith({int count, bool isLoading}) => CounterModel(
      count: count ?? this.count, isLoading: isLoading ?? this.isLoading);
  @override
  String toString() {
    return '{coun:$count, isLoading:$isLoading}';
  }
}

registerCounterState() {
  store.registerState<CounterModel>(
      stateName: 'counter',
      initialState: CounterModel.init(),
      mapActionToState: (state, action, emit) async {
        switch (action.type) {
          case 'Inc':
            emit(state.copyWith(count: state.count + 1, isLoading: false));
            break;
          case 'Dec':
            emit(state.copyWith(count: state.count - 1, isLoading: false));
            break;
          case 'AsyncInc':
            emit(state.copyWith(isLoading: true));
            await Future.delayed(Duration(seconds: 1));
            store.dispatch(store.Action(type: 'Inc'));
            break;
          default:
        }
      });
}
