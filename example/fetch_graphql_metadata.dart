import 'dart:convert';
import 'package:http/http.dart' as http;

import 'introspection.dart';

Future<Map<String, dynamic>> fetchMetadata(String endpoint) async {
  final response = await http.post(endpoint,
      body: jsonEncode({
        'query': introspection,
      }),
      headers: {
        'content-type': 'application/json',
      });
  List<dynamic> types = jsonDecode(response.body)['data']['__schema']['types'];
  final Map<String, dynamic> typeMap = new Map();
  types.forEach((t) {
    typeMap[t['name']] = t;
  });

  return typeMap;
}
