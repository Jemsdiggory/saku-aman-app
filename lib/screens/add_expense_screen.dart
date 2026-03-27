import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'Makan';
  bool _isSaving = false;

  // Daftar kategori 
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Makan',      'icon': Icons.restaurant},
    {'name': 'Transport',  'icon': Icons.directions_car},
    {'name': 'Belanja',    'icon': Icons.shopping_bag},
    {'name': 'Hiburan',    'icon': Icons.movie},
    {'name' : 'Game', 'icon': Icons.videogame_asset},
    {'name' : 'Tagihan', 'icon': Icons.receipt},
    {'name': 'Lainnya',    'icon': Icons.more_horiz}, 
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    // Validasi input
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak boleh kosong!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      amount: int.parse(_amountController.text.replaceAll('.', '')),
      category: _selectedCategory,
      note: _noteController.text,
      date: DateTime.now().toIso8601String().substring(0, 19),
    );

    await DbHelper.instance.insertExpense(expense);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true); // true = ada data baru
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFF2D3748);
    final bgColor     = isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardColor   = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final labelColor  = isDark ? Colors.white : const Color(0xFF2D3748);
    final subColor    = isDark ? Colors.white60 : const Color(0xFF718096);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          'Tambah Pengeluaran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // INPUT NOMINAL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 18, color: subColor),
                      const SizedBox(width: 6),
                      Text('Nominal', style: TextStyle(
                        color: subColor, fontSize: 13,
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: subColor),
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PILIH KATEGORI
            Text('Kategori', style: TextStyle(
              color: labelColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2D3748)
                          : cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2D3748)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat['icon'],
                          color: isSelected ? Colors.white : subColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : subColor,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // INPUT CATATAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note_outlined, size: 18, color: subColor),
                      const SizedBox(width: 6),
                      Text('Catatan (opsional)',
                          style: TextStyle(color: subColor, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    style: TextStyle(color: labelColor),
                    decoration: InputDecoration(
                      hintText: 'Contoh: makan siang di warung...',
                      hintStyle: TextStyle(color: subColor),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveExpense,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Pengeluaran',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3748),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}