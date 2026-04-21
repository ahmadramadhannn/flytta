import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TabData {
  final String id;
  final String title;
  final Widget content;

  TabData({
    required this.id,
    required this.title,
    required this.content,
  });
}

class TabBarWidget extends StatefulWidget {
  final List<TabData> tabs;
  final Function(int)? onTabChanged;

  const TabBarWidget({
    super.key,
    required this.tabs,
    this.onTabChanged,
  });

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: widget.tabs[_selectedIndex].content,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.tabs.length, (index) {
            final isSelected = index == _selectedIndex;
            return _buildTab(widget.tabs[index], index, isSelected);
          }),
        ),
      ),
    );
  }

  Widget _buildTab(TabData tab, int index, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTabChanged?.call(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: const Border(
            right: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab.title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(PhosphorIcons.x(), size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
