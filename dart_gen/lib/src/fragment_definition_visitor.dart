import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'capitalize_upper_case.dart';

class FragmentDefinitionVisitor extends SimpleVisitor {
  FragmentDefinitionVisitor(final this.typeMap, {Tap tap}) : super(tap: tap);

  final Map<String, dynamic> typeMap;

  String _result = '';

  @override
  String getResult() {
    return _result;
  }

  @override
  List<FragmentDefinationElement> visitFragmentDefinition(
      FragmentDefinationElement defination) {
    final castName = '''
      class ${capitalizeUpperCase(defination.name)}Fragment {
        
      }
    ''';
    return super.visitFragmentDefinition(defination);
  }
}
