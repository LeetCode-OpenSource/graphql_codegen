import 'package:graphql_parser/graphql_parser.dart';

import 'element.dart';
import 'selection_set.dart';

abstract class SelectionElement extends Element {
  SelectionElement(this._selection, this.parent) : super();

  final SelectionSetElement parent;

  final SelectionContext _selection;

  bool isField() {
    return _selection.field != null;
  }

  bool isInlineFragment() {
    return _selection.inlineFragment != null;
  }

  bool isFragmentSpread() {
    return _selection.fragmentSpread != null;
  }
}
