import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Financial {
  int financialStatus = 0;
  int financialType = 0;
  String creationDate = '';
  String description = '';
  double value = 0;
  int paymentType = 0;
  String dueDate = '';
  int idCostCenter = 0;
  int id = 0;
  String? namePayment;
  Financial(
      {this.financialStatus = 0,
      this.financialType = 0,
      this.creationDate = '',
      this.description = '',
      this.value = 0,
      this.paymentType = 0,
      this.dueDate = '',
      this.idCostCenter = 0,
      this.id = 0,
      this.namePayment});
  static List<Financial> fromJsonList(List list) {
    return list.map((item) => Financial.fromMap(item)).toList();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'financialStatus': financialStatus,
      'financialType': financialType,
      'creationDate': creationDate,
      'description': description,
      'value': value,
      'payment': paymentType,
      'dueDate': dueDate,
      'idCostCenter': idCostCenter,
      'id': id,
      'namePayment': namePayment
    };
  }

  factory Financial.fromMap(Map<String, dynamic> map) {
    return Financial(
      financialStatus: map['financialStatus'] as int,
      financialType: map['financialType'] as int,
      creationDate: map['creationDate'] as String,
      description: map['description'] as String,
      value: map['value'] as double,
      paymentType: map['paymentType'] as int,
      dueDate: map['dueDate'] as String,
      idCostCenter: map['idCostCenter'] as int,
      id: map['id'] as int,
      namePayment:
          map['namePayment'] != null ? map['namePayment'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Financial.fromJson(String source) =>
      Financial.fromMap(json.decode(source) as Map<String, dynamic>);
}
