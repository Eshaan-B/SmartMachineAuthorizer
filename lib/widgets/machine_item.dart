import 'package:flutter/material.dart';
import '../screens/select_date.dart';

class MachineItem extends StatefulWidget {
  final machineType;

  MachineItem({required this.machineType});

  @override
  _MachineItemState createState() => _MachineItemState();
}

class _MachineItemState extends State<MachineItem> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GridTile(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).pushNamed(SelectDate.routeName,
                arguments: {'doc': widget.machineType});
          },
          child: Image.asset(
            widget.machineType['image'],
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(widget.machineType['name']),
        ),
      ),
    );
  }
}
