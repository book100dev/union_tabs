part of union_tabs;

class TabBarViewModel extends BaseViewModel {
  String title = '';
  int pageCount = 0;
  int lastPageCount = 0;
  bool onlyOne = false;
  Axis scrollDirection = Axis.horizontal;
  ValueChanged<int>? onTabIndexChanged;
  void update() {
    // if (kIsWeb) {
    //   onlyOne = true;
    // } else {
    //   if (pageCount > 1 && lastPageCount != pageCount) {
    //     onlyOne = false;
    //   } else {
    //     onlyOne = true;
    //   }
    // }
    if (pageCount > 1 && lastPageCount != pageCount) {
        onlyOne = false;
      } else {
        onlyOne = true;
      }

    notifyListeners();
  }
}
