import 'dart:io';

import 'package:glob/glob.dart';
import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'src/fetch_graphql_metadata.dart';
import 'src/operation_visitor.dart';
import 'src/tap.dart';

Future<void> generateSchemas(
    String graphqlEndpoint, String filesPattern, String targetPath) async {
  final glob = Glob(filesPattern);
  final String graphlFiles = await glob
      .list()
      .asyncMap((file) => File.fromUri(file.uri).readAsString())
      .fold('', (acc, cur) => acc + '\n' + cur);
  try {
    final typeMeta = await fetchMetadata(graphqlEndpoint);
    final result = gen(graphlFiles, OperationVisitor(typeMeta, tap: tap));
    final file = File.fromUri(Uri.file(targetPath));
    await file.writeAsString(result);
  } catch (e) {
    print(
        'Fetch metadata from grapqhlEndpoint: $graphqlEndpoint fail, Error: $e');
    exit(1);
  }
}
