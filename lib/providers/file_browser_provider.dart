import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/file_item.dart';
import '../models/staged_item.dart';
import '../services/file_system_service.dart';

class FileBrowserProvider with ChangeNotifier {
  final FileSystemService fileSystemService = FileSystemService();

  // Left panel state
  String _leftPath = FileSystemService.homeDirectory;
  List<FileItem> _leftFiles = [];
  FileType? _leftFilterType;
  bool _leftShowHidden = false;
  String _leftSearchQuery = '';
  bool _leftGridView = false;

  // Right panel state
  String _rightPath = FileSystemService.homeDirectory;
  List<FileItem> _rightFiles = [];
  FileType? _rightFilterType;
  bool _rightShowHidden = false;
  String _rightSearchQuery = '';
  bool _rightGridView = false;

  // Staged items (temporary bucket)
  final List<StagedItem> _stagedItems = [];

  // Getters
  String get leftPath => _leftPath;
  List<FileItem> get leftFiles => _leftFiles;
  FileType? get leftFilterType => _leftFilterType;
  bool get leftShowHidden => _leftShowHidden;
  String get leftSearchQuery => _leftSearchQuery;
  bool get leftGridView => _leftGridView;

  String get rightPath => _rightPath;
  List<FileItem> get rightFiles => _rightFiles;
  FileType? get rightFilterType => _rightFilterType;
  bool get rightShowHidden => _rightShowHidden;
  String get rightSearchQuery => _rightSearchQuery;
  bool get rightGridView => _rightGridView;

  List<StagedItem> get stagedItems => List.unmodifiable(_stagedItems);
  int get stagedItemCount => _stagedItems.length;

  FileBrowserProvider() {
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    await loadLeftDirectory(_leftPath);
    await loadRightDirectory(_rightPath);
  }

  Future<void> loadLeftDirectory(String path) async {
    _leftPath = path;
    _leftFiles = await fileSystemService.getDirectoryContents(
      path,
      showHidden: _leftShowHidden,
      filterType: _leftFilterType,
    );
    _applyLeftSearch();
    notifyListeners();
  }

  Future<void> loadRightDirectory(String path) async {
    _rightPath = path;
    _rightFiles = await fileSystemService.getDirectoryContents(
      path,
      showHidden: _rightShowHidden,
      filterType: _rightFilterType,
    );
    _applyRightSearch();
    notifyListeners();
  }

  void navigateLeftUp() {
    final parent = fileSystemService.getParentDirectory(_leftPath);
    if (parent != _leftPath) {
      loadLeftDirectory(parent);
    }
  }

  void navigateRightUp() {
    final parent = fileSystemService.getParentDirectory(_rightPath);
    if (parent != _rightPath) {
      loadRightDirectory(parent);
    }
  }

  void setLeftFilterType(FileType? type) {
    _leftFilterType = type;
    loadLeftDirectory(_leftPath);
  }

  void setRightFilterType(FileType? type) {
    _rightFilterType = type;
    loadRightDirectory(_rightPath);
  }

  void toggleLeftHidden() {
    _leftShowHidden = !_leftShowHidden;
    loadLeftDirectory(_leftPath);
  }

  void toggleRightHidden() {
    _rightShowHidden = !_rightShowHidden;
    loadRightDirectory(_rightPath);
  }

  void setLeftSearchQuery(String query) {
    _leftSearchQuery = query;
    _applyLeftSearch();
    notifyListeners();
  }

  void setRightSearchQuery(String query) {
    _rightSearchQuery = query;
    _applyRightSearch();
    notifyListeners();
  }

  void toggleLeftView() {
    _leftGridView = !_leftGridView;
    notifyListeners();
  }

  void toggleRightView() {
    _rightGridView = !_rightGridView;
    notifyListeners();
  }

  void _applyLeftSearch() {
    if (_leftSearchQuery.isEmpty) {
      _leftFiles = fileSystemService.getDirectoryContentsSync(
        _leftPath,
        showHidden: _leftShowHidden,
        filterType: _leftFilterType,
      );
    } else {
      final allFiles = fileSystemService.getDirectoryContentsSync(
        _leftPath,
        showHidden: _leftShowHidden,
        filterType: _leftFilterType,
      );
      _leftFiles = allFiles
          .where((file) =>
              file.name.toLowerCase().contains(_leftSearchQuery.toLowerCase()))
          .toList();
    }
  }

  void _applyRightSearch() {
    if (_rightSearchQuery.isEmpty) {
      _rightFiles = fileSystemService.getDirectoryContentsSync(
        _rightPath,
        showHidden: _rightShowHidden,
        filterType: _rightFilterType,
      );
    } else {
      final allFiles = fileSystemService.getDirectoryContentsSync(
        _rightPath,
        showHidden: _rightShowHidden,
        filterType: _rightFilterType,
      );
      _rightFiles = allFiles
          .where((file) =>
              file.name.toLowerCase().contains(_rightSearchQuery.toLowerCase()))
          .toList();
    }
  }

  void stageForCopy(String filePath) {
    _stagedItems.add(StagedItem(path: filePath, operation: StagedOperation.copy));
    notifyListeners();
  }

  void stageForMove(String filePath) {
    _stagedItems.add(StagedItem(path: filePath, operation: StagedOperation.move));
    notifyListeners();
  }

  void removeStagedItem(int index) {
    _stagedItems.removeAt(index);
    notifyListeners();
  }

  void clearStagedItems() {
    _stagedItems.clear();
    notifyListeners();
  }

  Future<bool> executeStagedOperations(String destinationPath) async {
    bool allSuccess = true;
    
    for (final item in _stagedItems) {
      bool success;
      final fileName = item.path.split(Platform.pathSeparator).last;
      final destPath = '$destinationPath${Platform.pathSeparator}$fileName';
      
      if (item.operation == StagedOperation.copy) {
        success = await fileSystemService.copyFile(item.path, destPath);
      } else {
        success = await fileSystemService.moveFile(item.path, destPath);
      }
      
      if (!success) allSuccess = false;
    }
    
    if (allSuccess) {
      _stagedItems.clear();
      await loadRightDirectory(destinationPath);
      notifyListeners();
    }
    
    return allSuccess;
  }

  Future<bool> copyFile(String sourcePath, String destinationPath) async {
    return await fileSystemService.copyFile(sourcePath, destinationPath);
  }

  Future<bool> moveFile(String sourcePath, String destinationPath) async {
    return await fileSystemService.moveFile(sourcePath, destinationPath);
  }
}

// Extension for sync version (for search filtering)
extension FileSystemServiceSync on FileSystemService {
  List<FileItem> getDirectoryContentsSync(String directoryPath, {
    bool showHidden = false,
    FileType? filterType,
  }) {
    try {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        return [];
      }

      final entities = directory.listSync();
      final items = <FileItem>[];

      for (final entity in entities) {
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
}
