import 'package:get/get.dart';

import '../../../../core/network/rest_client.dart';

class FinancialRepository {
  FinancialRepository();

  final apiClient = Get.find<RestClient>();

  Future<dynamic> post(map) async {
    return await apiClient.request(
        url: 'financial', method: Method.POST, params: map);
  }

  Future<dynamic> getByMonth(map) async {
    return await apiClient.request(
        url: 'financial/getByIdCompany', method: Method.GET, params: map);
  }

  Future<dynamic> alter(map) async {
    return await apiClient.request(
        url: 'financial', method: Method.PUT, params: map);
  }
  Future<dynamic> delete(id) async {
    return await apiClient.request(
        url: 'financial/$id', method: Method.DELETE);
  }
}
