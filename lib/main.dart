import 'package:flutter/material.dart';
import 'models/user.dart';
import 'models/bank_account.dart';
import 'models/library_item.dart';

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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LibraryPage()),
                );
              },
              child: const Text('Library'),
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

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final Library library = Library();
  final User alice = User(name: 'Alice', age: 30);

  @override
  void initState() {
    super.initState();

    final book1 = Book(title: 'Harry Potter', author: 'JK Rowling', publishDate: DateTime(1995, 5, 1));
    final mag1 = Magazine(title: 'Super Magazine', issueNumber: '42');
    final book2 = Book(title: 'Book 2', author: 'John Smith', publishDate: DateTime(2023, 1, 15));
    final invalidItem = Book(title: '  ');
    
    library.addItem(book1);
    library.addItem(mag1);
    library.addItem(book2);
    library.addItem(invalidItem);

    library.borrowItem(book1, alice, DateTime.now().add(const Duration(days: 14)));
  }

  @override
  Widget build(BuildContext context) {
    final items = library.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final String status = item.borrower != null 
              ? 'Borrowed by ${item.borrower!.name}' 
              : 'Available';
              
          return ListTile(
            title: Text(item.title),
            subtitle: Text('Author: ${item.author ?? 'Unknown'}\nStatus: $status'),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (item.borrower != null) {
                    library.returnItem(item);
                  } else {
                    library.borrowItem(item, alice, DateTime.now().add(const Duration(days: 14)));
                  }
                });
              },
              child: Text(item.borrower != null ? 'Return' : 'Borrow'),
            ),
          );
        },
      ),
    );
  }
}
