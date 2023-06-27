class DoubleFormatter {
  formatter(String value) {
    if (value != '') {
      var amount = value.replaceAll(RegExp('[\\R\\ \\\$]'), '');

      var amountfinal = amount.replaceAll(RegExp('[\\. ]'), '');
      var amountfinalUS = amountfinal.replaceAll(RegExp(r','), '.');
      return double.parse(amountfinalUS);
    }
  }
}
