// KN: New class - Transaction
class Transaction {
  final double amount;
  final String merchant;
  bool fraudulent;
  bool synced;

  Transaction({
    required this.merchant,
    required this.amount,
    this.fraudulent = false,
    this.synced = false,
  });
}