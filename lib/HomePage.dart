import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading=true;
    });

    try {
      final response = await _supabase.from('expenses').select().order('date', ascending: false);
        setState(() {
          _expenses = response as List<Map<String, dynamic>>;
        });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading expenses record.")));
    } finally {
      setState(() {
        _isLoading=false;
      });
    }
  }

  Future<void> _addOrUpdateExpense(Map<String, dynamic>? expense) async {
    final isNew = expense == null;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ExpenseFormDialog(expense: expense),
    );
    if (result != null) {
      if (isNew) {
        await _supabase.from('expenses').insert(result);
      } else {
        await _supabase.from('expenses').update(result).eq('id', expense!['id']);
      }
      _fetchExpenses();
    }
  }

  Future<void> _deleteExpense(int id) async {
    await _supabase.from('expenses').delete().eq('id', id);
    _fetchExpenses();
  }

  Future<bool?> _confirmDelete(BuildContext context, int id) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

Future<void> _confirmDelete1(BuildContext context, int id) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Confirm
            child: Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    _deleteExpense(id);
  }
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchExpenses();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Add button clicked')),
              // );
              _addOrUpdateExpense(null);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle the selected value
              if (value == 'Option 1') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Option 1 selected')),
                );
              } else if (value == 'Option 2') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Option 2 selected')),
                );
              } else if (value == 'Logout') {
                Navigator.pop(context); // Example: Logout action
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Option 1',
                  child: Text('Option 1'),
                ),
                PopupMenuItem(
                  value: 'Option 2',
                  child: Text('Option 2'),
                ),
                PopupMenuDivider(), // Optional: Adds a divider
                PopupMenuItem(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),

        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),)
          : _expenses.isEmpty
          ? Center(child: Text('No expenses found'))
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                // return Dismissible(
                //     key: Key(expense['id'].toString()),
                //     direction: DismissDirection.endToStart,
                //     background: Container(
                //       color: Colors.red,
                //       alignment: Alignment.centerRight,
                //       padding: EdgeInsets.symmetric(horizontal: 20.0),
                //       child: Icon(Icons.delete, color: Colors.white),
                //     ),
                //     confirmDismiss: (direction) => _confirmDelete(context, expense['id']),
                //     onDismissed: (direction) {
                //       _deleteExpense(expense['id']); 
                //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record deleted.")));
                //     },
                //     child: Card(
                //       child: ListTile(
                //         title: Text(expense['expense_name']),
                //         subtitle: Text('Date: ${expense['date']} - Type: ${expense['type']}'),
                //         trailing: Text(
                //           'Php ${expense['amount'].toStringAsFixed(2)}',
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color: Colors.green,
                //           ),
                //         ),
                //         onTap: () => _addOrUpdateExpense(expense),
                //       ),
                //     ),
                //   );
                
                return Card(
                  child: ListTile(
                    title: Text(expense['expense_name']),
                    subtitle: Text(
                        'Date: ${expense['date']} - Type: ${expense['type']}'),
                    trailing: Text(
                      'Php${expense['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    onTap: () => _addOrUpdateExpense(expense),
                    onLongPress: () => _confirmDelete1(context, expense['id']),
                  ),
                );
              },
            ),
    );
  }
}

class ExpenseFormDialog extends StatefulWidget {
  final Map<String, dynamic>? expense;

  ExpenseFormDialog({this.expense});

  @override
  _ExpenseFormDialogState createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _expenseNameController;
  late TextEditingController _amountController;
  late String _type;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
        text: widget.expense?['date'] ?? DateTime.now().toIso8601String());
    _expenseNameController =
        TextEditingController(text: widget.expense?['expense_name'] ?? '');
    _amountController =
        TextEditingController(text: widget.expense?['amount']?.toString() ?? '');
    _type = widget.expense?['type'] ?? 'Meal';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                // controller: _dateController,
                // decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                // validator: (value) =>
                //     value == null || value.isEmpty ? 'Enter a date' : null,

                controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today), // Icon to indicate calendar functionality
              ),
              readOnly: true, // Prevent manual input
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000), // Earliest allowed date
                  lastDate: DateTime(2100), // Latest allowed date
                );

                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
                        pickedDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
                  });
                }
              },
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a date' : null,
              ),
              TextFormField(
                controller: _expenseNameController,
                decoration: InputDecoration(labelText: 'Expense Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an expense name' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter an amount'
                    : double.tryParse(value) == null
                        ? 'Enter a valid number'
                        : null,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Meal', 'Snacks', 'Other']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'date': _dateController.text,
                'expense_name': _expenseNameController.text,
                'amount': double.parse(_amountController.text),
                'type': _type,
              });
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}