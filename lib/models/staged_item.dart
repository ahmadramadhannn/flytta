enum StagedOperation {
  copy,
  move,
}

class StagedItem {
  final String path;
  final StagedOperation operation;

  StagedItem({
    required this.path,
    required this.operation,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'operation': operation.name,
    };
  }

  factory StagedItem.fromJson(Map<String, dynamic> json) {
    return StagedItem(
      path: json['path'],
      operation: StagedOperation.values.firstWhere(
        (e) => e.name == json['operation'],
      ),
    );
  }
}
