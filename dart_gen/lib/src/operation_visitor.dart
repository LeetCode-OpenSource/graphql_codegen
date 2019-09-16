import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'generate_error.dart';
import 'scalar_type_mapping.dart';
import 'utils.dart';

class OperationVisitor extends SimpleVisitor {
  OperationVisitor(final this.typeMap, this.fragments, {Tap tap})
      : super(tap: tap);

  static final Set<String> operationNames = {};

  final Map<String, dynamic> typeMap;

  final Map<String, FragmentDefinationElement> fragments;

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  String _generateOperationVariable(OperationDefinitionElement defination) {
    if (defination.variableDefinition == null ||
        defination.variableDefinition.isEmpty) {
      return '';
    }
    final constructorParams = defination.variableDefinition.map((variable) {
      if (variable.defaultValue != null) {
        return 'this.${variable.variable.name} = ${getDefaultValue(variable.defaultValue)}';
      } else {
        return 'this.${variable.variable.name}';
      }
    }).join(', ');
    final fieldDeclarion = defination.variableDefinition.map((variable) {
      final typeName = variable.type.source();
      final String gqlTypeName = typeMap[typeName]['name'];
      final isScalar = typeMap[typeName]['kind'] == 'SCALAR';
      final String dartType =
          isScalar ? scalarTypeMapping[gqlTypeName] : gqlTypeName;
      return '${variable.isList ? 'List<$dartType>' : dartType} ${variable.variable.name};';
    }).join('\n');
    final toJsonImpl = defination.variableDefinition.map((variable) {
      final typeName = variable.type.source();
      final isScalar = typeMap[typeName]['kind'] == 'SCALAR';
      final field = typeMap[typeName]['kind'] == 'ENUM'
          ? '${typeName}Values.reverseMap[${variable.variable.name}]'
          : isScalar
              ? variable.variable.name
              : variable.isList
                  ? '${variable.variable.name}${generateComplexToJsonMapImpl(variable.listCount - 1, isScalar ? 'value' : 'value?.toJson()')}'
                  : '${variable.variable.name}.toJson()';
      return '\'${variable.variable.name}\': $field';
    }).join(',\n');
    return '''
      class ${capitalizeUpperCase(defination.name)}Variable {
        ${capitalizeUpperCase(defination.name)}Variable({$constructorParams});

        $fieldDeclarion

        Map<String, dynamic> toJson() {
          return {
            $toJsonImpl
          };
        }
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
        typeMap,
        fragments);
    _result += fieldResults;
    return [defination];
  }
}
