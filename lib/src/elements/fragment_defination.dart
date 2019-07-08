import 'package:graphql_codegen/src/elements/element_kind.dart';
import 'package:graphql_codegen/src/elements/element.dart';
import 'package:graphql_codegen/src/elements/named_type.dart';
import 'package:graphql_codegen/src/elements/visitor.dart';
import 'package:graphql_parser/graphql_parser.dart';

class FragmentDefinationElement extends Element {
  FragmentDefinationElement(this._defination) {
    typeCondition = NamedTypeElement(this._defination.typeCondition.typeName);
  }

  final kind = ElementKind.FragmentDefinition;

  final FragmentDefinitionContext _defination;

  List<Element> get children {
    final List<Element> _children = [];
    if (typeCondition != null) {
      _children.add(typeCondition);
    }
    return _children;
  }

  NamedTypeElement typeCondition;

  String get name {
    return this._defination.name;
  }

  @override
  String source() {
    return this.children.map((child) => child.source()).join('');
  }

  @override
  accept(ElementVisitor visitor) {
    typeCondition = visitor.visitNamedType(typeCondition);
  }
}