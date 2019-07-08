import 'visitor.dart';

abstract class Element {
  void accept(ElementVisitor visitor);

  List<Element> children;

  String source();
}
