// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as Getx;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import '../endpoints/api_endpoints.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class RestClient extends GetxService {
  Dio _dio = Dio();
  //this is for header
  static header() => {
        'Content-Type': 'application/json',
      };

  Future<RestClient> init(int idCompany, String token) async {
    _dio = Dio(BaseOptions(headers: header()));
    await initInterceptors(idCompany, token);
    await 1.delay();
    return this;
  }

  Future initInterceptors(int idCompany, String token) async {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['tenantid'] = idCompany;
      // options.headers['Authorization'] = 'Bearer $token';
      options.connectTimeout = 5000;
      return handler.next(options);
    }, onResponse: (response, handler) {
      return handler.next(response);
    }, onError: (err, handler) {
      return handler.next(err);
    }));
  }

  Future<dynamic> request({
    required String url,
    required Method method,
    Map<String, dynamic>? params,
    List<Map>? paramsList,
    FormData? formData,
  }) async {
    Response response;

    try {
      url = ApiEndpoints.apod(url);
      if (method == Method.POST) {
        if (formData != null) {
          response = await _dio.post(
            url,
            data: formData,
          );
        } else if (paramsList != null && paramsList.isNotEmpty) {
          response = await _dio.post(url, data: paramsList);
        } else {
          response = await _dio.post(url, data: params);
        }
      } else if (method == Method.DELETE) {
        if (params != null) {
          response = await _dio.delete(url, data: params);
        } else {
          response = await _dio.delete(url);
        }
      } else if (method == Method.PUT) {
        if (formData != null) {
          response = await _dio.put(url, data: formData);
        } else {
          response = await _dio.put(url, data: params);
        }
      } else {
        response = await _dio.get(
          url,
          queryParameters: params,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception("");
      } else if (response.statusCode == 500) {
        throw Exception("Server Error");
      } else {
        throw Exception("Something Went Wrong");
      }
    } on SocketException {
      throw Exception("No Internet Connection");
    } on FormatException {
      throw Exception("Bad Response Format!");
    } on DioError catch (e) {
      if (e.response != null && e.response!.statusCode == 401) {
        Get.snackbar(
          "Expirado!",
          "Acesso expirado, favor logar novamente!",
          icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.yellow,
          duration: const Duration(seconds: 5),
          shouldIconPulse: true,
        );
      } else {
        print(e.response);
        Get.snackbar(
          "Falha!",
          "Falha na Conexão. Favor entrar em contato com o suporte!",
          icon: const Icon(Icons.privacy_tip_outlined, color: Colors.black),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
          shouldIconPulse: true,
        );
      }
    } catch (e) {
      throw Exception("Something Went Wrong");
    }
  }
}
