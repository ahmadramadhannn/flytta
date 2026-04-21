import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/staged_item.dart';
import '../providers/file_browser_provider.dart';

class StagingPanel extends StatelessWidget {
  const StagingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileBrowserProvider>(
      builder: (context, provider, child) {
        final stagedItems = provider.stagedItems;

        return Container(
          height: 200,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Column(
            children: [
              _buildHeader(context, provider, stagedItems.length),
              Expanded(
                child: stagedItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.tray(), size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'Staging area is empty',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Stage files by clicking copy/move buttons',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: stagedItems.length,
                        itemBuilder: (context, index) {
                          return _buildStagedItemTile(
                            context,
                            provider,
                            stagedItems[index],
                            index,
                          );
                        },
                      ),
              ),
              if (stagedItems.isNotEmpty) _buildActionButtons(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FileBrowserProvider provider, int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.tray()),
          const SizedBox(width: 8),
          const Text(
            'Staging Area',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '($itemCount items)',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          if (itemCount > 0)
            TextButton.icon(
              onPressed: () => provider.clearStagedItems(),
              icon: Icon(PhosphorIcons.trash(), size: 16),
              label: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget _buildStagedItemTile(
    BuildContext context,
    FileBrowserProvider provider,
    StagedItem item,
    int index,
  ) {
    final fileName = item.path.split('/').last;
    final isCopy = item.operation == StagedOperation.copy;

    return ListTile(
      leading: Icon(
        isCopy ? PhosphorIcons.copy() : PhosphorIcons.scissors(),
        color: isCopy ? Colors.blue : Colors.orange,
      ),
      title: Text(fileName),
      subtitle: Text(item.path),
      trailing: IconButton(
        icon: Icon(PhosphorIcons.x()),
        onPressed: () => provider.removeStagedItem(index),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FileBrowserProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final success = await provider.executeStagedOperations(provider.rightPath);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Operations completed successfully' : 'Some operations failed'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            icon: Icon(PhosphorIcons.check()),
            label: const Text('Execute to Right Panel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
