import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef void OnItemTapped(int index);

class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> list;
  final int radius;
  final Duration duration;
  final Curve curve;
  final int itemSize;
  final iconColor;
  final OnItemTapped onItemTapped;
  final Widget child;
  const RadialMenu(
      {Key key,
      this.list,
      this.radius = 100,
      this.duration = const Duration(seconds: 1),
      this.curve = Curves.linearToEaseOut,
      this.itemSize = 50,
      this.iconColor = Colors.white,
      this.onItemTapped,
      @required this.child})
      : super(key: key);

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation scaleAnimation;
  Animation<double> translationAnimation;
  Animation rotateAnimation;
  Animation angleAnimation;
  double angleDelta = 0.0;
  RadialMenuState menuState = RadialMenuState.Closed;
  @override
  void initState() {
    // TODO: implement initState

    angleDelta = 360 / widget.list.length;

    animationController = AnimationController(vsync: this)
      ..duration = widget.duration
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.completed:
            menuState = RadialMenuState.Opened;
            break;

          case AnimationStatus.dismissed:
            menuState = RadialMenuState.Closed;
            break;

          case AnimationStatus.forward:
            menuState = RadialMenuState.Opening;
            break;

          case AnimationStatus.reverse:
            menuState = RadialMenuState.Closing;
            break;

          default:
        }
      });

    scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: animationController, curve: Curves.easeInToLinear));

    translationAnimation =
        Tween<double>(begin: 0.0, end: widget.radius.toDouble()).animate(
            CurvedAnimation(parent: animationController, curve: widget.curve));

    rotateAnimation = Tween<double>(begin: 0.0, end: 360.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.0, 0.5, curve: widget.curve)));

    angleAnimation = Tween<double>(begin: 0.0, end: 10).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0.0, 0.5, curve: widget.curve)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wlist = [];
    wlist.add(widget.child);

   if(menuState==RadialMenuState.Opened)
   {
     wlist.add( GestureDetector(
       onTap: (){ _close(); },
           child: Container(
               color:Colors.black12.withOpacity(0.5)
           ),    
     ) );
   }


    wlist.addAll(_buildButtonList());

    wlist.add(_buildcloseButton());
    wlist.add(_buildOpenButton());
    return Stack(alignment: Alignment.center, children: wlist);
  }

  _buildcloseButton() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2 - widget.itemSize / 2),
      top: (MediaQuery.of(context).size.height / 2 - widget.itemSize / 2),
      child: Transform.scale(
        scale: scaleAnimation.value - 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _close();
            },
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              width: widget.itemSize.toDouble(),
              height: widget.itemSize.toDouble(),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildOpenButton() {
    return Positioned(
        left: (MediaQuery.of(context).size.width / 2 - widget.itemSize / 2),
        top: (MediaQuery.of(context).size.height / 2 - widget.itemSize / 2),
        child: Transform.scale(
          scale: scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _open();
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                width: widget.itemSize.toDouble(),
                height: widget.itemSize.toDouble(),
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  _buildButtonList() {
    List<Widget> list = [];
    double angleInc = angleDelta;
    double angle = 0.0;
    RadialMenuItem item;
    for (var i = 0; i < widget.list.length; i++) {
      item = widget.list[i];
      list.add(_buildButton(item, angle, i));
      angle += angleInc;
    }

    return list;
  }

  _buildButton(RadialMenuItem item, double angle, int i) {
    double angleInRadians = angle * (math.pi / 180);
    return Positioned(
      left: ((MediaQuery.of(context).size.width / 2) - widget.itemSize / 2) +
          translationAnimation.value *
              math.cos(angleInRadians + angleAnimation.value),
      top: ((MediaQuery.of(context).size.height / 2) - widget.itemSize / 2) +
          translationAnimation.value *
              math.sin(angleInRadians + angleAnimation.value),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onItemTapped != null) {
                widget.onItemTapped(i);
                _close();
            }
          },
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.color,
                ),
                width: widget.itemSize.toDouble(),
                height: widget.itemSize.toDouble(),
                child: Icon(
                  item.icon,
                  size: widget.itemSize / 2,
                  color: Colors.white,
                ),
              ),
              Text(
                menuState == RadialMenuState.Closed ? "" : item.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }

  _open() {
    animationController.forward();
  }

  _close() {
    animationController.reverse();
  }
}

class RadialMenuItem {
  final IconData icon;
  final Color color;
  final String title;

  RadialMenuItem({this.icon, this.color, this.title});
}

enum RadialMenuState { Opened, Opening, Closed, Closing }
