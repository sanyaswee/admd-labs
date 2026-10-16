import 'package:flutter/material.dart';
import 'models/user.dart';
import 'models/bank_account.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Lab'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersPage()),
                );
              },
              child: const Text('Users'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountsPage()),
                );
              },
              child: const Text('Bank Accounts'),
            ),
          ],
        ),
      ),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final List<User> users = [
    User(name: 'Alice', age: 30, email: 'alice@example.com'),
    User(name: 'Bob', email: 'bob@example.com'),
    User(name: 'Charlie'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text('Age: ${user.getDisplayAge()}\nEmail: ${user.email ?? 'Not provided'}'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final List<BankAccount> accounts = [];

  @override
  void initState() {
    super.initState();

    final acc1 = BankAccount(holderName: 'Alice', bankBranch: 'ABC');
    acc1.initializeAccount('ACC-12345');

    final acc2 = BankAccount(holderName: 'Bob');
    acc2.initializeAccount('ACC-67890');

    final acc3 = BankAccount(holderName: 'Charlie', bankBranch: 'DEF');

    final acc4 = BankAccount(holderName: 'Diana');
    
    accounts.addAll([acc1, acc2, acc3, acc4]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          
          final String accountDisplay = account.hasAccountNumber() 
              ? account.accountNumber 
              : 'Account Uninitialized';
              
          final String branchDisplay = account.bankBranch ?? 'N/A';
          
          return ListTile(
            title: Text(account.holderName),
            subtitle: Text('Account: $accountDisplay\nBranch: $branchDisplay'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
