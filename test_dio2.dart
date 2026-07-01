import 'package:dio/dio.dart';
void main() async {
  var options = BaseOptions(baseUrl: 'http://localhost:5247/api/v1');
  var dio = Dio(options);
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    print(options.uri);
    handler.reject(DioException(requestOptions: options));
  }));
  try {
    await dio.get('/auth/register/');
  } catch (e) {}
}
