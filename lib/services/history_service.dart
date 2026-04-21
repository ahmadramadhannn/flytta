import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _historyKey = 'file_operation_history';
  static const int _maxHistoryItems = 100;

  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    
    if (historyJson == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(historyJson);
      return decoded.map((item) => HistoryItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    final history = await getHistory();
    history.insert(0, item);
    
    // Keep only the last N items
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    await _saveHistory(history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> _saveHistory(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(history.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, historyJson);
  }
}
