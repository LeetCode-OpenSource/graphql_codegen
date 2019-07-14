import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'introspection.dart';

Future<Map<String, dynamic>> fetchMetadata(String endpoint,
    {bool cache = false}) async {
  Map<String, dynamic> json;
  final tmpFilePath =
      Uri.parse(join(Directory.systemTemp.path, 'gqlmeta.json'));
  final tmpfs = File.fromUri(tmpFilePath);
  if (cache) {
    final existed = tmpfs.existsSync();
    if (existed) {
      final content = await tmpfs.readAsString();
      json = jsonDecode(content);
    }
  }
  if (json == null) {
    final response = await http.post(endpoint,
        body: jsonEncode({
          'query': introspection,
        }),
        headers: {
          'content-type': 'application/json',
        });
    if (cache) {
      await tmpfs.writeAsString(response.body);
    }
    json = jsonDecode(response.body);
  }
  try {
    final List<dynamic> types = json['data']['__schema']['types'];
    final Map<String, dynamic> typeMap = {};
    for (var t in types) {
      typeMap[t['name']] = t;
    }
    return typeMap;
  } catch (e) {
    print(json);
    rethrow;
  }
}
