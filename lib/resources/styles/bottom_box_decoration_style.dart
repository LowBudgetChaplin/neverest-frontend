import 'package:flutter/cupertino.dart';
import 'package:neverest/resources/extensions/app_selectors.dart';

class BottomBoxDecoration {
  static BoxDecoration bottomBoxDecoration(BuildContext context){
    return BoxDecoration(
      color: context.colors.bgCardDefault,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(context.shapes.cardRadius),
        topRight: Radius.circular(context.shapes.cardRadius)
      ),
      border: Border.all(
        color: context.colors.borderCardLight,
        width: 1
      )
    );
  }
}