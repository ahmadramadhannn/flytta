# Flytta

A dual-pane file transfer tool for desktop built with Flutter. Browse source and destination directories, then drag and drop files to copy or move them efficiently.

## Features

- **Dual-panel interface** - Source and destination panels for efficient file operations
- **Drag and drop** - Drag files between panels or drop into directories to copy/move
- **Staging area** - Stage multiple files for batch copy/move operations
- **Grid and list views** - Toggle between grid and list view for file browsing
- **File filtering** - Filter by type: images, videos, audio, documents, archives, code
- **Search** - Quick file search within current directory
- **Breadcrumb navigation** - Click path segments to navigate quickly
- **Operation history** - Track your recent copy/move operations
- **Hidden files toggle** - Show or hide hidden files and directories
- **Image thumbnails** - Preview images in grid view with caching for smooth scrolling

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- For Linux: GTK development libraries
- For macOS: Xcode command line tools
- For Windows: Visual Studio with C++ desktop development tools

### Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run -d linux  # or -d macos, -d windows
```

### Building

```bash
# Debug build
flutter build linux --debug  # or -d macos, -d windows

# Release build
flutter build linux --release  # or -d macos, -d windows
```

## Usage

1. Navigate directories using the breadcrumb path or by clicking folders
2. Drag files from the source panel to the destination panel
3. Use the staging button (tray icon) to stage files for batch operations
4. Filter files by type using the filter chips
5. Toggle grid/list view using the view toggle button
6. Search files using the search bar
7. View operation history using the clock icon in the app bar

## License

MIT
