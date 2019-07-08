class FieldMeta {
  const FieldMeta(this.fieldName, this.name, this.isList, this.isMaybe,
      this.isEnum, this.isUnion);

  final String name;

  final String fieldName;

  final bool isList;

  final bool isMaybe;

  final bool isEnum;

  final bool isUnion;
}