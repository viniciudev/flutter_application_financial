import 'package:get/get.dart';

import '../../controller/financial/financialController.dart';
import '../../repository/financial/financial_repository.dart';

class FinancialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FinancialController>(() {
      return FinancialController(repository: FinancialRepository());
    });
  }
}