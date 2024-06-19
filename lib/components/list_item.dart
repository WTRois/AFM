import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class ListItem extends StatefulWidget {
  final String title;
  final String subTitle;
  final Function onTap;
  final Widget? badge;
  const ListItem(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.onTap,
      this.badge})
      : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 16),
                  ),
                  (widget.badge != null)
                      ? widget.badge!
                      : Container(),
                ],
              ),
              Text(widget.subTitle,
                  style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  textAlign: TextAlign.start),
            ],
          ),
        ),
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 3,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
      ),
      onTap: () {
        widget.onTap();
      },
    );
  }
}
