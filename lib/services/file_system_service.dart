import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/file_item.dart';

class FileSystemService {
  static String get homeDirectory {
    return Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.';
  }

  Future<List<FileItem>> getDirectoryContents(String directoryPath, {
    bool showHidden = false,
    FileType? filterType,
  }) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        return [];
      }

      final items = <FileItem>[];

      await for (final entity in directory.list()) {
        try {
          final fileItem = FileItem.fromFileSystemEntity(entity);

          if (!showHidden && fileItem.isHidden) {
            continue;
          }

          if (filterType != null && fileItem.type != filterType) {
            continue;
          }

          items.add(fileItem);
        } catch (e) {
          continue;
        }
      }

      items.sort((a, b) {
        if (a.type == FileType.directory && b.type != FileType.directory) {
          return -1;
        }
        if (a.type != FileType.directory && b.type == FileType.directory) {
          return 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return items;
    } catch (e) {
      return [];
    }
  }

  Future<bool> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      
      await sourceFile.copy(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      await sourceFile.rename(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> copyDirectory(String sourcePath, String destinationPath) async {
    try {
      final sourceDir = Directory(sourcePath);
      final destDir = Directory(destinationPath);
      
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      await for (final entity in sourceDir.list(recursive: true)) {
        final relativePath = path.relative(entity.path, from: sourcePath);
        final destPath = path.join(destinationPath, relativePath);

        if (entity is File) {
          await entity.copy(destPath);
        } else if (entity is Directory) {
          await Directory(destPath).create(recursive: true);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> moveDirectory(String sourcePath, String destinationPath) async {
    try {
      final sourceDir = Directory(sourcePath);
      await sourceDir.rename(destinationPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(String itemPath) async {
    try {
      final entity = FileSystemEntity.isDirectorySync(itemPath)
          ? Directory(itemPath)
          : File(itemPath);
      
      await entity.delete(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createDirectory(String path) async {
    try {
      final dir = Directory(path);
      await dir.create(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  String getParentDirectory(String currentPath) {
    return path.dirname(currentPath);
  }

  List<String> getPathSegments(String path) {
    final parts = path.split(Platform.pathSeparator);
    // Remove empty strings (from leading/trailing separators)
    return parts.where((p) => p.isNotEmpty).toList();
  }
}
