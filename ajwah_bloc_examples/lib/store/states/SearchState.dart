import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_examples/actionTypes.dart';

class SearchModel {
  final bool isLoading;
  final String error;
  final List<String> data;
  SearchModel({this.isLoading, this.error, this.data});
  SearchModel.init() : this(isLoading: false, error: '', data: ['No data']);
  SearchModel.loading()
      : this(isLoading: true, error: '', data: ['Loading...']);
  SearchModel.searchData(List<String> data)
      : this(isLoading: false, error: '', data: data);
}

class SearchState extends BaseState<SearchModel> {
  SearchState() : super(name: 'search', initialState: SearchModel.init());

  Stream<SearchModel> mapActionToState(
      SearchModel state, Action action) async* {
    switch (action.type) {
      case ActionTypes.SearchInput:
        yield SearchModel.loading();
        break;
      case ActionTypes.SearchData:
        yield SearchModel.searchData(action.payload);
        break;
      default:
        yield state;
    }
  }
}
