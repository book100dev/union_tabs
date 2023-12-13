part of union_tabs;

class PageBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
    if (!kIsWeb) return child;
    return super.buildOverscrollIndicator(context, child, details);
  }
}
