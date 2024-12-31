import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return DraggableItem(
                icon: e,
                builder: (e) {
                  return Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: 48,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.primaries[e.hashCode % Colors.primaries.length],
                    ),
                    child: Center(child: Icon(e, color: Colors.white)),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A draggable icon widget.
class DraggableItem extends StatefulWidget {
  final IconData icon;
  final Widget Function(IconData) builder;

  const DraggableItem({super.key, required this.icon, required this.builder});

  @override
  State<DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<DraggableItem> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        scale = 1.2;
      }),
      onExit: (_) => setState(() {
        scale = 1.0;
      }),
      child: Draggable<IconData>(
        data: widget.icon,
        feedback: Material(
          color: Colors.transparent,
          child: widget.builder(widget.icon),
        ),
        childWhenDragging: const SizedBox.shrink(),
        child: Transform.scale(
          scale: scale,
          child: widget.builder(widget.icon),
        ),
      ),
    );
  }
}

/// Dock widget containing draggable items.
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<IconData> items;
  final Widget Function(IconData) builder;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items); // Create a mutable list
  }

  // This method is responsible for updating the item order when dropped.
  void _onItemDropped(IconData item, int newIndex) {
    setState(() {
      // Only update the list if the item is dropped in a new position
      if (_items.indexOf(item) != newIndex) {
        _items.remove(item);
        _items.insert(newIndex, item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          return DragTarget<IconData>(
            onAccept: (receivedItem) {
              final newIndex = index;
              _onItemDropped(receivedItem, newIndex);
            },
            onWillAccept: (receivedItem) {
              return true; // Allow all items to be accepted
            },
            builder: (context, candidateItems, rejectedItems) {
              // Display draggable items
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                child: Stack(
                  children: [
                    widget.builder(_items[index]),
                    if (candidateItems.isNotEmpty)
                      Positioned.fill(
                        child: Container(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
