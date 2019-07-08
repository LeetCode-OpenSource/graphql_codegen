import 'package:graphql_codegen/src/elements/element.dart';
import 'package:graphql_codegen/src/elements/operation_defination.dart';

import 'named_type.dart';

abstract class ElementVisitor {
  List<Element> visitOperationDefinition(OperationDefinitionElement defination);

  List<Element> visitFragmentDefinition(OperationDefinitionElement defination);

  NamedTypeElement visitNamedType(NamedTypeElement type);
}
