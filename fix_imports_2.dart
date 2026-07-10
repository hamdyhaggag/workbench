import 'dart:io';

void main() {
  final dir = Directory('e:/Coding/workbench/lib');
  final entities = dir.listSync(recursive: true);

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      var newContent = content;

      // Fix wrong internal imports to absolute ones
      newContent = newContent.replaceAll("import '../domain/entities/item_entity.dart';", "import 'package:workbench/features/items/domain/entities/item_entity.dart';");
      newContent = newContent.replaceAll("import '../presentation/providers/item_providers.dart';", "import 'package:workbench/features/items/presentation/providers/item_providers.dart';");
      newContent = newContent.replaceAll("import '../presentation/widgets/item_type_badge.dart';", "import 'package:workbench/features/items/presentation/widgets/item_type_badge.dart';");
      newContent = newContent.replaceAll("import '../domain/entities/project_entity.dart';", "import 'package:workbench/features/projects/domain/entities/project_entity.dart';");

      if (newContent != content) {
        print('Fixed \${entity.path}');
        entity.writeAsStringSync(newContent);
      }
    }
  }
}
