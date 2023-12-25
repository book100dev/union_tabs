part of union_tabs;

class UnionInnerTabViewModel extends BaseViewModel {
  UnionInnerTabViewModel({this.tabController,this.title});
  final TabController? tabController;
  final String? title;
  void rebuild({bool scroll = false}) {
    notifyListeners();
  }
}