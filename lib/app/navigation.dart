import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Goes back one page, or Home when there is nothing to go back to (e.g. a
/// page opened straight from its web address in the browser preview).
void goBackOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}
