import 'package:get/get.dart';

import '../../../../core/network/rest_client.dart';

class FinancialRepository {
  FinancialRepository();

  final apiClient = Get.find<RestClient>();

  Future<dynamic> post(map) async {
    return await apiClient.request(
        url: 'financialClient/PostApp', method: Method.POST, params: map);
  }

  Future<dynamic> getByMonth(map) async {
    return await apiClient.request(
        url: 'financialClient/getByMonth', method: Method.GET, params: map);
  }

  Future<dynamic> getByMonthSummary(map) async {
    return await apiClient.request(
        url: 'financialClientSummary', method: Method.GET, params: map);
  }

  Future<dynamic> getByYearSummary(map) async {
    return await apiClient.request(
        url: 'financialClientSummary/getByYear',
        method: Method.GET,
        params: map);
  }

  Future<dynamic> alter(map) async {
    return await apiClient.request(
        url: 'financialClient', method: Method.PUT, params: map);
  }

  Future<dynamic> getCostCenter() async {
    return await apiClient.request(
        url: 'costCenterClient/getByIdClinic', method: Method.GET);
  }
    Future<dynamic> getFormPayment() async {
    return await apiClient.request(
        url: 'formPayment/getByIdClinic', method: Method.GET);
  }

  Future<dynamic> delete(id) async {
    return await apiClient.request(
        url: 'schedulingFinancial/$id', method: Method.DELETE);
  }

  Future<dynamic> searchListToPrint(map) async {
    return await apiClient.request(
        url: 'financialClient/SearchListToPrint', method: Method.GET,params: map);
  }
    Future<dynamic> fetchToEdit(id) async {
    return await apiClient.request(
        url: 'financialClient/$id', method: Method.GET);
  }
}
