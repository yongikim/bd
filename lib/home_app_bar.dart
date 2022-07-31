import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyText1!.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      pinned: false,
      snap: false,
      floating: false,
      backgroundColor: Theme.of(context).canvasColor,
      foregroundColor: Theme.of(context).canvasColor,
    );
  }
}
