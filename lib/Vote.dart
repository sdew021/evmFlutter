// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evmflutter/Dashboard.dart';
import 'package:evmflutter/Variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Vote extends StatefulWidget {
  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  String bal = "Loading";
  String dropdownValue = WalletDetails().cn1;
  @override
  void initState() {
    super.initState();
    getBalance();
  }

  Future<dynamic> getBalance() async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddressHex);
    // var result = await query("getBalance", [address]);
    var apiUrl = "http://localhost:7545"; //Replace with your API

    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);
// You can now call rpc methods. This one will query the amount of Ether you own
    EtherAmount balance = await ethClient
        .getBalance(EthereumAddress.fromHex(WalletDetails().candidate1));
    setState(() {
      bal = balance.getInEther.toString();
    });

    return balance.toString();
  }

  Future<String> sendTransaction(String from) async {
    var apiUrl = "http://localhost:7545"; //Replace with your API

    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);
    var credentials = await ethClient.credentialsFromPrivateKey(from);

    var result = await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(WalletDetails().toAddress),
        gasPrice: EtherAmount.inWei(BigInt.one),
        maxGas: 100000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
      ),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    bool _authStat = false;
    var _btntxt = "Authenticate";
    return Scaffold(
      appBar: AppBar(
        title: Text("Vote"),
      ),
      body: Center(
        child: Column(
          children: [
            // StreamBuilder<QuerySnapshot>(
            //   stream:
            //       FirebaseFirestore.instance.collection('votes').snapshots(),
            //   builder: (BuildContext context,
            //       AsyncSnapshot<QuerySnapshot> snapshot) {
            //     if (snapshot.hasError)
            //       return new Text('Error: ${snapshot.error}');
            //     switch (snapshot.connectionState) {
            //       case ConnectionState.waiting:
            //         return new Text('Loading...');
            //       default:
            //         return Container(
            //           height: 200,
            //           child: new ListView(
            //             children:
            //                 snapshot.data.docs.map((DocumentSnapshot document) {
            //               return new ListTile(
            //                 title: new Text(document['name']),
            //               );
            //             }).toList(),
            //           ),
            //         );
            //     }
            //   },
            // ),
            //Text("Balance " + bal),
            // ElevatedButton(
            //     onPressed: () {
            //       sendTransaction().then((value) => getBalance());
            //     },
            //     child: Text("Send Transaction"),
            //),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                child: DropdownButton<String>(
                  value: dropdownValue,
                  hint: Text("Candidate"),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                  ),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.blue),
                  underline: Container(
                    height: 2,
                    color: Colors.blue,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>[
                    WalletDetails().cn1,
                    WalletDetails().cn2,
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      _authStat = !_authStat;
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (_authStat)
                            return Colors.green;
                          else if (!_authStat) return Colors.red;
                          return null; // Use the component's default.
                        },
                      ),
                    ),
                    child: Text("$_btntxt")),
              ),
            ),
            Spacer(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 6,
                    height: 50,
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.blue,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Dashboard()),
                              (r) => false);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
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
                        if (dropdownValue == WalletDetails().cn1) {
                          sendTransaction(WalletDetails().pvtKey1).then(
                            (value) => {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Sucessfully Voted ${WalletDetails().cn1}"),
                                    ),
                                  )
                                  .closed
                                  .then((value) => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Dashboard()),
                                        )
                                      }),
                            },
                          );
                        } else {
                          sendTransaction(WalletDetails().pvtKey2).then(
                            (value) => {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Sucessfully Voted ${WalletDetails().cn2}"),
                                    ),
                                  )
                                  .closed
                                  .then((value) => {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Dashboard()),
                                            (r) => false)
                                      }),
                            },
                          );
                        }
                      },
                      child: Text("Cast Vote"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
