import 'package:graphql_parser/graphql_parser.dart';

import 'element_kind.dart';
import 'named_type.dart';
import 'selection.dart';
import 'selection_set.dart';
import 'visitor.dart';

class InlineFragmentElement extends SelectionElement {
  InlineFragmentElement(SelectionContext selection, SelectionSetElement parent)
      : super(selection, parent) {
    _inlineFragment = selection.inlineFragment;
    if (_inlineFragment.typeCondition.typeName != null) {
      _typeCondition =
          NamedTypeElement(selection.inlineFragment.typeCondition.typeName);
    }
    if (_inlineFragment.selectionSet != null) {
      _selectionSet = SelectionSetElement(_inlineFragment.selectionSet);
    }
  }

  @override
  final kind = ElementKind.InlineFragment;

  @override
  String get name {
    return null;
  }

  NamedTypeElement _typeCondition;

  NamedTypeElement get typeCondition {
    return _typeCondition;
  }

  SelectionSetElement _selectionSet;

  SelectionSetElement get selectionSet {
    return _selectionSet;
  }

  InlineFragmentContext _inlineFragment;

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    if (_typeCondition != null) {
      _typeCondition = visitor.visitNamedType(_typeCondition);
    }

    if (_selectionSet != null) {
      _selectionSet = visitor.visitSelectionSet(_selectionSet);
    }
  }
}
