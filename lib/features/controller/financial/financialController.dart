import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/financial/financial.dart';
import '../../model/financial/financialGroupedDay.dart';
import '../../repository/financial/financial_repository.dart';
import '../../routes/app_routes.dart';

class FinancialController extends GetxController {
  final FinancialRepository repository;
  FinancialController({required this.repository});
  DateTime dateTimeSelected = DateTime.now();

  int groupValueRadio = 0;
  Color colorContainer = Colors.green.shade400;
  Color colorTextButtom = Colors.green;
  selectRadio(int? value) {
    if (value == 0) {
      groupValueRadio = 0;
      colorContainer = Colors.green.shade400;
      colorTextButtom = Colors.green;
    } else {
      groupValueRadio = 1;
      colorContainer = Colors.red.shade300;
      colorTextButtom = Colors.red.shade300;
    }
    update();
  }

  RxBool isLoading = false.obs;
  load(RxBool value) {
    isLoading = value;
    update();
  }

  final _post = false.obs;
  get post => _post.value;
  set post(value) => _post.value = value;

  postFinancial(map, id) async {
    if (id > 0) {
      await repository
          .alter(map)
          .then((value) => {post = value, load(false.obs)})
          .catchError((error) => {load(false.obs), print(error)});
    } else {
      await repository
          .post(map)
          .then((value) => {post = value, load(false.obs)})
          .catchError((error) => {load(false.obs), print(error)});
    }
  }

  final _delete = false.obs;
  get delete => _delete.value;
  set delete(value) => _delete.value = value;

  deleteFinancial(id) async {
    load(true.obs);
    await repository
        .delete(id)
        .then((value) => {
              delete = value,
            })
        .catchError((error) => {load(false.obs)});
  }

  List<Financial> getList = <Financial>[];

  getByMonth(int pageNumber, int pageSize) async {
    DateTime date = dateTimeSelected;
    Map<String, dynamic> map = {
      'saleDate': DateTime(date.year, date.month).toIso8601String(),
      'saleDateFinal': DateTime(
        date.year,
        date.month,
      ).add(const Duration(days: 30)).toIso8601String(),
      'pageNumber': pageNumber,
      'pageSize': pageSize
    };
    await repository
        .getByMonth(map)
        .then((value) => {
              getList = Financial.fromJsonList(value),
            })
        .catchError((error) => {print(error)});
  }

  Future<dynamic> addFinanceAccount() async {
    await clearFields();
    await Get.toNamed(Routes.ADDFINANCEACCOUNT, arguments: {'data': financial});
  }

  Future<dynamic> editFinanceAccount(e) async {
    await fillFields(e);
    await Get.toNamed(Routes.ADDFINANCEACCOUNT, arguments: {'data': financial});
  }

  Financial financial = Financial();

  int idFinancial = 0;
  int idCostCenter = 0;
  final TextEditingController controllerValue = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final TextEditingController controllerDueDate = TextEditingController();
  TextEditingController controllerTax = TextEditingController();
  final TextEditingController controllerDiscount = TextEditingController();
  final TextEditingController controllerFines = TextEditingController();
  int idPayment = 1;

  fillFields(financial) async {
    idFinancial = financial.id;
    final formatter = NumberFormat.currency(locale: "eu", symbol: '');
    controllerValue.text = formatter.format(financial.value);
    controllerDescription.text = financial.description;
    final formatterDate = DateFormat("dd-MM-yyyy");
    controllerDueDate.text =
        formatterDate.format(DateTime.parse(financial.dueDate));
    idPayment = financial.paymentType;
    if (financial.financialType == TypeFinancial.receita) {
      groupValueRadio = 0;
      colorContainer = Colors.green.shade400;
      colorTextButtom = Colors.green;
    } else {
      groupValueRadio = 1;
      colorContainer = Colors.red.shade300;
      colorTextButtom = Colors.red.shade300;
    }
  }

  clearFields() async {
    idFinancial = 0;
    final formatter = NumberFormat.currency(locale: "eu", symbol: '');
    controllerValue.text = '';
    controllerDescription.text = '';
    final formatterDate = DateFormat("dd-MM-yyyy");
    controllerDueDate.text = '';
    idPayment = 0;
    idCostCenter = 0;
    controllerDiscount.text = '';
    controllerTax.text = '';
    controllerFines.text = '';
  }

  final int _pageSize = 10;
  int _pageKey = 0;
  ScrollController scrollController = ScrollController();
  List<Financial> getAllListAppend = <Financial>[];
  List<FinancialGroupedDay> financialGroupedDay = <FinancialGroupedDay>[];
  fetchPageInit(pageKey) async {
    load(true.obs);
    getAllListAppend.clear();
    financialGroupedDay.clear();
    try {
      _pageKey = pageKey;

      await getByMonth(
        _pageKey,
        _pageSize,
      );
      if (getList.isNotEmpty) {
        getAllListAppend.addAll(getList);
        Map<String, List<Financial>> inclusionDateMap =
            getAllListAppend.groupBy((m) => DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(m.creationDate)));

        inclusionDateMap.forEach((key, value) {
          financialGroupedDay
              .add(FinancialGroupedDay(date: key, financials: value));
        });
      }
    } catch (error) {
      load(false.obs);
    }
    load(false.obs);
  }

  fetchPage() async {
    load(true.obs);
    try {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        _pageKey++;

        await getByMonth(
          _pageKey,
          _pageSize,
        );
        if (getList.isNotEmpty) {
          financialGroupedDay.clear();
          getAllListAppend.addAll(getList);
          Map<String, List<Financial>> inclusionDateMap =
              getAllListAppend.groupBy((m) => DateFormat("yyyy-MM-dd")
                  .format(DateTime.parse(m.creationDate)));

          inclusionDateMap.forEach((key, value) {
            financialGroupedDay
                .add(FinancialGroupedDay(date: key, financials: value));
          });
        }
      }
    } catch (error) {
      load(false.obs);
    }
    load(false.obs);
  }
}

class TypeFinancial {
  static int receita = 0;
  static int despesa = 1;
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
