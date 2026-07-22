import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shreshtlibrary/core/network/api_client.dart';
import 'package:shreshtlibrary/core/network/token_store.dart';

void main() {
  group('ApiClient unwrapList', () {
    test('unwrapList parses <=50 items on main thread successfully', () async {
      final client = ApiClient(baseUrl: 'http://test', tokenStore: MemoryTokenStore());
      
      final mockData = List.generate(10, (index) => {'id': index, 'name': 'Item \$index'});
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {'data': mockData},
        statusCode: 200,
      );

      final result = await client.unwrapList(mockResponse, (json) => MockItem.fromJson(json));
      
      expect(result.length, 10);
      expect(result.first.id, 0);
      expect(result.last.id, 9);
    });

    test('unwrapList parses >50 items on background isolate successfully', () async {
      final client = ApiClient(baseUrl: 'http://test', tokenStore: MemoryTokenStore());
      
      // 100 items will trigger the compute logic
      final mockData = List.generate(100, (index) => {'id': index, 'name': 'Item \$index'});
      final mockResponse = Response(
        requestOptions: RequestOptions(path: ''),
        data: {'data': mockData},
        statusCode: 200,
      );

      final result = await client.unwrapList(mockResponse, (json) => MockItem.fromJson(json));
      
      expect(result.length, 100);
      expect(result.first.id, 0);
      expect(result.last.id, 99);
    });
  });
}


class MockItem {
  final int id;
  final String name;

  MockItem({required this.id, required this.name});

  factory MockItem.fromJson(Map<String, dynamic> json) {
    return MockItem(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
