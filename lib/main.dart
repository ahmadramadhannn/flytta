import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'providers/file_browser_provider.dart';
import 'providers/history_provider.dart';
import 'widgets/file_browser_panel.dart';
import 'widgets/staging_panel.dart';
import 'widgets/history_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileBrowserProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Flytta - File Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(PhosphorIcons.folders()),
            const SizedBox(width: 8),
            const Text('Flytta'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.clockCounterClockwise()),
            onPressed: () => _showHistoryDialog(context),
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: FileBrowserPanel(
                    isLeft: true,
                    title: 'Source',
                  ),
                ),
                Expanded(
                  child: FileBrowserPanel(
                    isLeft: false,
                    title: 'Destination',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<FileBrowserProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: () => _showStagingDialog(context, provider),
            tooltip: 'Staging Area (${provider.stagedItemCount} items)',
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(PhosphorIcons.tray()),
                if (provider.stagedItemCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${provider.stagedItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            children: [
              AppBar(
                title: const Text('Operation History'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(PhosphorIcons.x()),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Expanded(
                child: HistoryPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStagingDialog(BuildContext context, FileBrowserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              AppBar(
                title: const Text('Staging Area'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(PhosphorIcons.x()),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: StagingPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
