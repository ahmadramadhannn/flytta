import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';

class HistoryPanel extends StatelessWidget {
  const HistoryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        final history = provider.history;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.clockCounterClockwise()),
                  const SizedBox(width: 8),
                  const Text(
                    'Operation History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => provider.clearHistory(),
                      icon: Icon(PhosphorIcons.trash(), size: 16),
                      label: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(PhosphorIcons.clock(), size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'No history yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              return _buildHistoryTile(history[index]);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTile(HistoryItem item) {
    final operationIcon = _getOperationIcon(item.operation);
    final operationColor = _getOperationColor(item.operation);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(operationIcon, color: operationColor),
        title: Text(item.operation.toUpperCase()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${item.sourcePath}'),
            Text('To: ${item.destinationPath}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              item.success ? PhosphorIcons.checkCircle() : PhosphorIcons.xCircle(),
              color: item.success ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(item.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOperationIcon(String operation) {
    switch (operation.toLowerCase()) {
      case 'copy':
        return PhosphorIcons.copy();
      case 'move':
        return PhosphorIcons.scissors();
      case 'delete':
        return PhosphorIcons.trash();
      default:
        return PhosphorIcons.circle();
    }
  }

  Color _getOperationColor(String operation) {
    switch (operation.toLowerCase()) {
      case 'copy':
        return Colors.blue;
      case 'move':
        return Colors.orange;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
