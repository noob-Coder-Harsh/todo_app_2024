import 'package:flutter/material.dart';

class Appbar extends StatefulWidget {
  const Appbar({Key? key});

  @override
  _AppbarState createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Handle sort button press
            },
            icon: Icon(Icons.sort),
            color: Colors.white.withOpacity(0.6),
          ),
          Spacer(), // Add spacer to push search icon to the right
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching; // Toggle search state
              });
            },
            icon: Icon(Icons.search),
            color: Colors.white.withOpacity(0.6),
          ),
          if (_isSearching)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                  onChanged: (value) {
                    // Handle search text change
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
