import 'package:graphql_parser/graphql_parser.dart';

class TypeMeta {
  const TypeMeta(this.isList, this.isNullable, this.typeName);

  final bool isList;

  final bool isNullable;

  final TypeNameContext typeName;
}
