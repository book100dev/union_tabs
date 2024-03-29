part of union_tabs;

enum ScrollDirection { left, right, none }

class TabBarOverScroll with ChangeNotifier {
  bool overScroll = false;
  ScrollDirection direction = ScrollDirection.none;

  void setScrollDirection(ScrollDirection direction) {
    this.direction = direction;
  }

  void setOverScroll(bool overScroll) {
    this.overScroll = overScroll;
    notifyListeners();
  }
}

class TabBarOverScrollStateProvider extends StatefulWidget {
  final WidgetBuilder? builder;

  TabBarOverScrollStateProvider({Key? key, this.builder}) : super(key: key);

  @override
  _TabBarOverScrollStateProviderState createState() =>
      _TabBarOverScrollStateProviderState();

  static TabBarOverScroll? of(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<_OverScrollStateScope>()
        ?.widget as _OverScrollStateScope;
    return scope.overScroll;
  }
}

class _TabBarOverScrollStateProviderState
    extends State<TabBarOverScrollStateProvider> {
  TabBarOverScroll _overScroll = TabBarOverScroll();

  @override
  Widget build(BuildContext context) {
    return _OverScrollStateScope(
      overScroll: _overScroll,
      child: widget.builder!(context),
    );
  }

  @override
  void dispose() {
    _overScroll.dispose();
    super.dispose();
  }
}

class _OverScrollStateScope extends InheritedWidget {
  final TabBarOverScroll? overScroll;

  const _OverScrollStateScope(
      {Key? key, this.overScroll, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
