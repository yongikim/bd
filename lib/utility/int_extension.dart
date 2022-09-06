extension PriceString on int {
  String toPriceString() {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String mathFunc(Match match) => '${match[1]},';
    String result = toString().replaceAllMapped(reg, mathFunc);
    return result;
  }
}
