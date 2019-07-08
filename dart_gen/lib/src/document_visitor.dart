import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';
import 'fragment_definition_visitor.dart';
import 'operation_visitor.dart';
import 'tap.dart';

class DocumentVisitor extends SimpleVisitor {
  DocumentVisitor(final this.typeMap) : super(tap: tap) {
    _generateEnums();
  }

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  final Map<String, dynamic> typeMap;

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

  @override
  List<FragmentDefinationElement> visitFragmentDefinition(
      FragmentDefinationElement defination) {
    final _fragmentDefinitionVisitor =
        FragmentDefinitionVisitor(typeMap, tap: tap);
    final result =
        _fragmentDefinitionVisitor.visitFragmentDefinition(defination);
    _result += _fragmentDefinitionVisitor.getResult();
    return result;
  }

  @override
  List<OperationDefinitionElement> visitOperationDefinition(
      OperationDefinitionElement defination) {
    final _operationVisitor = OperationVisitor(typeMap, tap: tap);
    final result = _operationVisitor.visitOperationDefinition(defination);
    _result += _operationVisitor.getResult();
    return result;
  }
}
