import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchTool extends StatefulWidget {
  final Function(String) onSearchTag;

  const SearchTool({Key? key, required this.onSearchTag}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchTool> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _options = [];
  List<dynamic> _filteredOptions = [];
  bool showOverlay = false;
  OverlayEntry? _overlayEntry;
  List<OverlayEntry> _overlayEntries = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      var jsonData = json.encode(<String, dynamic>{"limit": 10000});
      final response = await http
          .post(Uri.parse('http://127.0.0.1:8000/api/tag'), body: jsonData);
      final data = json.decode(utf8.decode(response.bodyBytes));
      _options = data["tags"];
    });
  }

  void removeAllOverlays() {
    for (var entry in _overlayEntries) {
      entry.remove();
    }
    _overlayEntries.clear(); // 清空列表
  }

  void _updateFilteredOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        print(1);
        _filteredOptions = [];
        print(_overlayEntry);
        print(_overlayEntry == null);
        if (_overlayEntry != null) {
          print("我要remove了");
          removeAllOverlays();
          _overlayEntry = null;
        }
      } else {
        print(2);
        _filteredOptions = _options
            .where(
                (option) => option.toLowerCase().contains(query.toLowerCase()))
            .toList();
        print("我要show了");
        showOverlayFunction(context);
      }
    });
  }

  void showOverlayFunction(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: offset.dy + renderBox.size.height,
          left: offset.dx,
          child: _buildOverlayContent(),
        );
      },
    );
    _overlayEntries.add(_overlayEntry!);
    overlayState.insert(_overlayEntry!);
    // overlayState.insert(_overlayEntry!);
  }

  Widget _buildOverlayContent() {
    return Center(
      child: Container(
        height: 1000,
        width: 3000,
        child: Card(
          elevation: 4,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredOptions.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(_filteredOptions[index]),
                onTap: () {
                  _searchController.text = _filteredOptions[index];
                  widget.onSearchTag(_filteredOptions[index]);
                  _updateFilteredOptions('');
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 10.0),
            Icon(Icons.search),
            SizedBox(width: 10.0),
            Flexible(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '在这里输入Tag',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _updateFilteredOptions(value);
                },
                onSubmitted: (value) {
                  if (_overlayEntry != null) {
                    removeAllOverlays();
                    _overlayEntry = null;
                  }
                  widget.onSearchTag(value);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _updateFilteredOptions('');
              },
            ),
            SizedBox(width: 10.0),
          ],
        ),
      ],
    );
  }
}
