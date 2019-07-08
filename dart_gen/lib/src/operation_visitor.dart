import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'generate_error.dart';
import 'scalar_type_mapping.dart';
import 'utils.dart';

class OperationVisitor extends SimpleVisitor {
  OperationVisitor(final this.typeMap, {Tap tap}) : super(tap: tap);

  final Map<String, dynamic> typeMap;

  final Set<String> operationNames = {};

  String _result = '';

  @override
  String getResult() {
    return _result;
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

  String _generateOperationVariable(OperationDefinitionElement defination) {
    if (defination.variableDefinition == null) {
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
      final String dartType = typeMap[typeName]['kind'] == 'SCALAR'
          ? ScalarTypeMapping[gqlTypeName]
          : gqlTypeName;
      return '${variable.isList ? 'List<$dartType>' : dartType} ${variable.variable.name};';
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
