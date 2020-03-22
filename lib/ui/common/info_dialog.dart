import 'package:flutter/material.dart';
import 'package:what_when_where/resources/dimensions.dart';
import 'package:what_when_where/resources/strings.dart';
import 'package:what_when_where/ui/common/gradient_decoration.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String content;

  const InfoDialog({Key key, this.title, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Theme.of(context).accentColor),
        ),
        content: Container(
          foregroundDecoration: GradientDecoration(
              color: Theme.of(context).dialogBackgroundColor),
          child: SingleChildScrollView(
            padding: Dimensions.dialogContentPadding,
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(Strings.close),
          ),
        ],
      );
}
