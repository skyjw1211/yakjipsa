import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MedicationLog {
  final int? id; // Add an ID for database management
  final DateTime timestamp;
  final String mealType;
  final String imagePath;

  MedicationLog(
      {this.id,
      required this.timestamp,
      required this.mealType,
      required this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'mealType': mealType,
      'imagePath': imagePath,
    };
  }

  factory MedicationLog.fromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp']),
      mealType: map['mealType'] as String,
      imagePath: map['imagePath'] as String,
    );
  }
  String get formattedTime => DateFormat('yyyy-MM-dd HH:mm')
      .format(timestamp); // Helper to format the timestamp
}

class DatabaseHelper {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'medication_database.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT NOT NULL, mealType TEXT NOT NULL, imagePath TEXT NOT NULL)",
        );
      },
      version: 1,
    );
  }
}
