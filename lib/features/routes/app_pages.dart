import 'package:get/get_navigation/src/routes/get_route.dart';
import '../bindings/financial/financial_binding.dart';
import '../view/financial/AddFinanceAccount.dart';

import '../view/financial/FinancialPage.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: Routes.INITIAL, page: () => FinancialPage(), binding: FinancialBinding()),
    GetPage(
        name: Routes.FINANCIAL,
        page: () => FinancialPage(),
        binding: FinancialBinding()),
    
    GetPage(
        name: Routes.ADDFINANCEACCOUNT,
        page: () => AddFinanceAccountPage(),
        binding: FinancialBinding()),
  
  ];
}
