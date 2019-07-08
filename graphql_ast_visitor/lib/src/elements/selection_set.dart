import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'element_kind.dart';
import 'field.dart';
import 'fragment_spread.dart';
import 'inline_fragment.dart';
import 'selection.dart';
import 'visitor.dart';

class SelectionSetElement extends Element {
  SelectionSetElement(this._selectionSet) {
    _selections = _selectionSet.selections.map((selection) {
      if (selection.fragmentSpread != null) {
        return FragmentSpreadElement(selection, this);
      } else if (selection.field != null) {
        return FieldElement(selection, this);
      } else {
        return InlineFragmentElement(selection, this);
      }
    }).toList();
  }

  @override
  final kind = ElementKind.SelectionSet;

  final SelectionSetContext _selectionSet;

  List<SelectionElement> _selections = [];

  List<SelectionElement> get selections {
    return _selections;
  }

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    _selections = _selections.map((selection) {
      if (selection.isField()) {
        return visitor.visitField(selection);
      } else if (selection.isFragmentSpread()) {
        return visitor.visitFragmentSpread(selection);
      } else {
        return visitor.visitInlineFragment(selection);
      }
    }).fold([], (acc, cur) => List.from(acc)..addAll(cur));
  }
}
