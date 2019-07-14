import 'package:dart_gen/dart_gen.dart';

Future<void> main() async {
  await generateSchemas('https://api.github.com/graphql',
      'dart_gen/example/*.gql', 'schema.dart');
}
