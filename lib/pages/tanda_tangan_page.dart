import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class TandaTanganPage extends StatefulWidget {
  const TandaTanganPage({Key? key}) : super(key: key);

  @override
  _TandaTanganPageState createState() => _TandaTanganPageState();
}

class _TandaTanganPageState extends State<TandaTanganPage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tanda Tangan"),
          backgroundColor: Colors.blue[900],
        ),
        body: ListView(
          children: [
            
            Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  //SHOW EXPORTED IMAGE IN NEW ROUTE
                  IconButton(
                    icon: const Icon(Icons.check),
                    color: Colors.blue,
                    onPressed: () async {
                      if (_controller.isNotEmpty) {
                        final Uint8List? data = await _controller.toPngBytes();
                        
                        if (data != null) {
                          Navigator.pop(context, data);
                          // await Navigator.of(context).push(
                          //   MaterialPageRoute<void>(
                          //     builder: (BuildContext context) {
                          //       return Scaffold(
                          //         appBar: AppBar(),
                          //         body: Center(
                          //           child: Container(
                          //             color: Colors.grey[300],
                          //             child: Image.memory(data),
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() => _controller.undo());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() => _controller.redo());
                    },
                  ),
                  //CLEAR CANVAS
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() => _controller.clear());
                    },
                  ),
                ],
              ),
            ),
            Signature(
                controller: _controller,
                height: (MediaQuery.of(context).size.height-175),
                backgroundColor: Color.fromARGB(255, 243, 243, 243),
              ),
          ],
        ));
  }
}
