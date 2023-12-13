part of union_tabs;

class UnionOuterGestureDelegate {
  UnionOuterPageController? pageController;
  TabController? tabController;

  UnionOuterGestureDelegate(
      {required this.pageController, required this.tabController});

  /// 用于手势下发。
  /// record the gesture.
  Drag? _drag;

  /// 将处理UnionScrollNotification.
  bool handleUnionScrollNotification(
      BuildContext context, UnionScrollNotification notification) {
    if (tabController!.index != notification.index) {
      return false;
    }

    if (notification is UnionScrollStartNotification) {
      _drag = pageController!.position.drag(notification.dragDetails!, () {
        _drag = null;
      });
    } else if (notification is UnionOverscrollNotification) {
      if (_drag == null) {
        return true;
      }

      /// 计算用户滑动
      /// update the offset, to update the indicator's position
      try {
        Axis? axis = pageController?.position.axis;
        MediaQueryData data = MediaQuery.of(context);
        if (axis == Axis.horizontal) {
          //横屏
          tabController?.offset = (tabController!.offset +
                  notification.overscroll / data.size.width)
              .clamp(-1.0, 1.0);
        } else {
          //竖屏
          tabController?.offset = (tabController!.offset +
                  notification.overscroll / data.size.height)
              .clamp(-1.0, 1.0);
        }
      } catch (e) {
        print('滑动的时候 offset error：$e');
      }
      if (notification.dragDetails != null) {
        /// update the viewpager's position
        _drag?.update(notification.dragDetails!);
      }
    } else if (notification is UnionScrollEndNotification) {
      _drag?.cancel();
      _drag = null;
      double xx = 0;
      Axis? axis = pageController?.position.axis;
      //MediaQueryData data = MediaQuery.of(context);
      if (axis == Axis.horizontal) {
        xx = notification.dragDetails?.velocity.pixelsPerSecond.dx ?? 0;
      } else {
        xx = notification.dragDetails?.velocity.pixelsPerSecond.dy ?? 0;
      }
      if (xx != 0) {
        int offset = xx > 0 ? -1 : 1;
        int index = tabController!.index + offset;
        if (index < 0) index = 0;
        if (index >= tabController!.length) index = tabController!.length - 1;

        tabController?.animateTo(index, duration: Duration(milliseconds: 500));
      }
    } else if (notification is UnionScrollUpdateNotification) {
      // if (_drag != null && notification.dragDetails != null) {
      //   /// update the viewpager's position
      //   _drag?.update(notification.dragDetails!);

      //   /// 计算用户滑动
      //   /// update the offset, to update the indicator's position
      //   MediaQueryData data = MediaQuery.of(context);
      //   if (!tabController!.indexIsChanging) {
      //     Axis? axis = pageController?.position.axis;
      //     if (axis == Axis.horizontal) {
      //       tabController?.offset = (tabController!.offset +
      //               notification.dragDetails!.delta.dx / data.size.width)
      //           .clamp(-1.0, 1.0);
      //     } else {
      //       tabController?.offset = (tabController!.offset +
      //               notification.dragDetails!.delta.dy / data.size.height)
      //           .clamp(-1.0, 1.0);
      //     }
      //   }
      // }
    }
    return true;
  }

  void dispose() {
    pageController = null;
    tabController = null;
    _drag?.cancel();
    _drag = null;
  }
}
