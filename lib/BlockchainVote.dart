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
    ethClient = new Web3Client('http://localhost:7545', httpClient);
  }

  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x34C848C30572c1f29d06B6eb129447C0C1E0e6D1";

    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "MetaCoin"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "79d6e3ebd353cd270d39d22573654510d076c50fd08f4a024444bc9e0ae081e2");

    DeployedContract contract = await loadContract();

    final ethFunction = contract.function(functionName);

    var result = await ethClient.sendTransaction(
      credentials,
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
    EthereumAddress address = EthereumAddress.fromHex(targetAddressHex);
    // getBalance transaction
    List<dynamic> result = await query("getBalance", [address]);
    // returns list of results, in this case a list with only the balance
    return result;
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
              future: getBalance("0x1dce710dd47849Aa99503f2dD40755256fB9C91e"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      'You have this many MetaCoin ${snapshot.data[0]}');
                } else
                  return Text('Loading...');
              },
            ),
            SizedBox(
              height: 16,
            ),
            Text('Phone Number: 8310945403'),
            SizedBox(
              height: 16,
            ),
            Text('Unique Id: 1234567891'),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              child: Text("Send some MetaCoins"),
              onPressed: () async {
                var result = await sendCoind(
                    "0x34C848C30572c1f29d06B6eb129447C0C1E0e6D1", 2);
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
