import 'package:graphql_parser/graphql_parser.dart';

import 'directive.dart';
import 'element_kind.dart';
import 'selection.dart';
import 'selection_set.dart';
import 'visitor.dart';

class FragmentSpreadElement extends SelectionElement {
  FragmentSpreadElement(SelectionContext selection, SelectionSetElement parent)
      : super(selection, parent) {
    _fragmentSpread = selection.fragmentSpread;
    _directives = selection.fragmentSpread.directives
        .map((directive) => DirectiveElement(directive))
        .toList();
  }

  @override
  final kind = ElementKind.FragmentSpread;

  FragmentSpreadContext _fragmentSpread;

  List<DirectiveElement> _directives;

  List<DirectiveElement> get directives {
    return _directives;
  }

  @override
  String get name {
    return _fragmentSpread.name;
  }

  @override
  String source() {
    return null;
  }

  @override
  void accept(ElementVisitor visitor) {
    _directives = _directives
        .map((directive) => visitor.visitDirective(directive))
        .fold([], flat);
  }
}
