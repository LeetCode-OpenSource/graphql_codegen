import 'package:dart_gen/dart_gen.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final client = http.Client();
  final res = await client.get('https://gitlab.com/-/graphql-explorer');
  final reg = RegExp(r'"X-CSRF-Token": "(.*?)"');
  final matched = reg.firstMatch(res.body);
  await deleteCache();
  await generateSchemas('https://gitlab.com/api/graphql',
      'dart_gen/example/*.gql', 'schema.dart', headers: {
        'X-CSRF-Token': '${matched.group(1)}'
      });
}
