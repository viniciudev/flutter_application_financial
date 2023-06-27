import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String apod(String path) => kDebugMode == true
      ? "http://10.0.2.2:5001/api/$path"
      : "https://apis.igic.com.br/api/$path";

  static String registerLink() => kDebugMode == true
      ? "http://homolog.igic.com.br/register"
      : "https://app.igic.com.br/register";
}
//"http://10.0.2.2:5001/api/$path""https://apihomolog.igic.com.br/api/$path"
 // "https://3b32-189-37-77-252.sa.ngrok.io/api/$path"
