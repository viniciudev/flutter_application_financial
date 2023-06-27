
import 'package:get/get.dart';
import '../core/network/rest_client.dart';

class BaseController extends GetxController {
  late RestClient restClient;

  @override
  onInit() {
    super.onInit();
    restClient = Get.find();
  }

}