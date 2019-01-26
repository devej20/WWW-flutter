import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:what_when_where/redux/app/state.dart';
import 'package:what_when_where/redux/navigation/actions.dart';
import 'package:what_when_where/ui/image/image_page.dart';
import 'package:what_when_where/ui/tour_questions/tour_details_about_dialog.dart';

class NavigationMiddleware {
  static final List<Middleware<AppState>> middleware = [
    TypedMiddleware<AppState, OpenImage>(_openImage),
    TypedMiddleware<AppState, OpenTourInfo>(_openTourInfo),
  ];

  static void _openImage(
      Store<AppState> store, OpenImage action, NextDispatcher next) {
    next(action);

    _navigateTo(
        context: action.context,
        routeName: ImagePage.routeName,
        builder: (context) => ImagePage(url: action.imageUrl));
  }

  static void _openTourInfo(
      Store<AppState> store, OpenTourInfo action, NextDispatcher next) {
    next(action);

    TourDetailsAboutDialog(tour: action.tour).show(action.context);
  }

  static void _navigateTo(
          {BuildContext context, String routeName, WidgetBuilder builder}) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: routeName), builder: builder));
}