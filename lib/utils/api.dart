import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:payments/utils/constants.dart';
import 'package:payments/utils/exceptions.dart';

class Api {
  //Api routes
  //

  static Map<String, dynamic> razorPayHeaders() {
    final keyAndSecretId = "$razorPayKeyId:$razorPaySecretKeyId";
    final bytes = utf8.encode(keyAndSecretId);
    final base64Token = base64.encode(bytes);

    return {"Authorization": "Basic $base64Token"};
  }

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    required bool? useAuthToken,

    /*
    this means it will throw error if success/status from api return false/0
    {
      "error" : true,
      "message" : "",
    }

    If this is true then it will throw exception

    */
    bool? throwErrorOnSuccessResponse, //By default it is true
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body, ListFormat.multiCompatible);

      final response = await dio.post(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: Options(
              headers: (headers == null)
                  ? (useAuthToken ?? true)
                      ? {} //Use header here
                      : {}
                  : headers));

      if (throwErrorOnSuccessResponse ?? true) {
        if (!response.data['success']) {
          throw ApiException(response.data['message'].toString());
        }
      }
      return Map.from(response.data);
    } on DioError catch (e) {
      print(e.message);
      if (e.error is SocketException) {
        throw NetworkException("No internet");
      }
      if (e.response?.statusCode == 401) {
        throw ApiException("invalidCredential");
      }
      throw ApiException("defaultErrorMessage");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException("defaultErrorMessage");
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,

    /*
    this means it will throw error if success/status from api return false/0
    {
      "error" : true,
      "message" : "",
    }

    If this is true then it will throw exception

    */
    bool? throwErrorOnSuccessResponse, //By default it is true
  }) async {
    try {
      //
      final Dio dio = Dio();
      final response = await dio.get(url,
          queryParameters: queryParameters,
          options: Options(
              headers: (headers == null)
                  ? (useAuthToken ?? true)
                      ? {} //Use header here
                      : {}
                  : headers));

      //Check is there any error from response
      if (throwErrorOnSuccessResponse ?? true) {
        if (!response.data['success']) {
          throw ApiException(response.data['message'].toString());
        }
      }

      return Map.from(response.data);
    } on DioError catch (e) {
      print(e.message);
      throw e.error is SocketException
          ? NetworkException("noInternet")
          : ApiException("defaultErrorMessage");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException("defaultErrorMessage");
    }
  }
}
