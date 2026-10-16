class BankAccount {
  late String accountNumber;
  String holderName;
  double balance = 0.0;
  String? bankBranch;

  BankAccount({required this.holderName, this.bankBranch});

  void initializeAccount(String number) {
    accountNumber = number;
  }
}