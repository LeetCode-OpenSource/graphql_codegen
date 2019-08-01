import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'operation_visitor.dart';
import 'scalar_type_mapping.dart';
import 'tap.dart';
import 'utils.dart';

class DocumentVisitor extends SimpleVisitor {
  DocumentVisitor(final this.typeMap,
      {this.shouldCollectFragment = false, this.fragments = const {}})
      : super(tap: tap) {
    typeMap.removeWhere((key, _) => key.startsWith('__'));
    _generateEnums();
    _generateInputObjects();
  }

  final Map<String, FragmentDefinationElement> fragments;

  final bool shouldCollectFragment;

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  final Map<String, dynamic> typeMap;

  void _generateInputObjects() {
    typeMap.forEach((typename, typeMeta) {
      if (typeMeta['kind'] == 'INPUT_OBJECT') {
        String fromJson = '';
        String toJson = '';
        String type = '';
        String initialize = '';
        String fieldInitialize = '';
        for (final field in typeMeta['inputFields']) {
          String _fromJson;
          String _toJson;
          final fieldMeta = findDeepOfType(field);
          type = fieldMeta.isScalar
              ? scalarTypeMapping[fieldMeta.name]
              : fieldMeta.name;
          if (fieldMeta.isScalar) {
            _fromJson = 'json[\'${fieldMeta.fieldName}\']';
            _toJson = fieldMeta.fieldName;
          } else if (fieldMeta.isEnum) {
            final fieldName =
                fieldMeta.isList ? 'field' : 'json[\'${fieldMeta.fieldName}\']';
            _fromJson = '${fieldMeta.name}Values.map[$fieldName]';
            _toJson =
                '${fieldMeta.fieldName} != null ? ${fieldMeta.name}Values.reverseMap[${fieldMeta.fieldName}] : null';
          } else if (fieldMeta.isUnion) {
            print('Not support union field in INPUT_OBJECT');
          } else {
            final fieldName = fieldMeta.isList ? 'value' : fieldMeta.fieldName;
            _fromJson =
                '${fieldMeta.name}.fromJson(json[\'${fieldMeta.fieldName}\'])';
            _toJson = '$fieldName?.toJson()';
          }
          if (fieldMeta.isList) {
            final listCount = fieldMeta.listCount;
            _toJson = fieldMeta.isScalar
                ? _toJson
                : 'List<dynamic>.from(${fieldMeta.fieldName} ?? [])${generateComplexToJsonMapImpl(
                    fieldMeta.listCount - 1,
                    _toJson,
                  )}';
            final complexListCastType = fieldMeta.isEnum
                ? '${fieldMeta.name}Values.map[field]'
                : fieldMeta.isScalar
                    ? 'field as $type'
                    : '${fieldMeta.name}.fromJson(field)';
            final listType = listCount == 1
                ? type
                : '${List.filled(listCount - 1, 'List<').join('')}$type${List.filled(listCount - 1, '>').join('')}';
            type = 'List<$listType>';
            _fromJson =
                'List<$listType>.from((json[\'${fieldMeta.fieldName}\'] ?? [])${generateComplexFromJsonMapImpl(fieldMeta.listCount - 1, type, complexListCastType)})';
          }
          toJson += '\'${fieldMeta.fieldName}\': $_toJson,';
          fromJson += '${fieldMeta.fieldName}: $_fromJson,';
          initialize += 'this.${fieldMeta.fieldName},';
          fieldInitialize += 'final $type ${fieldMeta.fieldName};';
        }

        _result += '''
          class ${typeMeta['name']} {
            ${typeMeta['name']}({$initialize});

            factory ${typeMeta['name']}.fromJson(Map<String, dynamic> json) {
              if (json == null) {
                return ${typeMeta['name']}();
              }

              return ${typeMeta['name']}(
                $fromJson
              );
            }

            $fieldInitialize

            Map<String, dynamic> toJson() => {
              $toJson
            };
          }
        ''';
      }
    });
  }

  void _generateEnums() {
    _result += '''
      class EnumValues<T> {
        const EnumValues(this.map, this.reverseMap);

        final Map<String, T> map;
        final Map<T, String> reverseMap;
      }
    ''';
    typeMap.forEach((typename, typeMeta) {
      if (typeMeta['kind'] == 'ENUM') {
        final enumName = capitalizeUpperCase(typeMeta['name']);
        final List<dynamic> enumValues = typeMeta['enumValues'];
        final enumFields = enumValues.map((value) {
          final String name = value['name'];
          if (value['isDeprecated']) {
            return '''
            @depracated
            ${name.toUpperCase()}
            ''';
          }
          return '${name.toUpperCase()}';
        }).join(',\n');
        final enumValuesMap = enumValues.map((value) {
          final String name = value['name'];
          return '\'$name\': $enumName.${name.toUpperCase()}';
        }).join(',\n');
        final enumReveresValuesMap = enumValues.map((value) {
          final String name = value['name'];
          return '$enumName.${name.toUpperCase()}: \'$name\'';
        }).join(',\n');
        _result += '''
          enum $enumName {
            $enumFields
          }
          const ${enumName}Values = EnumValues({
            $enumValuesMap
          }, {
            $enumReveresValuesMap
          });
        ''';
      }
    });
  }

  @override
  List<FragmentDefinationElement> visitFragmentDefinition(
      FragmentDefinationElement defination) {
    if (shouldCollectFragment) {
      fragments[defination.name] = defination;
    }
    return [defination];
  }

  @override
  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    if (shouldCollectFragment) {
      return [defination];
    }
    final _operationVisitor = OperationVisitor(typeMap, fragments, tap: tap);
    final result = _operationVisitor.visitOperationDefinition(defination);
    _result += _operationVisitor.getResult();
    return result;
  }
}
