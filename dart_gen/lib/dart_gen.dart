import 'dart:io';

import 'package:glob/glob.dart';
import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';

import 'src/document_visitor.dart';
import 'src/fetch_graphql_metadata.dart';

Future<void> generateSchemas(
    String graphqlEndpoint, String filesPattern, String targetPath) async {
  final glob = Glob(filesPattern);
  final String graphlFiles = await glob
      .list()
      .asyncMap((file) => File.fromUri(file.uri).readAsString())
      .fold('', (acc, cur) => acc + '\n' + cur);
  Map<String, dynamic> typeMeta;
  try {
    typeMeta = await fetchMetadata(graphqlEndpoint);
  } catch (e) {
    print(
        'Fetch metadata from grapqhlEndpoint: $graphqlEndpoint fail, Error: $e');
    exit(1);
  }
  final result = gen(graphlFiles, DocumentVisitor(typeMeta));
  final file = File.fromUri(Uri.file(targetPath));
  await file.writeAsString(result);
}
