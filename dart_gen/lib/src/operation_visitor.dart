import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'field_visitor.dart';
import 'generate_error.dart';
import 'scalar_type_mapping.dart';
import 'tap.dart';

class FieldMeta {
  const FieldMeta(this.fieldName, this.name, this.isList, this.isMaybe,
      this.isEnum, this.isUnion);

  final String name;

  final String fieldName;

  final bool isList;

  final bool isMaybe;

  final bool isEnum;

  final bool isUnion;
}

class OperationVisitor extends SimpleVisitor {
  OperationVisitor(final this.typeMap, {Tap tap}) : super(tap: tap) {
    _generateEnums();
    // _generateUnions();
  }

  static FieldMeta findDeepOfType(dynamic def) {
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

  static Map<String, Map<String, dynamic>> _makeSubType(
      String parentType, Map<String, dynamic> typeMap) {
    final Map<String, Map<String, dynamic>> subTypeMap = {};
    final List<dynamic> fields = typeMap[parentType]['fields'];
    for (var def in fields) {
      subTypeMap[def['name']] = def;
    }
    return subTypeMap;
  }

  static String generateFromSelection(
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
      }
    }).where((visitor) => visitor != null);
    final String fieldsInitialization = selectionResults
        .map((visitor) => 'this.${visitor.fieldName}')
        .join(', ');
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

  final Map<String, dynamic> typeMap;

  final Set<String> operationNames = {};

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  void _generateEnums() {
    _result += '''
      class EnumValues<T> {
        const EnumValues(this.map, this.reverseMap);

        final Map<String, T> map;
        final Map<T, String> reverseMap;
      }
    ''';
    typeMap.removeWhere((key, _) => key.startsWith('__'));
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

  void _generateUnions() {
    typeMap.forEach((typename, typemeta) {
      if (typemeta['kind'] == 'UNION') {
        final List<dynamic> possibleTypes = typemeta['possibleTypes'];
        final String castMethods = possibleTypes.map((type) {
          final String typeName = type['name'];
          return '''
            $typeName castTo$typeName() {
              if (this._value['__typename'] != '$typeName') {
                return null;
              }
              return $typeName.fromJson(_value);
            }
          ''';
        }).join('\n');
        _result += '''
        class ${capitalizeUpperCase(typename)} {
          const ${capitalizeUpperCase(typename)}(this._value);

          final Map<String, dynamic> _value;

          $castMethods
        }
        ''';
      }
    });
  }

  String _getDefaultValue(ValueElement value) {
    switch (value.valueKind) {
      case ValueKind.String:
        return '"${value.source()}"';
      case ValueKind.Boolean:
        return '${value.source()}';
      default:
        throw GenerateError('Unimplement default value for ${value.valueKind}');
    }
  }

  String _generateOperationVariable(OperationDefinitionElement defination) {
    if (defination.variableDefinition == null) {
      return '';
    }
    final constructorParams = defination.variableDefinition.map((variable) {
      if (variable.defaultValue != null) {
        return 'this.${variable.variable.name} = ${_getDefaultValue(variable.defaultValue)}';
      } else {
        return 'this.${variable.variable.name}';
      }
    }).join(', ');
    final fieldDeclarion = defination.variableDefinition.map((variable) {
      final typeName = variable.type.source();
      final String gqlTypeName = typeMap[typeName]['name'];
      final String dartType = typeMap[typeName]['kind'] == 'SCALAR'
          ? ScalarTypeMapping[gqlTypeName]
          : gqlTypeName;
      return '$dartType ${variable.variable.name};';
    }).join('\n');
    return '''
      class ${capitalizeUpperCase(defination.name)}Variable {
        ${capitalizeUpperCase(defination.name)}Variable({$constructorParams});

        $fieldDeclarion
      }
    ''';
  }

  @override
  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    if (defination.name == null) {
      throw DartCodeGenerateError('No defination name');
    }
    if (operationNames.contains(defination.name)) {
      throw DartCodeGenerateError(
          'Duplicate operation name: ${defination.name}');
    }
    operationNames.add(defination.name);
    _result += _generateOperationVariable(defination);
    final capitalizeOperation = capitalizeUpperCase(defination.operation);
    final capitalizeOperationName = capitalizeUpperCase(defination.name);
    final className = '$capitalizeOperationName$capitalizeOperation';
    final fieldResults = generateFromSelection(
        className,
        capitalizeOperationName,
        capitalizeOperation,
        defination.selectionSet.selections,
        typeMap);
    _result += fieldResults;
    return [defination];
  }
}
