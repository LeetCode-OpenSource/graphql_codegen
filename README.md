# Graphql codegen

## graphql_ast_visitor
Provide abstract layer to visit graphql ast nodes.

## dart_gen
Generate dart codes from graphql ast nodes.

```graphql
query projectDetail($fullPath: ID!, $first: Int!, $after: String!, $status: PipelineStatusEnum) {
  project(fullPath: $fullPath) {
    archived
    pipelines(first: $first, after: $after, status: $status) {
      edges {
        cursor
        node {
          id
          iid
          sha
          status
          detailedStatus {
            detailsPath
            hasDetails
          }
        }
      }
      pageInfo {
        endCursor
        hasNextPage
        hasPreviousPage
      }
    }
  }
}
```

```dart
...

class ProjectDetailVariable {
  ProjectDetailVariable({this.fullPath, this.first, this.after, this.status});

  String fullPath;
  int first;
  String after;
  PipelineStatusEnum status;

  Map<String, dynamic> toJson() {
    return {
      'fullPath': fullPath,
      'first': first,
      'after': after,
      'status': PipelineStatusEnumValues.reverseMap[status]
    };
  }
}

class ProjectDetailQuery {
  ProjectDetailQuery({this.project});

  factory ProjectDetailQuery.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return ProjectDetailQuery();
    }
    return ProjectDetailQuery(
        project: ProjectDetailQueryProject.fromJson(json['project']));
  }

  ProjectDetailQueryProject project;

  Map<String, dynamic> toJson() => {'project': project?.toJson()};
}

...
```


Run `dart_gen/example/main.dart` to see full output from this graphql

You can also write some more gql files from [gitlab](https://gitlab.com/-/graphql-explorer) to see more generated results.

## Roadmap

### Enginnering
- [ ] Unit tests
- [ ] CI
- [ ] Docs and Example website
### Features
- [x] Operations
- [x] Variables
- [x] Fragments
- [x] Union Types
- [ ] Directives

## Limitions
- Every `Query` and `Mutation` must have a *unique* name
