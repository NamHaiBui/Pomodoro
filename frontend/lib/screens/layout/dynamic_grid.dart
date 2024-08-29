import 'package:flutter/material.dart';

class DraggableGridScreen extends StatefulWidget {
  const DraggableGridScreen({super.key});

  @override
  State<DraggableGridScreen> createState() => _DraggableGridScreenState();
}

class _DraggableGridScreenState extends State<DraggableGridScreen> {
  // Placeholder widgets
  final List<Widget> bottomRowWidgets = [
    Container(color: Colors.blue, child: const Center(child: Text('Widget 1'))),
    Container(
        color: Colors.green, child: const Center(child: Text('Widget 2'))),
    Container(
        color: Colors.orange, child: const Center(child: Text('Widget 3'))),
  ];

  // Grid cells (initially empty)
  late List<Widget?> gridCells;

  @override
  void initState() {
    super.initState();
    gridCells = List.generate(6, (_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Grid')),
      body: Column(
        children: [
          // Grid area
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GridView.builder(
                  itemCount: gridCells.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3x2 grid
                    childAspectRatio: constraints.maxWidth /
                        (constraints.maxHeight *
                            0.8), // Adjust the aspect ratio to fit the screen
                  ),
                  itemBuilder: (context, index) {
                    return DragTarget<Map<String, dynamic>>(
                      builder: (context, candidateData, rejectedData) {
                        Widget cellContent = Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: gridCells[index] ?? Container(),
                        );

                        // Only make the cell draggable if it contains a widget
                        if (gridCells[index] != null) {
                          return Draggable<Map<String, dynamic>>(
                            data: {'index': index, 'isGridCell': true},
                            feedback: Material(
                              elevation: 5,
                              child: SizedBox(
                                width: constraints.maxWidth / 3,
                                height: constraints.maxHeight / 3,
                                child: gridCells[index]!,
                              ),
                            ),
                            childWhenDragging:
                                Container(color: Colors.grey.withOpacity(0.5)),
                            child: cellContent,
                          );
                        } else {
                          return cellContent;
                        }
                      },
                      onAcceptWithDetails: (details) {
                        setState(() {
                          if (details.data['isGridCell'] == true) {
                            // Swap widgets within the grid
                            final sourceIndex = details.data['index'] as int;
                            final tempWidget = gridCells[index];
                            gridCells[index] = gridCells[sourceIndex];
                            gridCells[sourceIndex] = tempWidget;
                          } else {
                            // Move widget from bottom row to grid
                            final bottomRowIndex = details.data['index'] as int;
                            gridCells[index] = bottomRowWidgets[bottomRowIndex];
                            bottomRowWidgets.removeAt(bottomRowIndex);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Draggable widgets area
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: bottomRowWidgets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Draggable<Map<String, dynamic>>(
                    data: {'index': index, 'isGridCell': false},
                    feedback: Material(
                      elevation: 5,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: bottomRowWidgets[index],
                      ),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: bottomRowWidgets[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DraggableGridScreen(),
  ));
}
