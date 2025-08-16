import 'package:flutter/material.dart';
import 'package:payguard_ai_mvp/models/transaction.dart';

// Due to techninical issues, all code in this project has been pushed to the repo by Kayleigh Ncube

// Contributers are credited as follows:
// Kayleigh Ncube: KN
// KgotsoFatso Dignity: KD
// Thapelo Bapela: TP

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PayGuard AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'PayGuard AI MVP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _onlineMode = false;
  List<Transaction> _transactionList = [
    Transaction(merchant: "Online Purchase", amount: 200, fraudulent: false, synced: true),
    Transaction(merchant: "Offline Purchase", amount: 400, fraudulent: false, synced: false),
    Transaction(merchant: "Fraud Purchase", amount: 90000, fraudulent: true, synced: false),
  ];

  void _addNewTransaction(double amount, String merchant){
    // KN, TP: Refactoring, new functions
    bool possibleFraud = _fraudulentRuleSet(merchant, amount);

    setState(() {
      if (amount > 0.0){
        _transactionList.add(
          Transaction(merchant: merchant, amount: amount, fraudulent: possibleFraud),
        );
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to verify transaction."))
      );
      }
    });

    if (possibleFraud){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$merchant (R$amount) has been flagged as fraudulent."))
      );
    }
  }

  bool _fraudulentRuleSet(String merchant, double amount ){
    bool fraudConditions = 
      (merchant.toLowerCase() == "groceries" && amount > 2500) 
      || (merchant.toLowerCase() == "rent" && amount > 15000)
      || amount > 50000 || amount < 0.0;

    return fraudConditions;

  }

  void _handleOnlineSync(){
    if (_onlineMode){
      setState(() {
        for (var trns in _transactionList){
          trns.synced = true;
        }
      });
    }
  }

  void _displayTransaction(Transaction selectedTransaction){
    String info;

    info = selectedTransaction.fraudulent ? "Amount entered exceeds average amount for similar transactions" : (selectedTransaction.synced ? "Approved and stored online" : "Awaiting internet connection");

// (KD): New Function
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text("Transaction Information"),
          content: Text(info),
          actions: selectedTransaction.fraudulent ? [
            TextButton(
              onPressed: () => setState((){
                selectedTransaction.fraudulent = false;
                Navigator.pop(context);
              }),
              child: const Text("Approve"),
            ),
            TextButton(onPressed: (){ Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction has been reported"))
      );}, child: const Text("Report")),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))
            ] : [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    // TP: Refactoring
    final merchantEntryCtrl = TextEditingController();
    final amountEntryCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () => setState((){_onlineMode = !_onlineMode;}), icon: Icon(_onlineMode ? Icons.cloud_done : Icons.cloud_off))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  TextField(controller: merchantEntryCtrl, decoration: InputDecoration(labelText: "Reference")),
                  TextField(controller:  amountEntryCtrl, decoration: InputDecoration(labelText: "Amount"), keyboardType: TextInputType.numberWithOptions(decimal: false)),
                  ElevatedButton(
                    onPressed: (){
                      final newMerchant = merchantEntryCtrl.text;
                      final newAmount = (double.tryParse(amountEntryCtrl.text.trim()) ?? 0.0);
                      _addNewTransaction(newAmount, newMerchant);
                      if (newAmount > 0.0){
                        merchantEntryCtrl.clear();
                        amountEntryCtrl.clear();
                      }
                      _handleOnlineSync();
                    },
                    child: const Text("Confirm Transaction"))
                ],
              ),
            ),
            // KD: ListView and cleanup
            Text("Confirmed Transactions", style: TextStyle(fontSize: 24),),
            Expanded(child: ListView.builder(
              itemCount: _transactionList.length,
              
              itemBuilder: (context, index) {
                final trns = _transactionList.reversed.toList()[index];
                return ListTile(
                  title: Text("${trns.merchant}: R ${trns.amount}"),
                  subtitle: Text(trns.fraudulent ? "Flagged for potential fraud" : trns.synced ? "Approved" : "Queued"),
                  trailing: IconButton(icon: Icon(
                    // KN: Ternary condition for icon
                    trns.fraudulent ? Icons.warning : (trns.synced ? Icons.cloud_done : Icons.cloud_off),
                    color: trns.fraudulent ? Colors.amber : (trns.synced ? Colors.green : Colors.red),
                  ), onPressed: () => _displayTransaction(trns),)
                );
              }
              ))
          ],
        ),
      ),
    );
  }
}
