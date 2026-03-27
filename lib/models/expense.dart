class Expense {
  final int? id;
  final int amount;
  final String category;
  final String note;
  final String date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  // Konversi object → Map (untuk disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
    };
  }

  // Konversi Map → object (untuk dibaca dari SQLite)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      note: map['note'],
      date: map['date'],
    );
  }
}