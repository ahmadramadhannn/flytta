import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/file_item.dart';
import '../models/staged_item.dart';
import '../services/file_system_service.dart';

class FileBrowserProvider with ChangeNotifier {
  final FileSystemService fileSystemService = FileSystemService();

  // Left panel state
  String _leftPath = FileSystemService.homeDirectory;
  List<FileItem> _leftAllFiles = []; // Cached base list from disk
  List<FileItem> _leftFiles = []; // Filtered/searched result
  FileType? _leftFilterType;
  bool _leftShowHidden = false;
  String _leftSearchQuery = '';
  bool _leftGridView = false;

  // Right panel state
  String _rightPath = FileSystemService.homeDirectory;
  List<FileItem> _rightAllFiles = []; // Cached base list from disk
  List<FileItem> _rightFiles = []; // Filtered/searched result
  FileType? _rightFilterType;
  bool _rightShowHidden = false;
  String _rightSearchQuery = '';
  bool _rightGridView = false;

  // Staged items (temporary bucket)
  final List<StagedItem> _stagedItems = [];

  // Search debounce timers
  Timer? _leftSearchDebounce;
  Timer? _rightSearchDebounce;

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

  List<StagedItem> get stagedItems => _stagedItems;
  int get stagedItemCount => _stagedItems.length;

  FileBrowserProvider() {
    _loadDirectories();
  }

  @override
  void dispose() {
    _leftSearchDebounce?.cancel();
    _rightSearchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadDirectories() async {
    await Future.wait([
      loadLeftDirectory(_leftPath),
      loadRightDirectory(_rightPath),
    ]);
  }

  Future<void> loadLeftDirectory(String path) async {
    _leftPath = path;
    _leftAllFiles = await fileSystemService.getDirectoryContents(
      path,
      showHidden: _leftShowHidden,
      filterType: _leftFilterType,
    );
    _applyLeftSearch();
    notifyListeners();
  }

  Future<void> loadRightDirectory(String path) async {
    _rightPath = path;
    _rightAllFiles = await fileSystemService.getDirectoryContents(
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
    _leftSearchDebounce?.cancel();
    _leftSearchDebounce = Timer(const Duration(milliseconds: 150), () {
      _applyLeftSearch();
      notifyListeners();
    });
  }

  void setRightSearchQuery(String query) {
    _rightSearchQuery = query;
    _rightSearchDebounce?.cancel();
    _rightSearchDebounce = Timer(const Duration(milliseconds: 150), () {
      _applyRightSearch();
      notifyListeners();
    });
  }

  void toggleLeftView() {
    _leftGridView = !_leftGridView;
    notifyListeners();
  }

  void toggleRightView() {
    _rightGridView = !_rightGridView;
    notifyListeners();
  }

  /// Filters the cached _leftAllFiles list in-memory (no disk I/O)
  void _applyLeftSearch() {
    if (_leftSearchQuery.isEmpty) {
      _leftFiles = _leftAllFiles;
    } else {
      final query = _leftSearchQuery.toLowerCase();
      _leftFiles = _leftAllFiles
          .where((file) => file.name.toLowerCase().contains(query))
          .toList();
    }
  }

  /// Filters the cached _rightAllFiles list in-memory (no disk I/O)
  void _applyRightSearch() {
    if (_rightSearchQuery.isEmpty) {
      _rightFiles = _rightAllFiles;
    } else {
      final query = _rightSearchQuery.toLowerCase();
      _rightFiles = _rightAllFiles
          .where((file) => file.name.toLowerCase().contains(query))
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
