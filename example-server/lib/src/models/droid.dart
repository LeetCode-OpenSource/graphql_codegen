import 'package:angel_model/angel_model.dart';
import 'package:angel_serialize/angel_serialize.dart';
import 'package:graphql_schema/graphql_schema.dart';
import 'character.dart';
import 'episode.dart';
part 'droid.g.dart';

@graphQLClass
@GraphQLDocumentation(description: 'Beep! Boop!')
abstract class _Droid extends Model implements Character {
  /// Doc comments automatically become GraphQL descriptions.
  List<Character> get friends;
}
