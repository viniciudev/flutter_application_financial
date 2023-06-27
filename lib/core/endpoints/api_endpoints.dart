import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String apod(String path) => kDebugMode == true
      ? "https://webapicommercial.azurewebsites.net/api/$path" //"http://10.0.2.2:5001/api/$path"
      : "https://webapicommercial.azurewebsites.net/api/$path";
}
