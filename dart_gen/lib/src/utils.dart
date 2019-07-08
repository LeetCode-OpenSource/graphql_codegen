import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'field_meta.dart';
import 'field_visitor.dart';
import 'tap.dart';

FieldMeta findDeepOfType(dynamic def) {
  dynamic result = def['type'];
  var isList = false;
  var isMaybe = true;
  var isEnum = false;
  var isUnion = false;
  while (true) {
    if (result['kind'] == 'ENUM') {
      isEnum = true;
    }
    if (result['kind'] == 'UNION') {
      isUnion = true;
    }
    if (result['kind'] == 'NON_NULL') {
      isMaybe = true;
    }
    if (result['kind'] == 'LIST') {
      isList = true;
    }
    if (result['ofType'] != null) {
      result = result['ofType'];
    } else {
      break;
    }
  }
  return FieldMeta(
      def['name'], result['name'], isList, isMaybe, isEnum, isUnion);
}

String generateFromSelection(
    String className,
    String operationName,
    String parentName,
    List<SelectionElement> selections,
    Map<String, dynamic> typeMap) {
  final subTypeMap = _makeSubType(parentName, typeMap);
  final selectionResults = selections.map((selection) {
    if (selection is FieldElement) {
      final graphqlTypeMeta = findDeepOfType(subTypeMap[selection.name]);
      final fieldVisitor = FieldVisitor(
          typeMap, subTypeMap, operationName, graphqlTypeMeta,
          tap: tap);
      fieldVisitor.visitField(selection);
      return fieldVisitor;
    } else if (selection is InlineFragmentElement) {}
  }).where((visitor) => visitor != null);
  final String fieldsInitialization =
      selectionResults.map((visitor) => 'this.${visitor.fieldName}').join(', ');
  final String toJsonImpl = selectionResults.map((visitor) {
    final field = visitor.isScalar
        ? visitor.fieldName
        : visitor.graphqlTypeMeta.isList
            ? 'List<dynamic>.from(${visitor.fieldName}.map((value) => ${visitor.graphqlTypeMeta.isEnum ? '${visitor.graphqlTypeMeta.name}Values.reverseMap[value]' : 'value.toJson()'}))'
            : visitor.graphqlTypeMeta.isEnum
                ? '${visitor.graphqlTypeMeta.name}Values.reverseMap[${visitor.fieldName}]'
                : '${visitor.fieldName}.toJson()';
    return '\'${visitor.fieldName}\': $field';
  }).join(',\n');
  final String toJson = '''
    Map<String, dynamic> toJson() => {
      $toJsonImpl
    };
  ''';
  final String fromJsonImpl = selectionResults.map((visitor) {
    final jsonContent = visitor.graphqlTypeMeta.isList
        ? 'List<${visitor.graphqlTypeMeta.name}>.from(json[\'${visitor.fieldName}\'].map((field) => ${visitor.graphqlTypeMeta.isEnum ? '${visitor.graphqlTypeMeta.name}Values.map[field]' : '${visitor.graphqlTypeMeta.name}.fromJson(field)'}))'
        : visitor.graphqlTypeMeta.isEnum
            ? '${visitor.graphqlTypeMeta.name}Values.map[${visitor.fieldName}]'
            : 'json[\'${visitor.fieldName}\']';
    return '${visitor.fieldName}: $jsonContent';
  }).join(',\n');
  final String fromJsonFactory = '''
    factory $className.fromJson(Map<String, dynamic> json) => $className(
      $fromJsonImpl
    );
  ''';
  return '''
    class $className {
      $className({$fieldsInitialization});

      $fromJsonFactory

      ${selectionResults.map((visitor) => visitor.schemaDef).where((def) => def.isNotEmpty).join("\n")}

      $toJson
    }
    ${selectionResults.map((visitor) => visitor.getResult()).join("\n")}
  ''';
}

Map<String, Map<String, dynamic>> _makeSubType(
    String parentType, Map<String, dynamic> typeMap) {
  final Map<String, Map<String, dynamic>> subTypeMap = {};
  final List<dynamic> fields =
      typeMap[parentType]['fields'] ?? typeMap[parentType]['possibleTypes'];
  for (var def in fields) {
    subTypeMap[def['name']] = def;
  }
  return subTypeMap;
}

String getDefaultValue(ValueElement value) {
  switch (value.valueKind) {
    case ValueKind.String:
      return '"${value.source()}"';
    case ValueKind.Boolean:
    case ValueKind.Number:
      return '${value.source()}';
    default:
      throw GenerateError('Unimplement default value for ${value.valueKind}');
  }
}
