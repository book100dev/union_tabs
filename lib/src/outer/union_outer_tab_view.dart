part of union_tabs;

class UnionOuterTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const UnionOuterTabBarView({
    Key? key,
    required this.tabBarViewModel,
    required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(children != null),
        assert(dragStartBehavior != null),
        super(key: key);

  final TabBarViewModel tabBarViewModel;

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// One widget per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<Widget> children;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _UnionOuterTabBarViewState createState() => _UnionOuterTabBarViewState();
}

class _UnionOuterTabBarViewState extends State<UnionOuterTabBarView> {
  TabController? _controller;
  late UnionOuterPageController _pageController;
  late List<Widget> _children;
  late List<Widget> _childrenWithKey;
  int? _currentIndex;
  int _warpUnderwayCount = 0;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  UnionOuterGestureDelegate? _gestureDelegate;

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError('No TabController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());

    if (newController == _controller) return;

    if (_controllerIsValid)
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    _controller = newController;
    if (_controller != null)
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
  }

  void _updateGestureDelegate() {
    _gestureDelegate = UnionOuterGestureDelegate(
        pageController: _pageController, tabController: _controller!);
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
    //手动切换tab。子page 的index 默认回到开始
    widget.tabBarViewModel.onTabIndexChanged = (index) {
      //切换的时候让干掉系统动画。http://jira.hualala.com/browse/HCD-92
      _currentIndex = index;
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
      _pageController.animateToPage(_currentIndex!,
          duration: Duration(milliseconds: 1), curve: Curves.easeIn);
      _innerTabBarViewToFirst();
      if (_controller != null)
        _controller!.animation!.addListener(_handleTabControllerAnimationTick);
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = _controller?.index;
    _pageController = UnionOuterPageController(initialPage: _currentIndex ?? 0);
    _updateGestureDelegate();
  }

  @override
  void didUpdateWidget(UnionOuterTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
      _updateGestureDelegate();
    }

    if (widget.children != oldWidget.children && _warpUnderwayCount == 0)
      _updateChildren();
  }

  @override
  void dispose() {
    if (_controllerIsValid)
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    _controller = null;
    // We don't own the _controller Animation, so it's not disposed here.

    _gestureDelegate?.dispose();
    super.dispose();
  }

  void _updateChildren() {
    _children = widget.children;
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  void _handleTabControllerAnimationTick() {
    if (_warpUnderwayCount > 0 || !_controller!.indexIsChanging)
      return; // This widget is driving the controller's animation.

    if (_controller!.index != _currentIndex) {
      _currentIndex = _controller!.index;
      _warpToCurrentIndex();
    }
  }

  //切换分类默认选中第一个
  Future<void> _innerTabBarViewToFirst() async {
    UnionInnerTabBarView innerTabBarView =
        _children.elementAt(_currentIndex!) as UnionInnerTabBarView;
    innerTabBarView.controller?.index = 0;
    // 当前分类之前的要跳到最后一页
    List<UnionInnerTabBarView> previousArray =
        _children.sublist(0, _currentIndex).cast<UnionInnerTabBarView>();
    previousArray.forEach((UnionInnerTabBarView element) {
      var last = element.children.last;
      int lastIndex = element.children.indexOf(last);
      element.controller?.index = lastIndex;
    });
    List<UnionInnerTabBarView> lastArray = _children
        .sublist(_currentIndex!, _children.lastIndexOf(_children.last))
        .cast<UnionInnerTabBarView>();
    lastArray.forEach((UnionInnerTabBarView element) {
      element.controller?.index = 0;
    });
  }

  Future<void> _warpToCurrentIndex() async {
    if (!mounted) return Future<void>.value();

    if (_pageController.page == _currentIndex!.toDouble())
      return Future<void>.value();

    final int previousIndex = _controller!.previousIndex;
    if ((_currentIndex! - previousIndex).abs() == 1) {
      _warpUnderwayCount += 1;
      await _pageController.animateToPage(_currentIndex!,
          duration: kTabScrollDuration, curve: Curves.ease);
      _warpUnderwayCount -= 1;
      return Future<void>.value();
    }

    assert((_currentIndex! - previousIndex).abs() > 1);
    final int initialPage = _currentIndex! > previousIndex
        ? _currentIndex! - 1
        : _currentIndex! + 1;
    final List<Widget> originalChildren = _childrenWithKey;
    setState(() {
      _warpUnderwayCount += 1;

      _childrenWithKey = List<Widget>.from(_childrenWithKey, growable: false);
      final Widget temp = _childrenWithKey[initialPage];
      _childrenWithKey[initialPage] = _childrenWithKey[previousIndex];
      _childrenWithKey[previousIndex] = temp;
    });
    _pageController.jumpToPage(initialPage);

    await _pageController.animateToPage(_currentIndex!,
        duration: kTabScrollDuration, curve: Curves.ease);
    if (!mounted) return Future<void>.value();
    setState(() {
      _warpUnderwayCount -= 1;
      if (widget.children != _children) {
        _updateChildren();
      } else {
        _childrenWithKey = originalChildren;
      }
    });
  }

  // Called when the PageView scrolls
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_warpUnderwayCount > 0) return false;

    if (notification.depth != 0) return false;

    _warpUnderwayCount += 1;
    if (notification is ScrollUpdateNotification &&
        !_controller!.indexIsChanging) {
      if ((_pageController.page! - _controller!.index).abs() > 1.0) {
        _controller!.index = _pageController.page!.floor();
        _currentIndex = _controller!.index;
      }
      _controller!.offset =
          (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
    } else if (notification is ScrollEndNotification) {
      _controller!.index = _pageController.page!.round();
      _currentIndex = _controller!.index;
      if (!_controller!.indexIsChanging)
        _controller!.offset =
            (_pageController.page! - _controller!.index).clamp(-1.0, 1.0);
    }
    _warpUnderwayCount -= 1;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.children.length) {
        throw FlutterError(
            "Controller's length property (${_controller!.length}) does not match the "
            "number of tabs (${widget.children.length}) present in TabBar's tabs property.");
      }
      return true;
    }());

    return NotificationListener<UnionScrollNotification>(
      onNotification: (UnionScrollNotification notification) {
        return _gestureDelegate!
            .handleUnionScrollNotification(context, notification);
      },
      child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: ViewModelBuilder<TabBarViewModel>.reactive(
              viewModelBuilder: () => widget.tabBarViewModel,
              // onViewModelReady: (model) => model.init(),
              builder: (context, viewModel, child) => UnionOuterPageView(
                    scrollDirection: viewModel.scrollDirection,
                    dragStartBehavior: widget.dragStartBehavior,
                    controller: _pageController,
                    physics: viewModel.onlyOne
                        ? const PageScrollPhysics().applyTo(widget.physics ??
                            PageScrollPhysics()
                                .applyTo(const ClampingScrollPhysics()))
                        : NeverScrollableScrollPhysics(),
                    children: _childrenWithKey,
                  ))),
    );
  }
}
