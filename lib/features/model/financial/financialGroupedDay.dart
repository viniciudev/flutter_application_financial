import 'financial.dart';

class FinancialGroupedDay {
  late String date;
  late List<Financial> financials;

  FinancialGroupedDay({required this.date, required this.financials});

  FinancialGroupedDay.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    if (json['financials'] != null) {
      financials = <Financial>[];
      json['financials'].forEach((v) {
        financials.add(Financial.fromMap(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (financials.isNotEmpty) {
      data['financials'] = financials.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static List<FinancialGroupedDay> fromJsonList(List list) {
    return list.map((item) => FinancialGroupedDay.fromJson(item)).toList();
  }
}
