import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'medication_log.dart'; // Import your data model
// ... other imports

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MedicationTracker(),
    );
  }
}

class MedicationTracker extends StatefulWidget {
  @override
  _MedicationTrackerState createState() => _MedicationTrackerState();
}

class _MedicationTrackerState extends State<MedicationTracker> {
  MedicationLog? _latestLog;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadLatestLog();
  }

  Future<void> _loadLatestLog() async {
    // Get the database
    final database = await dbHelper.initializeDB();
    // Query the latest log entry
    List<Map<String, dynamic>> maps =
        await database.query('logs', orderBy: 'timestamp DESC', limit: 1);
    if (maps.isNotEmpty) {
      setState(() {
        _latestLog = MedicationLog.fromMap(maps.first);
      });
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString(); // Unique filename
      final savedImage =
          await File(image.path).copy('${appDir.path}/$fileName.png');

      // Save the medication log to the database
      final database = await dbHelper.initializeDB();
      await database.insert(
        'logs',
        MedicationLog(
                timestamp: DateTime.now(),
                mealType: "Breakfast",
                imagePath: savedImage.path)
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _loadLatestLog(); // Reload latest log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medication Tracker')),
      body: Center(
          child: _latestLog != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(File(_latestLog!.imagePath)),
                    Text(_latestLog!.formattedTime),
                    Text(_latestLog!.mealType)
                  ],
                )
              : Text('No medication logged yet.')),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        tooltip: 'Take Picture',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
