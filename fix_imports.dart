import 'dart:io';

void main() {
  final dir = Directory('e:/Coding/workbench/lib');
  final entities = dir.listSync(recursive: true);

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      var newContent = content;

      // Fix core imports
      newContent = newContent.replaceAll(RegExp(r"import '(\.\./)+core/"), "import 'package:workbench/core/");
      
      // Fix features imports
      newContent = newContent.replaceAllMapped(
        RegExp(r"import '(\.\./)+(projects|items|auth|home|search|settings)/"),
        (match) => "import 'package:workbench/features/${match.group(2)}/"
      );

      // Fix specific hardcoded error for item_type_badge
      newContent = newContent.replaceAll("import 'widgets/item_type_badge.dart'", "import 'package:workbench/features/items/presentation/widgets/item_type_badge.dart'");

      if (newContent != content) {
        print('Fixed \${entity.path}');
        entity.writeAsStringSync(newContent);
      }
    }
  }
}
