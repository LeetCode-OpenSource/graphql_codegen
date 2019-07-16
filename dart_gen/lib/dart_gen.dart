import 'dart:io';

import 'package:glob/glob.dart';
import 'package:graphql_ast_visitor/graphql_ast_visitor.dart';
import 'package:dart_style/dart_style.dart';

import 'src/document_visitor.dart';
import 'src/fetch_graphql_metadata.dart';

export 'src/document_visitor.dart';
export 'src/fetch_graphql_metadata.dart' show deleteCache;
export 'src/operation_visitor.dart';

Future<void> generateSchemas(
    String graphqlEndpoint, String filesPattern, String targetPath,
    {DocumentVisitor Function(Map<String, dynamic> typeMeta,
            Map<String, FragmentDefinationElement> fragments)
        documentVisitorFactory,
    bool cache = true,
    bool formatted = true,
    Map<String, String> headers}) async {
  final glob = Glob(filesPattern);
  final String graphlFiles = await glob
      .list()
      .asyncMap((file) => File.fromUri(file.uri).readAsString())
      .fold('', (acc, cur) => acc + '\n' + cur);
  Map<String, dynamic> typeMeta;
  try {
    typeMeta = await fetchMetadata(graphqlEndpoint, cache: cache, headers: headers);
  } catch (e) {
    print(
        'Fetch metadata from grapqhlEndpoint: $graphqlEndpoint fail, Error: $e');
    exit(1);
  }
  final fragmentsVisitor =
      DocumentVisitor(typeMeta, shouldCollectFragment: true, fragments: {});
  gen(graphlFiles, fragmentsVisitor);
  final visitor = documentVisitorFactory != null
      ? documentVisitorFactory(typeMeta, fragmentsVisitor.fragments)
      : DocumentVisitor(typeMeta, fragments: fragmentsVisitor.fragments);
  final result = gen(graphlFiles, visitor);
  final formattedResult = formatted ? DartFormatter().format(result) : result;
  final file = File.fromUri(Uri.file(targetPath));
  await file.writeAsString(formattedResult);
}
