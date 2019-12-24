import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_examples/actionTypes.dart';
import 'package:ajwah_bloc_examples/store/states/counterState.dart';
import 'package:ajwah_bloc_examples/widgets/popupMenu.dart';
import 'package:flutter/material.dart';

class CounterComponent extends StatelessWidget {
  const CounterComponent({Key key}) : super(key: key);

  void increment() {
    dispatch(ActionTypes.Inc);
  }

  void decrement() {
    dispatch(ActionTypes.Dec);
  }

  void asyncIncrement() {
    dispatch(ActionTypes.AsyncInc);
  }

  @override
  Widget build(BuildContext context) {
    //var store=AppStateProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
        actions: <Widget>[PopupMemu()],
      ),
      body: Container(
          child: Row(
        children: <Widget>[
          ButtonBar(mainAxisSize: MainAxisSize.min, children: <Widget>[
            RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: Icon(Icons.add),
              onPressed: increment,
            ),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: Text('Async(+)'),
              onPressed: asyncIncrement,
            ),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.blue,
              child: Icon(Icons.remove),
              onPressed: decrement,
            ),
          ]),
          SizedBox(
            width: 10.0,
          ),
          StreamBuilder<CounterModel>(
            stream: select('counter'),
            builder:
                (BuildContext context, AsyncSnapshot<CounterModel> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isLoading) {
                  return CircularProgressIndicator();
                }
                return Text(
                  snapshot.data.count.toString(),
                  style: Theme.of(context).textTheme.title,
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return CircularProgressIndicator();
            },
          )
        ],
      )),
    );
  }
}
