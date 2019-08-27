import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class SearchEffect extends BaseEffect {
  SearchEffect() : super(effectKey: 'search_effects');

  Future<List<String>> search(String input) async {
    var url =
        'https://en.wikipedia.org/w/api.php?&origin=*&action=opensearch&search=${input}&limit=5';

    try {
      var response = await http.get(url);
      var jsonResponse = convert.jsonDecode(response.body);
      return (jsonResponse[1] as List).cast<String>();
    } catch (err) {
      return [];
    }
  }

  Observable<Action> effectForSearch(Actions action$, Store store$) {
    return action$
        .ofType(ActionTypes.SearchInput)
        .debounceTime(Duration(milliseconds: 450))
        .distinct()
        .switchMap((action) => Observable.fromFuture(search(action.payload)))
        .map((data) => Action(type: ActionTypes.SearchData, payload: data));
  }

  List<Observable<Action>> registerEffects(Actions action$, Store store$) {
    return [effectForSearch(action$, store$)];
  }
}
