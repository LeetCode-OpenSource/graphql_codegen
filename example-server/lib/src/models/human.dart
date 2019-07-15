import 'package:angel_model/angel_model.dart';
import 'package:angel_serialize/angel_serialize.dart';
import 'package:collection/collection.dart';
import 'package:graphql_schema/graphql_schema.dart';
import 'character.dart';
import 'episode.dart';
part 'human.g.dart';

@graphQLClass
abstract class _Human extends Model implements Character {

  List<Character> get friends;

  int get totalCredits;
}
