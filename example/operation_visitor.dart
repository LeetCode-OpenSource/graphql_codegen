import 'package:graphql_codegen/graphql_codegen.dart';
import 'package:graphql_codegen/src/elements/selection.dart';

import 'capitalize_upper_case.dart';
import 'field_visitor.dart';
import 'generate_error.dart';
import 'tap.dart';
import 'scalar_type_mapping.dart';

class FieldMeta {
  FieldMeta(this.fieldName, this.name, this.isList, this.isMaybe);

  final String name;

  final String fieldName;
  
  final bool isList;
  
  final bool isMaybe;
}

class OperationVisitor extends SimpleVisitor {
  OperationVisitor(final this.typeMap, {Tap tap}) : super(tap: tap);

  final Map<String, dynamic> typeMap;

  final Set<String> operationNames = Set();

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  String _getDefaultValue(ValueElement value) {
    if (value.valueKind == ValueKind.String) {
      return '"${value.source()}"';
    } else if (value.valueKind == ValueKind.Boolean) {
      return '${value.source()}';
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
    class ${defination.name}Variable {
      ${defination.name}Variable({$constructorParams});

      $fieldDeclarion
    }
    ''';
  }

  static FieldMeta findDeepOfType(dynamic def) {
    dynamic result = def['type'];
    var isList = false;
    var isMaybe = true;
    while (true) {
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
    return FieldMeta(def['name'], result['name'], isList, isMaybe);
  }

  static Map<String, Map<String, dynamic>> _makeSubType(
      String parentType, Map<String, dynamic> typeMap) {
    final Map<String, Map<String, dynamic>> subTypeMap = Map();
    (typeMap[parentType]['fields'] as List<dynamic>).forEach((def) {
      subTypeMap[def['name']] = def;
    });
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
        final fieldVisitor =
            FieldVisitor(typeMap, subTypeMap, operationName, graphqlTypeMeta, tap: tap);
        fieldVisitor.visitField(selection);
        return fieldVisitor;
      }
    }).where((visitor) => visitor != null);

    return '''
    class $className {
      ${selectionResults.map((visitor) => visitor.schemaDef).join("\n")}
    }
    
    ${selectionResults.map((visitor) => visitor.getResult()).join("\n")}
        
    ''';
  }

  @override
  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    if (defination.name == null) {
      throw new DartCodeGenerateError('No defination name');
    }
    if (operationNames.contains(defination.name)) {
      throw new DartCodeGenerateError(
          'Duplicate operation name: ${defination.name}');
    }
    operationNames.add(defination.name);
    _result += _generateOperationVariable(defination);
    final capitalizeOperation = capitalizeUpperCase(defination.operation);
    final capitalizeOperationName = capitalizeUpperCase(defination.name);
    final className = '${capitalizeOperationName}${capitalizeOperation}';
    final fieldResults = generateFromSelection(className, capitalizeOperationName, capitalizeOperation,
        defination.selectionSet.selections, typeMap);
    _result += fieldResults;
    return [defination];
  }
}
