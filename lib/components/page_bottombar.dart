import 'package:flutter/material.dart';

/**
 * 传入总页数，以及改变的回调函数
 * 页数为totalPages
 * */
class PageBottomBar extends StatefulWidget {
  final Function(int) onPageChange;
  final int totalPages;

  PageBottomBar({
    required this.onPageChange,
    required this.totalPages,
  });

  @override
  _PageBottomBarState createState() => _PageBottomBarState();
}

class _PageBottomBarState extends State<PageBottomBar> {
  final TextEditingController bottomPageController = TextEditingController();
  int index = 1;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                if (index == 1) {
                  widget.onPageChange(1);
                } else {
                  index = index - 1;
                  widget.onPageChange(index);
                }
              },
              icon: Icon(Icons.chevron_left)),
          Container(
            width: 50,
            child: TextField(
              controller: bottomPageController,
              decoration: InputDecoration(
                hintText: (index).toString(),
              ),
              textAlign: TextAlign.center,
              onSubmitted: (value) {
                int newPageIndex = int.parse(value);
                widget.onPageChange(newPageIndex);
                index = newPageIndex;
                bottomPageController.clear();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              if (index == widget.totalPages) {
                widget.onPageChange(widget.totalPages);
              } else {
                index = index + 1;
                widget.onPageChange(index);
              }
            },
            icon: Icon(Icons.chevron_right),
          ),
          SizedBox(
            width: 200,
          ),
          Text("共${widget.totalPages}页")
        ],
      ),
    );
  }
}
