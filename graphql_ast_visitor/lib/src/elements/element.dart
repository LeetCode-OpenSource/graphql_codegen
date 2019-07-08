import 'element_kind.dart';
import 'visitor.dart';

abstract class Element {
  ElementKind get kind;

  String source();

  void accept(ElementVisitor visitor);

  List<T> flat<T>(List<T> acc, List<T> cur) {
    return List.from(acc)..addAll(cur);
  }
}
