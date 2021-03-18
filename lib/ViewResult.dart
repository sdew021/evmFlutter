import 'package:evmflutter/Variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ViewResult extends StatefulWidget {
  @override
  _ViewResultState createState() => _ViewResultState();
}

class _ViewResultState extends State<ViewResult> {
  var electionStatus = "Open";
  var cn1, cn2, v1, v2, tv, st1 = "", st2 = "";
  @override
  void initState() {
    super.initState();
    getValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: Center(
        child: Column(
          children: [
            ListTile(
              title: Text("Election Status: $electionStatus"),
            ),
            ListTile(
              title: Text("Total Votes: $tv"),
            ),
            ListTile(
              leading: Icon(
                Icons.looks_one_outlined,
                color: Colors.white,
              ),
              title: Text(
                "$cn1",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "$st1",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                "Votes: $v1",
                style: TextStyle(color: Colors.white),
              ),
              tileColor: Colors.blue,
            ),
            ListTile(
              leading: Icon(Icons.looks_two_outlined),
              title: Text("$cn2"),
              subtitle: Text("$st2"),
              trailing: Text("Votes: $v2"),
            ),
          ],
        ),
      ),
    );
  }

  void getValues() async {
    var apiUrl = "http://localhost:7545"; //Replace with your API

    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);
// You can now call rpc methods. This one will query the amount of Ether you own
    int vc1 = await ethClient.getTransactionCount(
        EthereumAddress.fromHex(WalletDetails().candidate1));
    int vc2 = await ethClient.getTransactionCount(
        EthereumAddress.fromHex(WalletDetails().candidate2));
    int bn = await ethClient.getBlockNumber();

    setState(() {
      tv = bn;
      if (vc1 > vc2) {
        v1 = vc1;
        v2 = vc2;
        cn1 = WalletDetails().cn1;
        cn2 = WalletDetails().cn2;
        st1 = "WINNER";
      } else if (vc2 > vc1) {
        v1 = vc2;
        v2 = vc1;
        cn2 = WalletDetails().cn1;
        cn1 = WalletDetails().cn2;
        st1 = "WINNER";
      } else {
        v1 = vc1;
        v2 = vc2;
        cn1 = WalletDetails().cn1;
        cn2 = WalletDetails().cn2;
        st1 = "TIED";
        st2 = "TIED";
      }
    });
  }
}
