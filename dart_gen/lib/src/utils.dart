import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'field_meta.dart';
import 'scalar_type_mapping.dart';
import 'selection_visitor.dart';
import 'tap.dart';

FieldMeta findDeepOfType(dynamic def) {
  dynamic result = def['type'];
  var isList = false;
  var isMaybe = true;
  var isEnum = false;
  var isUnion = false;
  var isScalar = false;
  var listCount = 0;
  // ignore: literal_only_boolean_expressions
  while (true) {
    if (result['kind'] == 'ENUM') {
      isEnum = true;
    }
    if (result['kind'] == 'UNION') {
      isUnion = true;
    }
    if (result['kind'] == 'NON_NULL') {
      isMaybe = false;
    }
    if (result['kind'] == 'LIST') {
      isList = true;
      listCount++;
    }
    if (result['kind'] == 'SCALAR') {
      isScalar = true;
    }
    if (result['ofType'] != null) {
      result = result['ofType'];
    } else {
      break;
    }
  }
  return FieldMeta(def['name'], result['name'], isList, listCount, isMaybe,
      isEnum, isUnion, isScalar);
}

String generateFromSelection(
    String className,
    String operationName,
    String parentName,
    List<SelectionElement> selections,
    Map<String, dynamic> typeMap,
    Map<String, FragmentDefinationElement> fragments,
    {skipClassGeneration = false}) {
  final flatSelections = flatFragmentSpreadSelections(selections, fragments);
  final subTypeMap = _makeSubType(parentName, typeMap);
  final List<SelectionVisitor> selectionVisitors = [];
  final selectionResults = flatSelections.fold(selectionVisitors,
      (List<SelectionVisitor> acc, selection) {
    final subTypeName = selection is InlineFragmentElement
        ? selection.typeCondition.name
        : selection.name;
    if (subTypeName.startsWith('__')) {
      return acc;
    }
    final graphqlTypeMeta = findDeepOfType(subTypeMap[subTypeName]);
    final selectionVisitor = SelectionVisitor(
        typeMap,
        subTypeMap,
        '$className${capitalizeUpperCase(subTypeName)}',
        graphqlTypeMeta,
        fragments,
        tap: tap);
    if (selection is FieldElement) {
      selectionVisitor.visitField(selection);
      acc.add(selectionVisitor);
    } else if (selection is InlineFragmentElement) {
      selectionVisitor.unionClassName = className;
      selectionVisitor.visitInlineFragment(selection);
      acc.add(selectionVisitor);
    }
    return acc;
  });
  final String fieldsInitialization =
      selectionResults.map((visitor) => 'this.${visitor.fieldName}').join(', ');
  final String toJsonImpl = selectionResults.map((visitor) {
    String mapImpl;
    if (visitor.graphqlTypeMeta.isList) {
      mapImpl = visitor.graphqlTypeMeta.isEnum
          ? '${visitor.graphqlTypeMeta.name}Values.reverseMap[value]'
          : 'value?.toJson()';
      mapImpl = generateComplexToJsonMapImpl(
          visitor.graphqlTypeMeta.listCount - 1, mapImpl);
    }
    final field = visitor.isScalar
        ? visitor.fieldName
        : visitor.graphqlTypeMeta.isList
            ? 'List<dynamic>.from((${visitor.fieldName} ?? [])$mapImpl)'
            : visitor.graphqlTypeMeta.isEnum
                ? '${visitor.fieldName} != null ? ${visitor.graphqlTypeMeta.name}Values.reverseMap[${visitor.fieldName}] : null'
                : '${visitor.fieldName}?.toJson()';
    return '\'${visitor.fieldName}\': $field';
  }).join(',\n');
  final String toJson = '''
    Map<String, dynamic> toJson() => {
      $toJsonImpl
    };
  ''';
  final String fromJsonImpl = selectionResults.map((visitor) {
    final typeMeta = visitor.graphqlTypeMeta;
    String listType;
    String finalType;
    String complexListCastType;
    if (typeMeta.isList) {
      final complexListType =
          typeMeta.isEnum ? typeMeta.name : visitor.typeName;
      finalType = typeMeta.isScalar
          ? scalarTypeMapping[typeMeta.name]
          : complexListType;
      final listCount = typeMeta.listCount;
      listType = listCount == 1
          ? finalType
          : '${List.filled(listCount - 1, 'List<').join('')}$finalType${List.filled(listCount - 1, '>').join('')}';
      complexListCastType = typeMeta.isEnum
          ? '${typeMeta.name}Values.map[field]'
          : typeMeta.isScalar
              ? 'field as $finalType'
              : '${visitor.typeName}.fromJson(field)';
    }
    final jsonContent = typeMeta.isList
        ? 'List<$listType>.from((json[\'${visitor.alias ?? visitor.fieldName}\'] ?? [])${generateComplexFromJsonMapImpl(typeMeta.listCount - 1, finalType, complexListCastType)})'
        : typeMeta.isEnum
            ? 'json[\'${visitor.alias ?? visitor.fieldName}\'] != null ? ${typeMeta.name}Values.map[json[\'${visitor.alias ?? visitor.fieldName}\']] : null'
            : typeMeta.isScalar
                ? 'json[\'${visitor.alias ?? visitor.fieldName}\']'
                : '${visitor.schemaName}.fromJson(json[\'${visitor.alias ?? visitor.fieldName}\'])';
    return '${visitor.fieldName}: $jsonContent';
  }).join(',\n');
  final String fromJsonFactory = '''
    factory $className.fromJson(Map<String, dynamic> json) {
      if (json == null) {
        return $className();
      }
      return $className(
        $fromJsonImpl
      );
    }
  ''';
  final classDefination = skipClassGeneration
      ? ''
      : '''
    class $className {
      $className({$fieldsInitialization});

      $fromJsonFactory

      ${selectionResults.map((visitor) => visitor.schemaDef).where((def) => def.isNotEmpty).join("\n")}

      $toJson
    }
  ''';
  return '''
    $classDefination
    ${selectionResults.map((visitor) => visitor.getResult()).join("\n")}
  ''';
}

Map<String, Map<String, dynamic>> _makeSubType(
    String parentType, Map<String, dynamic> typeMap) {
  final Map<String, Map<String, dynamic>> subTypeMap = {};
  List<dynamic> fields;
  var isUnion = false;
  if (typeMap[parentType]['possibleTypes'] != null) {
    fields = typeMap[parentType]['possibleTypes'];
    isUnion = true;
  } else {
    fields = typeMap[parentType]['fields'];
  }
  for (var def in fields) {
    if (isUnion) {
      subTypeMap[def['name']] = {'type': def, 'name': def['name']};
    } else {
      subTypeMap[def['name']] = def;
    }
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

List<SelectionElement> flatFragmentSpreadSelections(
    List<SelectionElement> selections,
    Map<String, FragmentDefinationElement> fragments) {
  final List<SelectionElement> result = [];
  return selections.fold(result, (acc, cur) {
    if (cur is FragmentSpreadElement) {
      if (!fragments.containsKey(cur.name)) {
        throw GenerateError('Missing fragment defination: ${cur.name}');
      }
      final fragmentDefinition = fragments[cur.name];
      if (fragmentDefinition.selectionSet.selections.isNotEmpty) {
        result.addAll(flatFragmentSpreadSelections(
            fragmentDefinition.selectionSet.selections, fragments));
      }
    } else {
      acc.add(cur);
    }
    return acc;
  });
}

String generateUnions(Map<String, dynamic> typemeta, String unionTypeName,
    String unionTypeNameWithPrefix, Set<String> maybeUnions) {
  final List<dynamic> possibleTypes = typemeta['possibleTypes'];
  final String castMethods = possibleTypes
      .where((type) => maybeUnions.contains(type['name']))
      .map((type) {
    final String typeName = type['name'];
    final subTypeClassName = '${typeName}Of$unionTypeNameWithPrefix';
    return '''
      $subTypeClassName castTo$subTypeClassName() {
        if (_value['__typename'] != '$typeName') {
          return null;
        }
        return $subTypeClassName.fromJson(_value);
      }
    ''';
  }).join('\n');
  return '''
    class $unionTypeNameWithPrefix {
      const $unionTypeNameWithPrefix(this._value);

      factory $unionTypeNameWithPrefix.fromJson(dynamic json) => $unionTypeNameWithPrefix(json);

      final Map<String, dynamic> _value;

      dynamic toJson() => _value;

      $castMethods
    }
  ''';
}

String generateComplexToJsonMapImpl(int listCount, String mapImpl) {
  if (listCount == 0) {
    return '.map((value) => $mapImpl)';
  }
  return '.map((value$listCount) => value$listCount?${generateComplexToJsonMapImpl(listCount - 1, mapImpl)})';
}

String generateComplexFromJsonMapImpl(int listCount, String type, String impl) {
  if (listCount == 0) {
    return '.map((field) => $impl)';
  }
  final levelType =
      '${List.filled(listCount - 1, 'List<').join('')}$type${List.filled(listCount - 1, '>').join('')}';
  return '.map((field$listCount) => List<$levelType>.from(field$listCount${generateComplexFromJsonMapImpl(listCount - 1, type, impl)}))';
}
