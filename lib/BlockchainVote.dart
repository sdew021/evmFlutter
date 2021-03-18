import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainVote extends StatefulWidget {
  BlockchainVote({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = "Blockchain Vote";

  @override
  _BlockchainVoteState createState() => _BlockchainVoteState();
}

class _BlockchainVoteState extends State<BlockchainVote> {
  Client httpClient;
  Web3Client ethClient;

  String lastTransactionHash;

  @override
  void initState() {
    super.initState();
    httpClient = new Client();
    ethClient = new Web3Client("http://localhost:7545", httpClient);
  }

  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    String toContractAddress = "0xD57a7ef4498f373eB77080681851b62D5dEd5fEb";

    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "MetaCoin"),
        EthereumAddress.fromHex(toContractAddress));
    return contract;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey fromCredentials = EthPrivateKey.fromHex(
        "1bb1e8616fa398ded6ff34c9137da38243901f8b40c91029867900398c779a6b");

    DeployedContract contract = await loadContract();

    final ethFunction = contract.function(functionName);

    var result = await ethClient.sendTransaction(
      fromCredentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
    );
    return result;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return data;
  }

  Future<String> sendCoind(String targetAddressHex, int amount) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddressHex);
    // uint in smart contract means BigInt for us
    var bigAmount = BigInt.from(amount);
    // sendCoin transaction
    var response = await submit("sendCoin", [address, bigAmount]);
    // hash of the transaction
    return response;
  }

  Future<List<dynamic>> getBalance(String targetAddressHex) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddressHex);
    // var result = await query("getBalance", [address]);
    var apiUrl = "http://localhost:7545"; //Replace with your API

    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);
// You can now call rpc methods. This one will query the amount of Ether you own
    EtherAmount balance = await ethClient.getBalance(
        EthereumAddress.fromHex("0x12EE1464c548aF532a2b4709d8467E54a8903c69"));
    return [balance.getValueInUnit(EtherUnit.ether)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: getBalance("0xD57a7ef4498f373eB77080681851b62D5dEd5fEb"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('You have this many MetaCoin ${snapshot.data}');
                } else
                  return Text('Loading... ${snapshot.data}');
              },
            ),
            ElevatedButton(
              child: Text("Send some MetaCoins"),
              onPressed: () async {
                var result = await sendCoind(
                    "0xAC7667CF9e1a1352aaDE2cEB6824e31DeC259930", 2);
                setState(() {
                  lastTransactionHash = result;
                });
              },
            ),
            Text("Last transaction hash: $lastTransactionHash")
          ],
        ),
      ),
    );
  }
}
