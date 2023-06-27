import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controller/financial/financialController.dart';
import '../../model/financial/financialGroupedDay.dart';
import '../../repository/financial/financial_repository.dart';

class FinancialPage extends GetView<FinancialController> {
  String saldoAtual = "";
  bool recDesp = false;

  var dataAtual = DateTime.now();
  var formatter = DateFormat('dd-MM-yyyy');
  var formatterCalendar = DateFormat('MM-yyyy');
  late String dataFormatada;
  var dateCalendar = DateTime.now();
  var currentLast = '';
  FinancialPage({super.key});
  @override
  final FinancialController controller =
      Get.put(FinancialController(repository: FinancialRepository()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FinancialController>(
          autoRemove: false,
          initState: (state) async {
            controller.dateTimeSelected = DateTime.now();
            controller.scrollController.addListener(() {
              if (controller.scrollController.offset ==
                  controller.scrollController.position.maxScrollExtent) {
                controller.fetchPage();
              }
            });
            
            await controller.fetchPageInit(1);
          },
          builder: (_) {
            return LoadingOverlay(
                isLoading: _.isLoading.value,
                color: Colors.grey,
                progressIndicator: const CircularProgressIndicator(),
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                        title: const Text('Transações'),
                        expandedHeight: 150,
                        flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 40),
                                child: SafeArea(
                                  child: Wrap(
                                      children: [tableCalendar(), totalsTop()]),
                                )))),
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      childCount: controller.financialGroupedDay.length,
                      (context, index) {
                        return listDadaFinancial(
                            controller.financialGroupedDay[index]);
                      },
                    ))
                  ],
                ));
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          controller
              .addFinanceAccount()
              .then((value) => controller.fetchPageInit(1));
        },
        mini: true,
        child: const Icon(Icons.add),
      ),
    );
  }

  tableCalendar() {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
        child: TableCalendar(
          onPageChanged: (date) async {
            dateCalendar = date;
            Map<String, dynamic> map = {
              'initialDate': DateTime(date.year, date.month, date.day),
              'finalDate': DateTime(date.year, date.month, date.day)
            };
            controller.dateTimeSelected = date;
            controller.fetchPageInit(1);
          },
          firstDay: DateTime.utc(2021, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: dateCalendar,
          locale: "pt_BR",
          headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM(locale).format(date).toUpperCase(),
              formatButtonVisible: false,
              leftChevronMargin: const EdgeInsets.fromLTRB(40, 0, 0, 0),
              rightChevronMargin: const EdgeInsets.fromLTRB(0, 0, 40, 0),
              // decoration: BoxDecoration(color: TemeColor.backgroud),
              headerPadding: const EdgeInsets.all(0),
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: Colors.white),
              titleCentered: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
              )),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
          ),
          daysOfWeekVisible: false,
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.transparent),
            weekendStyle: TextStyle(color: Colors.transparent),
          ),
          rowHeight: 0,
          calendarFormat: CalendarFormat.month,
        ),
      ),
    );
  }

  totalsTop() {
    final formatterCurrency = NumberFormat.currency(locale: "eu", symbol: '');
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                children: [
                  const Text(
                    "Total Receitas",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "R\$${formatterCurrency.format(_currentBalance(controller))}",
                    style: const TextStyle(
                        color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
            height: 40,
            child: VerticalDivider(
              color: Colors.grey,
              indent: 5,
            )),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                children: [
                  const Text(
                    "Total Despesas",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "R\$${formatterCurrency.format(_currentExpenses(controller))}",
                    style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  listDadaFinancial(FinancialGroupedDay financialGroupedDay) {
    final formatterCurrency = NumberFormat.currency(locale: "eu", symbol: '');
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Wrap(
        children: [
          Text(
              DateFormat.MEd('pt-BR')
                  .format(DateTime.parse(financialGroupedDay.date)),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children: financialGroupedDay.financials
                .map(
                  (e) => Slidable(
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) async {
                            await controller.deleteFinancial(e.id);
                            await _updateValues();
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            controller
                                .editFinanceAccount(e)
                                .then((value) => controller.fetchPageInit(1));
                          },
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Editar',
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Card(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.white70, width: 1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: e.financialType == TypeFinancial.receita
                              ? const Icon(
                                  Icons.arrow_downward_rounded,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.red,
                                )),
                      title: Text(e.description),
                      trailing: e.financialType == TypeFinancial.receita
                          ? Text(
                              "+ "
                              "R\$${formatterCurrency.format(e.value)}",
                              style: const TextStyle(color: Colors.green),
                            )
                          : Text(
                              "- "
                              "R\$${formatterCurrency.format(e.value)}",
                              style: const TextStyle(color: Colors.red),
                            ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  _updateValues() async {
    await controller.fetchPageInit(1);
  }

  _currentBalance(FinancialController _) {
    double resultBalance = 0;
    for (var element in _.getAllListAppend) {
      if (element.financialType == TypeFinancial.receita) {
        resultBalance += element.value;
      }
    }

    return resultBalance;
  }

  _currentExpenses(FinancialController _) {
    double resultBalance = 0;
    for (var element in _.getAllListAppend) {
      if (element.financialType == TypeFinancial.despesa) {
        resultBalance += element.value;
      }
    }

    return resultBalance;
  }
}

class TypeFinancial {
  static int receita = 0;
  static int despesa = 1;
}
