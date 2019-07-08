import 'package:graphql_codegen/src/elements/element_kind.dart';
import 'package:graphql_codegen/src/elements/element.dart';
import 'package:graphql_codegen/src/elements/visitor.dart';
import 'package:graphql_parser/graphql_parser.dart';

class OperationDefinitionElement extends Element {
  OperationDefinitionElement(this._defination);

  final kind = ElementKind.OperationDefinition;

  final OperationDefinitionContext _defination;

  String get operation {
    return this._defination.name;
  }

  @override
  String source() {
    return this._defination.span.text;
  }

  @override
  accept(ElementVisitor visitor) {
    
  }
}
