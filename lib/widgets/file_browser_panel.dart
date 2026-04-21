import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/file_item.dart';
import '../providers/file_browser_provider.dart';

class FileBrowserPanel extends StatelessWidget {
  final bool isLeft;
  final String title;

  const FileBrowserPanel({
    super.key,
    required this.isLeft,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FileBrowserProvider>(
      builder: (context, provider, child) {
        final currentPath = isLeft ? provider.leftPath : provider.rightPath;
        final files = isLeft ? provider.leftFiles : provider.rightFiles;
        final showHidden = isLeft ? provider.leftShowHidden : provider.rightShowHidden;
        final searchQuery = isLeft ? provider.leftSearchQuery : provider.rightSearchQuery;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              right: isLeft ? const BorderSide(color: Colors.grey) : BorderSide.none,
              left: !isLeft ? const BorderSide(color: Colors.grey) : BorderSide.none,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, provider, currentPath, showHidden, searchQuery),
              _buildFilterBar(context, provider),
              Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    // Handle drop in the current directory
                    _handleDrop(context, provider, details.data, currentPath, currentPath);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      color: candidateData.isNotEmpty 
                        ? Colors.blue.withOpacity(0.1) 
                        : null,
                      child: files.isEmpty
                          ? const Center(child: Text('No files found'))
                          : ListView.builder(
                              itemCount: files.length,
                              itemBuilder: (context, index) {
                                return _buildFileTile(context, provider, files[index]);
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    FileBrowserProvider provider,
    String currentPath,
    bool showHidden,
    String searchQuery,
  ) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(PhosphorIcons.arrowUUpLeft()),
                onPressed: () {
                  if (isLeft) {
                    provider.navigateLeftUp();
                  } else {
                    provider.navigateRightUp();
                  }
                },
                tooltip: 'Go up',
              ),
              IconButton(
                icon: Icon(showHidden ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
                onPressed: () {
                  if (isLeft) {
                    provider.toggleLeftHidden();
                  } else {
                    provider.toggleRightHidden();
                  }
                },
                tooltip: showHidden ? 'Hide hidden files' : 'Show hidden files',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    if (isLeft) {
                      provider.setLeftSearchQuery(value);
                    } else {
                      provider.setRightSearchQuery(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            currentPath,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, FileBrowserProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              'All',
              null,
              provider,
            ),
            _buildFilterChip(
              context,
              'Images',
              FileType.image,
              provider,
            ),
            _buildFilterChip(
              context,
              'Videos',
              FileType.video,
              provider,
            ),
            _buildFilterChip(
              context,
              'Audio',
              FileType.audio,
              provider,
            ),
            _buildFilterChip(
              context,
              'Documents',
              FileType.document,
              provider,
            ),
            _buildFilterChip(
              context,
              'Archives',
              FileType.archive,
              provider,
            ),
            _buildFilterChip(
              context,
              'Code',
              FileType.code,
              provider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    FileType? type,
    FileBrowserProvider provider,
  ) {
    final currentFilter = isLeft ? provider.leftFilterType : provider.rightFilterType;
    final isSelected = currentFilter == type;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (isLeft) {
            provider.setLeftFilterType(selected ? type : null);
          } else {
            provider.setRightFilterType(selected ? type : null);
          }
        },
      ),
    );
  }

  Widget _buildFileTile(
    BuildContext context,
    FileBrowserProvider provider,
    FileItem file,
  ) {
    return Draggable<String>(
      data: file.path,
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getFileIcon(file.type), color: Colors.white),
              const SizedBox(width: 8),
              Text(
                file.name,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          // Handle drop on file/directory
          if (file.type == FileType.directory) {
            _handleDrop(context, provider, details.data, file.path, file.name);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return ListTile(
            leading: Icon(_getFileIcon(file.type)),
            title: Text(file.name),
            subtitle: Text('${file.sizeFormatted} • ${_formatDate(file.modified)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(PhosphorIcons.copy()),
                  onPressed: () => provider.stageForCopy(file.path),
                  tooltip: 'Stage for copy',
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.scissors()),
                  onPressed: () => provider.stageForMove(file.path),
                  tooltip: 'Stage for move',
                ),
              ],
            ),
            onTap: () {
              if (file.type == FileType.directory) {
                if (isLeft) {
                  provider.loadLeftDirectory(file.path);
                } else {
                  provider.loadRightDirectory(file.path);
                }
              }
            },
          );
        },
      ),
    );
  }

  void _handleDrop(
    BuildContext context,
    FileBrowserProvider provider,
    String sourcePath,
    String destinationPath,
    String destDirectoryName,
  ) async {
    final fileName = sourcePath.split(Platform.pathSeparator).last;
    final destPath = '$destinationPath${Platform.pathSeparator}$fileName';
    
    final success = await provider.copyFile(sourcePath, destPath);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Copied $fileName to $destDirectoryName' 
            : 'Failed to copy $fileName'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
      if (success) {
        if (isLeft) {
          provider.loadLeftDirectory(destinationPath);
        } else {
          provider.loadRightDirectory(destinationPath);
        }
      }
    }
  }

  IconData _getFileIcon(FileType type) {
    switch (type) {
      case FileType.directory:
        return PhosphorIcons.folder();
      case FileType.image:
        return PhosphorIcons.image();
      case FileType.video:
        return PhosphorIcons.filmStrip();
      case FileType.audio:
        return PhosphorIcons.musicNote();
      case FileType.document:
        return PhosphorIcons.fileText();
      case FileType.archive:
        return PhosphorIcons.package();
      case FileType.code:
        return PhosphorIcons.code();
      default:
        return PhosphorIcons.file();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
