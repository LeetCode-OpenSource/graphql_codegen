import 'package:graphql_parser/graphql_parser.dart' as gql;

import 'elements/document.dart';
import 'elements/visitor.dart';

export 'elements/visitor.dart';

String gen(String source, ElementVisitor visitor) {
  final tokens = gql.scan(source);
  final parser = gql.Parser(tokens);

  if (parser.errors.isNotEmpty) {
    throw GenerateError(parser.errors.map((e) => e.toString()).join('\n'));
  }

  final document = parser.parseDocument();
  final documentElement = DocumentElement(document);
  documentElement.accept(visitor);
  return visitor.getResult();
}

class GenerateError extends Error {
  GenerateError(this.message) : super();

  final String message;

  @override
  String toString() {
    return message;
  }
}
