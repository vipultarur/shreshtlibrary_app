import 'package:dio/dio.dart';
void main() {
  var options = BaseOptions(baseUrl: 'http://localhost:5247/api/v1');
  var d = Dio(options);
  var req = RequestOptions(path: '/auth/register/', baseUrl: options.baseUrl);
  print(Uri.parse(options.baseUrl).resolve(req.path));
}
