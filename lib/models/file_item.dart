import 'dart:io';

enum FileType {
  directory,
  file,
  image,
  video,
  audio,
  document,
  archive,
  code,
  other,
}

class FileItem {
  final String path;
  final String name;
  final FileType type;
  final int size;
  final DateTime modified;
  final bool isHidden;

  FileItem({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    required this.modified,
    required this.isHidden,
  });

  factory FileItem.fromFileSystemEntity(FileSystemEntity entity) {
    final stat = entity.statSync();
    final path = entity.path;
    final name = path.split(Platform.pathSeparator).last;
    
    FileType type;
    bool isHidden = name.startsWith('.');
    
    if (entity is Directory) {
      type = FileType.directory;
    } else {
      // Determine file type by extension
      final extension = name.split('.').last.toLowerCase();
      type = _getFileTypeFromExtension(extension);
    }

    return FileItem(
      path: path,
      name: name,
      type: type,
      size: stat.size,
      modified: stat.modified,
      isHidden: isHidden,
    );
  }

  static FileType _getFileTypeFromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
        return FileType.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
        return FileType.video;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'aac':
      case 'ogg':
        return FileType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
      case 'odt':
        return FileType.document;
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return FileType.archive;
      case 'dart':
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'cpp':
      case 'c':
      case 'html':
      case 'css':
      case 'json':
      case 'xml':
        return FileType.code;
      default:
        return FileType.other;
    }
  }

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
