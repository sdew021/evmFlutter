import 'dart:io';

import 'package:evmflutter/FingerprintAuth.dart';
import 'package:evmflutter/ViewResult.dart';
import 'package:evmflutter/Vote.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      if (Platform.isIOS || Platform.isAndroid) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Vote()),
                            (r) => false);
                      } else {
                        final snackbar =
                            SnackBar(content: Text("$Platform Not Supported"));
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      }
                    } catch (e) {
                      // final snackbar =
                      //     SnackBar(content: Text("Platform Not Supported"));
                      // ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Vote()),
                          (r) => false);
                    }
                  },
                  child: Text("Vote"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FingerprintAuthWidget(),
                      ),
                    );
                  },
                  child: Text("Fingerprint Auth"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewResult(),
                      ),
                    );
                  },
                  child: Text("View Result"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
