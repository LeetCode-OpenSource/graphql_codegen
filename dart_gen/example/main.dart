import 'package:dart_gen/dart_gen.dart';

Future<void> main() async {
  await generateSchemas(
      'https://dev.lingkou.work/graphql?',
      'dart_gen/example/{coin_reward,question_topics,topics_list}.gql',
      'schema.dart');
}
