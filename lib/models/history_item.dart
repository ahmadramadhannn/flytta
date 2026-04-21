class HistoryItem {
  final String id;
  final String sourcePath;
  final String destinationPath;
  final String operation; // 'copy', 'move', 'delete'
  final DateTime timestamp;
  final bool success;

  HistoryItem({
    required this.id,
    required this.sourcePath,
    required this.destinationPath,
    required this.operation,
    required this.timestamp,
    required this.success,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourcePath': sourcePath,
      'destinationPath': destinationPath,
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      sourcePath: json['sourcePath'],
      destinationPath: json['destinationPath'],
      operation: json['operation'],
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'],
    );
  }
}
