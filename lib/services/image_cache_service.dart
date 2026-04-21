import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, ui.Image> _cache = {};
  final Map<String, FileImage> _fileImageCache = {};
  static const int _maxCacheSize = 100;

  FileImage getImage(String path) {
    if (_fileImageCache.containsKey(path)) {
      return _fileImageCache[path]!;
    }

    // Evict oldest if cache is full
    if (_fileImageCache.length >= _maxCacheSize) {
      final firstKey = _fileImageCache.keys.first;
      _fileImageCache.remove(firstKey);
    }

    final fileImage = FileImage(File(path));
    _fileImageCache[path] = fileImage;
    return fileImage;
  }

  void clear() {
    _cache.clear();
    _fileImageCache.clear();
  }

  void evict(String path) {
    _cache.remove(path);
    _fileImageCache.remove(path);
  }
}
