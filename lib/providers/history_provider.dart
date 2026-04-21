import 'package:flutter/foundation.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  List<HistoryItem> _history = [];
  bool _isLoading = false;

  List<HistoryItem> get history => _history;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    
    _history = await _historyService.getHistory();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHistoryItem({
    required String sourcePath,
    required String destinationPath,
    required String operation,
    required bool success,
  }) async {
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourcePath: sourcePath,
      destinationPath: destinationPath,
      operation: operation,
      timestamp: DateTime.now(),
      success: success,
    );
    
    await _historyService.addHistoryItem(item);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _historyService.clearHistory();
    await loadHistory();
  }
}
