import 'package:injectable/injectable.dart';
import 'package:redux/redux.dart';
import 'package:what_when_where/redux/app/state.dart';
import 'package:what_when_where/redux/bookmarks/actions.dart';
import 'package:what_when_where/redux/navigation/actions.dart';

@injectable
class BookmarksMiddleware {
  List<Middleware<AppState>> _middleware;
  Iterable<Middleware<AppState>> get middleware =>
      _middleware ?? (_middleware = _createMiddleware());

  BookmarksMiddleware();

  List<Middleware<AppState>> _createMiddleware() => [
        TypedMiddleware<AppState, OpenBookmarksUserAction>(_open),
        TypedMiddleware<AppState, CloseBookmarksUserAction>(_close),
      ];

  void _open(Store<AppState> store, OpenBookmarksUserAction action,
      NextDispatcher next) {
    next(action);

    store.dispatch(const SystemActionNavigation.bookmarks());
    store.dispatch(const SystemActionBookmarks.init());
  }

  void _close(Store<AppState> store, CloseBookmarksUserAction action,
      NextDispatcher next) {
    next(action);

    store.dispatch(const SystemActionBookmarks.deInit());
  }
}