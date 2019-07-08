import 'package:graphql_parser/graphql_parser.dart' as gql;

String gen(String source) {
  final tokens = gql.scan(source);
  final parser = gql.Parser(tokens);

  if (parser.errors.isNotEmpty) {
    throw GenerateError(parser.errors.map((e) => e.toString()).join('\n'));
  }

  final ops = parser.parseOperationDefinition();
  ops.selectionSet.selections.forEach((selection) {
    print(selection.field.fieldName.name);
  });
}

class GenerateError extends Error {
  GenerateError(this.message): super();

  final String message;

  @override
  String toString() {
    return message;
  }
}
