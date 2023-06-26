import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String apod(String path) => kDebugMode == true
      ? "http://10.0.2.2:5001/api/$path"
      : "https://apis.igic.com.br/api/$path";

}

