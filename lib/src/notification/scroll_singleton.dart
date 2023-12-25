part of union_tabs;

class ScrollSingleton {
  ScrollSingleton._internal();
  
  factory ScrollSingleton() => _instance;

  bool scrolling = false;
  
  static late final ScrollSingleton _instance = ScrollSingleton._internal();
}