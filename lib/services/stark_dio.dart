import 'package:dio/dio.dart';

import '../model/mensagem.dart';
import 'rest_client_response.dart';

class StarkDio {
  late final Dio dio = Dio();
  Future<void> get() async {
    Dio dio = Dio();

    try {
      Response response =
          await dio.get('https://0fb6-179-42-27-126.ngrok-free.app/');
      print(response.data);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<RestClientResponse<T>> post<T>(String path,
      {data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _dioResponseConverter(response);
    } on DioError catch (e) {
      _throwRestClientException(e);
    }
  }

  Future<RestClientResponse<T>> _dioResponseConverter<T>(
      Response<dynamic> response) async {
    return RestClientResponse<T>(
      data: response.data,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );
  }

  Never _throwRestClientException(DioError dioError) {
    final response = dioError.response;
    throw RestClientException(
      error: dioError.error,
      message: response?.statusMessage,
      statusCode: response?.statusCode,
      response: RestClientResponse(
          data: response?.data,
          statusCode: response?.statusCode,
          statusMessage: response?.statusMessage),
    );
  }
}

class RestClientException implements Exception {
  String? message;
  int? statusCode;
  dynamic error;
  RestClientResponse response;

  RestClientException({
    required this.error,
    required this.response,
    this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'RestClientException(message: $message, statusCode: $statusCode, error: $error, response: $response)';
  }
}
