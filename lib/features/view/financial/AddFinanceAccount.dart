import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../../../../core/utils/currencyInput/currency_input_formatter_nodollarsign.dart';
import '../../../../../core/utils/formatterFloat/formater_real_to_us.dart';
import '../../controller/financial/financialController.dart';
import '../../model/financial/financial.dart';
import '../../model/formPayment.dart';

class AddFinanceAccountPage extends GetView<FinancialController> {
  var formatter = DateFormat('dd-MM-yyyy');
  final _formKey = GlobalKey<FormState>();
  late Financial financial;
  AddFinanceAccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GetBuilder<FinancialController>(initState: (state) async {
      controller.controllerDueDate.text =
          DateFormat("dd-MM-yyyy").format(DateTime.now());
    }, builder: (_) {
      return LoadingOverlay(
        isLoading: _.isLoading.value,
        progressIndicator: const CircularProgressIndicator(),
        child: Scaffold(
          appBar: AppBar(
            // backgroundColor: TemeColor.backgroud,
            title: const Text(
              "Adicionar Valores",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          backgroundColor: _.colorContainer,
          body: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "R\$ ",
                          style: TextStyle(
                              color: Colors.white, fontSize: width * 0.06),
                        ),
                        Flexible(
                          child: _fieldValue(context),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Radio(
                          activeColor: Colors.green[900],
                          value: 0,
                          groupValue: _.groupValueRadio,
                          onChanged: (int? value) {
                            _.selectRadio(value);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.01),
                          child: const Text("receita"),
                        ),
                        Radio(
                          activeColor: Colors.red[900],
                          value: 1,
                          groupValue: _.groupValueRadio,
                          onChanged: (int? value) {
                            _.selectRadio(value);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.01),
                          child: const Text("despesa"),
                        )
                      ],
                    ),
                    _fieldDescription(context),
                    _fieldDueDate(context),
                    _fieldPaymentType(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(child: _closePopup()),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(child: _confirmFinancial(_))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  _fieldValue(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return TextFormField(
      controller: controller.controllerValue,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatterNoDollarSign()
      ],
      maxLength: 10,
      style: TextStyle(fontSize: width * 0.05),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.end,
      decoration: _inputDecoration(context, '', "0,00"),
      validator: (val) {
        if (val!.isEmpty || val == '0,00') {
          return 'Campo Obrigatório!';
        } else {
          return null;
        }
      },
    );
  }

  _fieldDescription(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return TextFormField(
        controller: controller.controllerDescription,
        maxLength: 500,
        style: TextStyle(fontSize: width * 0.05),
        keyboardType: TextInputType.text,
        maxLines: 1,
        textAlign: TextAlign.start,
        decoration: _inputDecoration(context, "Descrição", ""),
        validator: (value) {
          if (value == null || controller.controllerDescription.text.isEmpty) {
            return 'Campo Obrigatório';
          } else {
            return null;
          }
        });
  }

  _fieldDueDate(BuildContext context) {
    final format = DateFormat("dd-MM-yyyy");
    return DateTimeField(
      controller: controller.controllerDueDate,
      decoration: _inputDecoration(context, "Data Vencimento", ""),
      validator: (value) {
        if (value == null && controller.controllerDueDate.text.isEmpty) {
          return 'Campo Obrigatório!';
        } else {
          return null;
        }
      },
      format: format,
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime(2100),
            builder: (context, child) => Localizations.override(
                  context: context,
                  locale: const Locale('pt', 'BR'),
                  child: child,
                ));

        if (date != null) {
          return date;
        } else {
          return currentValue;
        }
      },
    );
  }

  _fieldPaymentType(BuildContext context) {
    List<FormOfPayment> list = [
      FormOfPayment(name: 'Dinheiro', value: 0),
      FormOfPayment(name: 'Cartão', value: 1),
    ];

    return DropdownButtonFormField(
      value: list[controller.idPayment],
      decoration: _inputDecoration(context, 'Forma pagamento', ''),
      items: list.map(
        (val) {
          return DropdownMenuItem<FormOfPayment>(
              value: val, child: Text(val.name));
        },
      ).toList(),
      onChanged: (FormOfPayment? val) {
        controller.idPayment = val!.value;
      },
    );
  }

  _inputDecoration(BuildContext context, String labeText, String hintText) {
    double width = MediaQuery.of(context).size.width;
    return InputDecoration(
      hintText: hintText,
      labelText: labeText,
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white54),
      contentPadding: EdgeInsets.only(
          left: width * 0.04,
          top: width * 0.01,
          bottom: width * 0.041,
          right: width * 0.04),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 2.0,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 2.0,
        ),
      ),
    );
  }

  _saveFinancial(FinancialController _) async {
    final formatter = DateFormat('dd-MM-yyyy');
    final date = formatter.parse(controller.controllerDueDate.text);

    var data = jsonEncode(controller.financial);
    var dataDecode = jsonDecode(data);
    Map map = jsonDecode(dataDecode);
    map['id'] = controller.idFinancial;
    map['financialType'] =
        _.groupValueRadio == 0 ? TypeFinancial.receita : TypeFinancial.despesa;
    map['description'] = controller.controllerDescription.text;
    map['value'] = DoubleFormatter().formatter(controller.controllerValue.text);
    map['paymentType'] = controller.idPayment == 0 ? 0 : controller.idPayment;
    map['dueDate'] = date.toIso8601String();
    map['idCostCenter'] = 1;
    map['creationDate'] = controller.idFinancial == 0
        ? DateTime.now().toIso8601String()
        : map['creationDate'];
    map['origin'] = 1;
    await _.load(true.obs);
    await _.postFinancial(map, controller.idFinancial);

    if (_.post == true) Get.back();
  }

  _closePopup() {
    return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ))),
        onPressed: () {
          Get.back();
        },
        child: const Text("Cancelar",
            style: TextStyle(color: Colors.white, fontSize: 20)));
  }

  _confirmFinancial(FinancialController _) {
    return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ))),
        onPressed: () {
          if (_formKey.currentState!.validate()) _saveFinancial(_);
        },
        child: Text("Confirmar",
            style: TextStyle(
              fontSize: 20,
              color: _.colorTextButtom,
              fontWeight: FontWeight.bold,
            )));
  }
}
