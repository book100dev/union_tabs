
library union_tabs;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:stacked/stacked.dart';
import 'package:union_tabs/src/notification/union_scroll_notification.dart';

export 'package:flutter/physics.dart' show Tolerance;

part 'src/inner/union_inner_page_view.dart';
part 'src/inner/union_inner_scrollable.dart';
part 'src/inner/union_inner_tab_view.dart';
part 'src/inner/union_inner_tab_view_model.dart';
part 'src/inner/union_tabs_provider.dart';
part 'src/inner/tab_bar_view_model.dart';
part 'src/notification/page_behavior.dart';
part 'src/notification/page_controller.dart';
part 'src/notification/scroll_singleton.dart';
part 'src/notification/page_scroll_physics.dart';
part 'src/notification/scroll_position.dart';
part 'src/outer/union_outer_gesture_delegate.dart';
part 'src/outer/union_outer_page_view.dart';
part 'src/outer/union_outer_scroll_position.dart';
part 'src/outer/union_outer_sliver.dart';
part 'src/outer/union_outer_tab_view.dart';


//技术参考：https://www.jianshu.com/p/9e62f6b932f9