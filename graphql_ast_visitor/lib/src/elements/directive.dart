import 'package:graphql_parser/graphql_parser.dart';

import 'argument.dart';
import 'element.dart';
import 'element_kind.dart';
import 'visitor.dart';

class DirectiveElement extends Element {
  DirectiveElement(this._directiveContext) {
    _argument = ArgumentElement(_directiveContext.argument, this);
  }

  final DirectiveContext _directiveContext;

  @override
  final kind = ElementKind.Directive;

  ArgumentElement _argument;

  ArgumentElement get argument {
    return _argument;
  }

  @override
  String source() {
    return _directiveContext.span.text;
  }

  @override
  void accept(ElementVisitor visitor) {
    // client side directive only have 1 argument by spec
    _argument = visitor.visitArgument(_argument)[0];
  }
}
