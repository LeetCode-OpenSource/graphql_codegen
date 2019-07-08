import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'operation_visitor.dart';
import 'scalar_type_mapping.dart';

class FieldVisitor extends SimpleVisitor {
  FieldVisitor(
      this.typeMap, this.subTypeMap, this.operationName, this.graphqlTypeMeta,
      {Tap tap})
      : super(tap: tap) {
    schemaName =
        '$operationName${capitalizeUpperCase(graphqlTypeMeta.fieldName)}';
    _schemaDef = '$schemaName ${graphqlTypeMeta.fieldName};';
  }

  final Map<String, dynamic> typeMap;

  final Map<String, dynamic> subTypeMap;

  final String operationName;

  FieldMeta graphqlTypeMeta;

  String schemaName;

  String _result = '';

  String _schemaDef;

  String get schemaDef {
    return _schemaDef;
  }

  @override
  String getResult() {
    return _result;
  }

  @override
  List<FieldElement> visitField(FieldElement field) {
    if (field.selectionSet != null) {
      final childFiledsResults = OperationVisitor.generateFromSelection(
          schemaName,
          operationName,
          graphqlTypeMeta.name,
          field.selectionSet.selections,
          typeMap);
      _result += childFiledsResults;
    } else {
      final fieldMeta = OperationVisitor.findDeepOfType(subTypeMap[field.name]);
      final typeName = fieldMeta.isEnum
          ? '${capitalizeUpperCase(fieldMeta.name)}'
          : ScalarTypeMapping[fieldMeta.name];
      if (fieldMeta.isList) {
        _schemaDef = 'List<$typeName> ${field.name};\n';
      } else {
        _schemaDef = '$typeName ${field.name};\n';
      }
    }
    return super.visitField(field);
  }
}
