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
                          : (isLeft ? provider.leftGridView : provider.rightGridView)
                              ? GridView.builder(
                                  padding: const EdgeInsets.all(8),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: files.length,
                                  itemBuilder: (context, index) {
                                    return _buildFileTile(context, provider, files[index]);
                                  },
                                )
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
                icon: Icon(isLeft ? (provider.leftGridView ? PhosphorIcons.listDashes() : PhosphorIcons.gridFour()) : (provider.rightGridView ? PhosphorIcons.listDashes() : PhosphorIcons.gridFour())),
                onPressed: () {
                  if (isLeft) {
                    provider.toggleLeftView();
                  } else {
                    provider.toggleRightView();
                  }
                },
                tooltip: isLeft 
                  ? (provider.leftGridView ? 'Switch to list view' : 'Switch to grid view')
                  : (provider.rightGridView ? 'Switch to list view' : 'Switch to grid view'),
              ),
              IconButton(
                icon: Icon(showHidden ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(showHidden ? 'Hide Hidden Files?' : 'Show Hidden Files?'),
                      content: Text(
                        showHidden
                            ? 'This will hide all hidden files and directories (starting with a dot).'
                            : 'This will show all hidden files and directories (starting with a dot).',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    if (isLeft) {
                      provider.toggleLeftHidden();
                    } else {
                      provider.toggleRightHidden();
                    }
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
    final isGridView = isLeft ? provider.leftGridView : provider.rightGridView;

    if (isGridView) {
      return _buildGridItem(context, provider, file);
    } else {
      return _buildListItem(context, provider, file);
    }
  }

  Widget _buildListItem(
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
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    FileBrowserProvider provider,
    FileItem file,
  ) {
    return Draggable<String>(
      data: file.path,
      feedback: Material(
        elevation: 4,
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getFileIcon(file.type), color: Colors.white, size: 32),
              const SizedBox(height: 4),
              Text(
                file.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      child: DragTarget<String>(
        onAcceptWithDetails: (details) {
          if (file.type == FileType.directory) {
            _handleDrop(context, provider, details.data, file.path, file.name);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        if (file.type == FileType.directory) {
                          if (isLeft) {
                            provider.loadLeftDirectory(file.path);
                          } else {
                            provider.loadRightDirectory(file.path);
                          }
                        }
                      },
                      child: _buildThumbnail(file),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                file.sizeFormatted,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(PhosphorIcons.copy(), size: 14),
                                    onPressed: () => provider.stageForCopy(file.path),
                                    tooltip: 'Stage for copy',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: Icon(PhosphorIcons.scissors(), size: 14),
                                    onPressed: () => provider.stageForMove(file.path),
                                    tooltip: 'Stage for move',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(FileItem file) {
    if (file.type == FileType.image) {
      return Image.file(
        File(file.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(PhosphorIcons.image(), size: 48, color: Colors.grey),
            ),
          );
        },
      );
    } else if (file.type == FileType.video) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(PhosphorIcons.filmStrip(), size: 48, color: Colors.grey),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Icon(_getFileIcon(file.type), size: 48, color: Colors.grey),
        ),
      );
    }
  }

  void _handleDrop(
    BuildContext context,
    FileBrowserProvider provider,
    String sourcePath,
    String destinationPath,
    String destDirectoryName,
  ) async {
    // Check if source and destination are the same
    final sourceDirectory = sourcePath.substring(0, sourcePath.lastIndexOf(Platform.pathSeparator));
    if (sourceDirectory == destinationPath) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot move file to the same directory'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

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
