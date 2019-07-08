import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'fragment_defination.dart';
import 'operation_defination.dart';

enum DefinitionKind {
  Operation,
  Fragment,
  Unknown,
}

abstract class DefinitionElement extends Element {
  static DefinitionElement create(DefinitionContext def) {
    if (def is OperationDefinitionContext) {
      return OperationDefinitionElement(def);
    } else if (def is FragmentDefinitionContext) {
      return FragmentDefinationElement(def);
    }
    return null;
  }

  DefinitionElement(this._definition) : super();

  final DefinitionContext _definition;

  DefinitionKind get definitionKind {
    if (_definition is OperationDefinitionContext) {
      return DefinitionKind.Operation;
    } else if (_definition is FragmentDefinitionContext) {
      return DefinitionKind.Fragment;
    }
    return DefinitionKind.Unknown;
  }
}
