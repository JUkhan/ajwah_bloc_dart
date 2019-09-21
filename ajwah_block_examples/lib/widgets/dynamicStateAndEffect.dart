import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/store/effects/searchEffect.dart';
import 'package:ajwah_block_examples/store/states/SearchState.dart';
import 'package:ajwah_block_examples/store/states/counterState.dart';
import 'package:ajwah_block_examples/widgets/popupMenu.dart';

import 'package:flutter_web/material.dart';

class DynamicStateAndEffectWidget extends StatelessWidget {
  const DynamicStateAndEffectWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dynamic State and Effects'),
          actions: <Widget>[PopupMemu()],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('Add Search State'),
                        onPressed: () {
                          store().addState(SearchState());
                        },
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('Remove Search State'),
                        onPressed: () {
                          store().removeStateByStateName('search');
                        },
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('Add Search Effect'),
                        onPressed: () {
                          store().addEffects(SearchEffect());
                        },
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        child: Text('Remove Search Effect'),
                        onPressed: () {
                          store().removeEffectsByKey('search_effects');
                        },
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.black45,
                        child: Text('Import State'),
                        onPressed: () {
                          store().importState({"counter": CounterModel.init()});
                        },
                      ),
                    ],
                  )
                ],
              ),
              Expanded(
                child: Container(
                  child: StreamBuilder<SearchModel>(
                    stream: select('search'),
                    builder: (BuildContext context,
                        AsyncSnapshot<SearchModel> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                    prefix: snapshot.data.isLoading
                                        ? CircularProgressIndicator()
                                        : null,
                                    hintText: 'Wiki search',
                                    icon: Icon(Icons.search)),
                                onChanged: (text) {
                                  dispatch(ActionTypes.SearchInput, text);
                                },
                              ),
                              Expanded(
                                  child: ListView.builder(
                                itemCount: snapshot.data.data.length,
                                itemBuilder: (context, position) {
                                  return ListTile(
                                    title: Text(snapshot.data.data[position]),
                                  );
                                },
                              )),
                            ]);
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      return Center(
                          child: Text('Search state has been removed'));
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
