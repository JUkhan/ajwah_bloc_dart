import 'dart:async';
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:rxdart/rxdart.dart';

void main() {
  createStore(exposeApiGlobally: true);
  registerThemeState();
  runApp(App());
}

class ThemeToggleAction extends Action {}

void registerThemeState() {
  registerState<Brightness>(
    stateName: 'theme',
    filterActions: (action) => action is ThemeToggleAction,
    initialState: Brightness.light,
    mapActionToState: (state, action, emit) {
      emit(state == Brightness.light ? Brightness.dark : Brightness.light);
    },
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Brightness>(
        stream: select('theme'),
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(brightness: snapshot.data),
            home: HomePage(),
          );
        });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reactive'),
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
                onPressed: () => dispatch(Action(type: 'show-widget')),
                child: Text('Show Widget'),
              ),
              RaisedButton(
                onPressed: () => dispatch(Action(type: 'hide-widget')),
                child: Text('Hide Widget'),
              ),
            ],
          ),
          StreamBuilder<String>(
            stream: storeInstance().actions.whereTypes(
                ['show-widget', 'hide-widget']).map((action) => action.type),
            initialData: 'hide-widget',
            builder: (context, snapshot) {
              return snapshot.data == 'show-widget'
                  ? DynamicWidget()
                  : Container();
            },
          ),
          RaisedButton(
            onPressed: () => dispatch(ThemeToggleAction()),
            child: Text('Toggle Theme'),
          ),
        ],
      )),
    );
  }
}

class DynamicWidget extends StatelessWidget {
  final _effectKey = 'effectKey';

  void _addEffectForAsyncInc() {
    storeInstance().registerEffect(
      (action$, store$) => action$
          .whereType('AsyncInc')
          .debounceTime(Duration(milliseconds: 500))
          .map((event) => Action(type: 'Dec')),
      effectKey: _effectKey,
    );
  }

  void _removeEffect([bool isDisposing = false]) {
    storeInstance().unregisterEffect(effectKey: _effectKey);
  }

  String getMessage(bool hasEffect) {
    return hasEffect
        ? "Effect added successfully.\nNow click on the [Async +] button and see it's not working as expected."
        : 'No special effect';
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
                child: Text('Add Effect on AsyncInc action'),
              ),
              RaisedButton(
                onPressed: _removeEffect,
                child: Text('Remove effect'),
              )
            ],
          ),
          StreamBuilder<bool>(
              stream: select<SpecialEffectModel>('special-effect')
                  .map((model) => model.hasEffect),
              initialData: false,
              builder: (context, snapshot) {
                return Text(getMessage(snapshot.data),
                    style: TextStyle(fontSize: 20, color: Colors.white70));
              }),
        ],
      ),
    );
  }
}

class Counter extends StatelessWidget {
  Counter({
    Key key,
  }) : super(key: key) {
    registerSpecialEffectState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: select<SpecialEffectModel>('special-effect')
            .map((model) => model.hasState),
        initialData: false,
        builder: (context, snapshot) {
          return !snapshot.data
              ? Text('Please add counter state by clicking [Add State] button')
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () => dispatch(Action(type: 'Inc')),
                      child: Text('+'),
                    ),
                    RaisedButton(
                      onPressed: () => dispatch(Action(type: 'Dec')),
                      child: Text('-'),
                    ),
                    StreamBuilder<bool>(
                      stream: select<SpecialEffectModel>('special-effect')
                          .map((model) => model.hasEffect),
                      initialData: false,
                      builder: (context, snapshot) => RaisedButton(
                        onPressed: () => dispatch(Action(type: 'AsyncInc')),
                        child: Text(
                          'Async +',
                          style: TextStyle(
                              color: snapshot.data ? Colors.red : null),
                        ),
                      ),
                    ),
                    StreamBuilder<AsyncData<int>>(
                      stream: select('counter'),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data.asyncStatus ==
                                  AsyncStatus.Loading
                              ? CircularProgressIndicator()
                              : Text(
                                  '  ${snapshot.data.data}',
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.blue),
                                );
                        }
                        return Container();
                      },
                    ),
                  ],
                );
        });
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
          onPressed: registerCounterState,
          child: Text('Add State'),
        ),
        RaisedButton(
          onPressed: () =>
              storeInstance().unregisterState(stateName: 'counter'),
          child: Text('Remove State'),
        ),
        RaisedButton(
          onPressed: () {
            registerCounterState();
            storeInstance()
              ..unregisterEffect(effectKey: 'effectKey')
              ..importState({
                'counter': AsyncData.loaded(10),
                'theme': Brightness.dark,
                'special-effect':
                    SpecialEffectModel(hasEffect: false, hasState: true)
              });
          },
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
      stream: storeInstance().exportState(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: Text.rich(
              TextSpan(text: 'Export State\n', children: [
                TextSpan(
                    text:
                        'action:${snapshot.data[0]} \nstates:${snapshot.data[1]}',
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

class SpecialEffectModel {
  final bool hasEffect;
  final bool hasState;
  SpecialEffectModel({
    this.hasEffect,
    this.hasState,
  });

  SpecialEffectModel copyWith({
    bool hasEffect,
    bool hasState,
  }) {
    return SpecialEffectModel(
      hasEffect: hasEffect ?? this.hasEffect,
      hasState: hasState ?? this.hasState,
    );
  }

  @override
  String toString() =>
      'SpecialEffectModel(hasEffect: $hasEffect, hasState: $hasState)';
}

void registerSpecialEffectState() {
  registerState<SpecialEffectModel>(
    stateName: 'special-effect',
    initialState: SpecialEffectModel(hasEffect: false, hasState: false),
    mapActionToState: (state, action, emit) {
      switch (action.type) {
        case 'registerEffect(effectKey)':
          emit(state.copyWith(hasEffect: true));
          break;
        case 'unregisterEffect(effectKey)':
          emit(state.copyWith(hasEffect: false));
          break;
        case 'registerState(counter)':
          emit(state.copyWith(hasState: true));
          break;
        case 'unregisterState(counter)':
          emit(state.copyWith(hasState: false));
          break;
        default:
      }
    },
  );
}

void registerCounterState() {
  registerState<AsyncData<int>>(
      stateName: 'counter',
      initialState: AsyncData.loaded(10),
      mapActionToState: (state, action, emit) async {
        switch (action.type) {
          case 'Inc':
            emit(AsyncData.loaded(state.data + 1));
            break;
          case 'Dec':
            emit(AsyncData.loaded(state.data - 1));
            break;
          case 'AsyncInc':
            emit(AsyncData.loading(state.data));
            await Future.delayed(Duration(seconds: 1));
            dispatch(Action(type: 'Inc'));
            break;
          default:
        }
      });
}

enum AsyncStatus { Loading, Loaded, Error }

class AsyncData<T> {
  final T data;
  final AsyncStatus asyncStatus;
  final String error;
  AsyncData({this.data, this.asyncStatus, this.error});

  AsyncData.loaded(T data)
      : this(
          data: data,
          asyncStatus: AsyncStatus.Loaded,
          error: null,
        );

  AsyncData.error(String errorMessage, T data)
      : this(
          data: data,
          asyncStatus: AsyncStatus.Error,
          error: errorMessage,
        );
  AsyncData.loading(T data)
      : this(
          data: data,
          asyncStatus: AsyncStatus.Loading,
          error: null,
        );

  @override
  String toString() {
    return 'AsyncData(data: $data, asyncStatus: $asyncStatus, error: $error)';
  }
}
