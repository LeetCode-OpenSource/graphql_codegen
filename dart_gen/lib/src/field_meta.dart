class FieldMeta {
  const FieldMeta(this.fieldName, this.name, this.isList, this.listCount,
      this.isMaybe, this.isEnum, this.isUnion, this.isScalar);

  final String name;

  final String fieldName;

  final bool isList;

  final int listCount;

  final bool isMaybe;

  final bool isEnum;

  final bool isUnion;

  final bool isScalar;
}
