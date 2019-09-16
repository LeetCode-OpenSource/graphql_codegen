import 'package:graphql_parser/graphql_parser.dart';

import 'type_meta.dart';

TypeMeta getTypeMeta(TypeContext type) {
  dynamic variableDef = type;
  var isNullable = false;
  var isList = false;
  var listCount = 0;
  while (true) {
    if (variableDef is ListTypeContext) {
      isList = true;
      listCount += 1;
      if (variableDef.type != null) {
        variableDef = variableDef.type;
      } else {
        break;
      }
    } else {
      isNullable = variableDef.isNullable;
      if (variableDef.listType != null) {
        variableDef = variableDef.listType;
      } else {
        break;
      }
    }
  }
  return TypeMeta(isList, listCount, isNullable, variableDef.typeName);
}
