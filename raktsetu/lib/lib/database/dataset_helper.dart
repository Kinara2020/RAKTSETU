import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('raktsetu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // DONORS TABLE
    await db.execute('''
      CREATE TABLE donors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        blood_group TEXT NOT NULL,
        city TEXT NOT NULL,
        phone TEXT NOT NULL,
        age INTEGER NOT NULL,
        last_donated TEXT,
        is_available INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // HOSPITALS TABLE
    await db.execute('''
      CREATE TABLE hospitals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    // BLOOD INVENTORY TABLE
    await db.execute('''
      CREATE TABLE blood_inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        blood_group TEXT NOT NULL,
        units INTEGER NOT NULL,
        city TEXT NOT NULL,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // REQUESTS TABLE
    await db.execute('''
      CREATE TABLE requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hospital_id INTEGER NOT NULL,
        blood_group TEXT NOT NULL,
        units_needed INTEGER NOT NULL,
        city TEXT NOT NULL,
        status TEXT DEFAULT 'Pending',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (hospital_id) REFERENCES hospitals (id)
      )
    ''');

    // SEED DATA
    await _seedData(db);
  }

  Future _seedData(Database db) async {
    // INSERT HOSPITALS
    final hospitals = [
      {'name': 'Civil Hospital', 'city': 'Ahmedabad', 'phone': '9876543210', 'address': 'Asarwa, Ahmedabad'},
      {'name': 'Sterling Hospital', 'city': 'Ahmedabad', 'phone': '9876543211', 'address': 'Gurukul, Ahmedabad'},
      {'name': 'Apollo Hospital', 'city': 'Ahmedabad', 'phone': '9876543212', 'address': 'Bhat, Ahmedabad'},
      {'name': 'GMERS Hospital', 'city': 'Gandhinagar', 'phone': '9876543213', 'address': 'Sector 12, Gandhinagar'},
      {'name': 'Shardaben Hospital', 'city': 'Ahmedabad', 'phone': '9876543214', 'address': 'Ellisbridge, Ahmedabad'},
      {'name': 'Vadilal Hospital', 'city': 'Surat', 'phone': '9876543215', 'address': 'Adajan, Surat'},
      {'name': 'New Civil Hospital', 'city': 'Surat', 'phone': '9876543216', 'address': 'Majura Gate, Surat'},
      {'name': 'PDU Hospital', 'city': 'Rajkot', 'phone': '9876543217', 'address': 'Rajkot'},
      {'name': 'SSG Hospital', 'city': 'Vadodara', 'phone': '9876543218', 'address': 'Vadodara'},
      {'name': 'Dhiraj Hospital', 'city': 'Vadodara', 'phone': '9876543219', 'address': 'Piparia, Vadodara'},
    ];
    for (var h in hospitals) {
      await db.insert('hospitals', h);
    }

    // INSERT DONORS
    final donors = [
      {'name': 'Aarav Shah', 'blood_group': 'A+', 'city': 'Ahmedabad', 'phone': '9000000001', 'age': 24, 'last_donated': '2024-01-15', 'is_available': 1},
      {'name': 'Priya Patel', 'blood_group': 'B+', 'city': 'Ahmedabad', 'phone': '9000000002', 'age': 28, 'last_donated': '2024-02-10', 'is_available': 1},
      {'name': 'Rohan Mehta', 'blood_group': 'O+', 'city': 'Surat', 'phone': '9000000003', 'age': 32, 'last_donated': '2024-03-05', 'is_available': 1},
      {'name': 'Nisha Joshi', 'blood_group': 'AB+', 'city': 'Vadodara', 'phone': '9000000004', 'age': 26, 'last_donated': '2024-01-20', 'is_available': 1},
      {'name': 'Karan Desai', 'blood_group': 'A-', 'city': 'Gandhinagar', 'phone': '9000000005', 'age': 30, 'last_donated': '2023-12-01', 'is_available': 1},
      {'name': 'Meera Trivedi', 'blood_group': 'B-', 'city': 'Ahmedabad', 'phone': '9000000006', 'age': 22, 'last_donated': null, 'is_available': 1},
      {'name': 'Yash Kapoor', 'blood_group': 'O-', 'city': 'Surat', 'phone': '9000000007', 'age': 27, 'last_donated': '2024-02-28', 'is_available': 1},
      {'name': 'Ananya Singh', 'blood_group': 'AB-', 'city': 'Rajkot', 'phone': '9000000008', 'age': 25, 'last_donated': '2024-01-10', 'is_available': 0},
      {'name': 'Dev Rathod', 'blood_group': 'A+', 'city': 'Ahmedabad', 'phone': '9000000009', 'age': 35, 'last_donated': '2023-11-15', 'is_available': 1},
      {'name': 'Pooja Sharma', 'blood_group': 'B+', 'city': 'Vadodara', 'phone': '9000000010', 'age': 29, 'last_donated': '2024-03-01', 'is_available': 1},
      {'name': 'Arjun Nair', 'blood_group': 'O+', 'city': 'Ahmedabad', 'phone': '9000000011', 'age': 23, 'last_donated': '2024-02-15', 'is_available': 1},
      {'name': 'Shreya Agarwal', 'blood_group': 'A+', 'city': 'Gandhinagar', 'phone': '9000000012', 'age': 31, 'last_donated': '2024-01-05', 'is_available': 1},
      {'name': 'Vivek Pandya', 'blood_group': 'AB+', 'city': 'Surat', 'phone': '9000000013', 'age': 28, 'last_donated': null, 'is_available': 1},
      {'name': 'Riya Modi', 'blood_group': 'B+', 'city': 'Ahmedabad', 'phone': '9000000014', 'age': 24, 'last_donated': '2024-03-10', 'is_available': 1},
      {'name': 'Harsh Bhatt', 'blood_group': 'O-', 'city': 'Rajkot', 'phone': '9000000015', 'age': 33, 'last_donated': '2023-10-20', 'is_available': 1},
      {'name': 'Tanvi Dave', 'blood_group': 'A-', 'city': 'Vadodara', 'phone': '9000000016', 'age': 26, 'last_donated': '2024-02-01', 'is_available': 1},
      {'name': 'Nikhil Solanki', 'blood_group': 'B-', 'city': 'Ahmedabad', 'phone': '9000000017', 'age': 29, 'last_donated': '2024-01-25', 'is_available': 0},
      {'name': 'Kavya Rao', 'blood_group': 'AB-', 'city': 'Surat', 'phone': '9000000018', 'age': 27, 'last_donated': '2023-12-15', 'is_available': 1},
      {'name': 'Siddharth Jain', 'blood_group': 'O+', 'city': 'Gandhinagar', 'phone': '9000000019', 'age': 34, 'last_donated': '2024-03-08', 'is_available': 1},
      {'name': 'Diya Chauhan', 'blood_group': 'A+', 'city': 'Ahmedabad', 'phone': '9000000020', 'age': 22, 'last_donated': null, 'is_available': 1},
      {'name': 'Raj Malhotra', 'blood_group': 'B+', 'city': 'Surat', 'phone': '9000000021', 'age': 30, 'last_donated': '2024-02-20', 'is_available': 1},
      {'name': 'Ishaan Verma', 'blood_group': 'O+', 'city': 'Vadodara', 'phone': '9000000022', 'age': 25, 'last_donated': '2024-01-30', 'is_available': 1},
      {'name': 'Aisha Khan', 'blood_group': 'AB+', 'city': 'Ahmedabad', 'phone': '9000000023', 'age': 28, 'last_donated': '2023-11-20', 'is_available': 1},
      {'name': 'Parth Thakkar', 'blood_group': 'A+', 'city': 'Rajkot', 'phone': '9000000024', 'age': 32, 'last_donated': '2024-03-15', 'is_available': 1},
      {'name': 'Neha Dubey', 'blood_group': 'B-', 'city': 'Gandhinagar', 'phone': '9000000025', 'age': 27, 'last_donated': '2024-02-05', 'is_available': 1},
      {'name': 'Amit Tiwari', 'blood_group': 'O-', 'city': 'Ahmedabad', 'phone': '9000000026', 'age': 36, 'last_donated': '2023-09-10', 'is_available': 1},
      {'name': 'Sneha Pillai', 'blood_group': 'A-', 'city': 'Surat', 'phone': '9000000027', 'age': 24, 'last_donated': '2024-01-12', 'is_available': 1},
      {'name': 'Kunal Mishra', 'blood_group': 'AB+', 'city': 'Vadodara', 'phone': '9000000028', 'age': 29, 'last_donated': '2024-03-02', 'is_available': 1},
      {'name': 'Aditi Gupta', 'blood_group': 'B+', 'city': 'Ahmedabad', 'phone': '9000000029', 'age': 23, 'last_donated': null, 'is_available': 1},
      {'name': 'Mohit Saxena', 'blood_group': 'O+', 'city': 'Gandhinagar', 'phone': '9000000030', 'age': 31, 'last_donated': '2024-02-25', 'is_available': 1},
      {'name': 'Priyanka Reddy', 'blood_group': 'A+', 'city': 'Ahmedabad', 'phone': '9000000031', 'age': 26, 'last_donated': '2024-01-18', 'is_available': 1},
      {'name': 'Rahul Patil', 'blood_group': 'AB-', 'city': 'Surat', 'phone': '9000000032', 'age': 33, 'last_donated': '2023-12-20', 'is_available': 0},
      {'name': 'Simran Kaur', 'blood_group': 'B+', 'city': 'Rajkot', 'phone': '9000000033', 'age': 25, 'last_donated': '2024-03-12', 'is_available': 1},
      {'name': 'Akash Yadav', 'blood_group': 'O+', 'city': 'Vadodara', 'phone': '9000000034', 'age': 28, 'last_donated': '2024-02-08', 'is_available': 1},
      {'name': 'Bhavna Trivedi', 'blood_group': 'A+', 'city': 'Ahmedabad', 'phone': '9000000035', 'age': 30, 'last_donated': '2024-01-22', 'is_available': 1},
      {'name': 'Chirag Patel', 'blood_group': 'B+', 'city': 'Gandhinagar', 'phone': '9000000036', 'age': 27, 'last_donated': null, 'is_available': 1},
      {'name': 'Deepika Nair', 'blood_group': 'O-', 'city': 'Surat', 'phone': '9000000037', 'age': 29, 'last_donated': '2024-03-06', 'is_available': 1},
      {'name': 'Eshan Mehta', 'blood_group': 'AB+', 'city': 'Ahmedabad', 'phone': '9000000038', 'age': 24, 'last_donated': '2024-02-12', 'is_available': 1},
      {'name': 'Falak Sheikh', 'blood_group': 'A-', 'city': 'Vadodara', 'phone': '9000000039', 'age': 32, 'last_donated': '2023-11-25', 'is_available': 1},
      {'name': 'Gaurav Sharma', 'blood_group': 'B-', 'city': 'Rajkot', 'phone': '9000000040', 'age': 35, 'last_donated': '2024-01-08', 'is_available': 1},
      {'name': 'Hinal Shah', 'blood_group': 'O+', 'city': 'Ahmedabad', 'phone': '9000000041', 'age': 23, 'last_donated': '2024-03-18', 'is_available': 1},
      {'name': 'Ishan Joshi', 'blood_group': 'A+', 'city': 'Gandhinagar', 'phone': '9000000042', 'age': 26, 'last_donated': '2024-02-22', 'is_available': 1},
      {'name': 'Jhanvi Kapoor', 'blood_group': 'AB+', 'city': 'Surat', 'phone': '9000000043', 'age': 28, 'last_donated': null, 'is_available': 1},
      {'name': 'Kush Desai', 'blood_group': 'B+', 'city': 'Vadodara', 'phone': '9000000044', 'age': 31, 'last_donated': '2024-01-28', 'is_available': 1},
      {'name': 'Lavanya Rao', 'blood_group': 'O+', 'city': 'Ahmedabad', 'phone': '9000000045', 'age': 25, 'last_donated': '2024-03-20', 'is_available': 1},
      {'name': 'Manav Rathod', 'blood_group': 'A+', 'city': 'Rajkot', 'phone': '9000000046', 'age': 29, 'last_donated': '2024-02-18', 'is_available': 1},
      {'name': 'Nandini Bhatt', 'blood_group': 'B-', 'city': 'Ahmedabad', 'phone': '9000000047', 'age': 27, 'last_donated': '2024-01-14', 'is_available': 0},
      {'name': 'Om Solanki', 'blood_group': 'AB-', 'city': 'Gandhinagar', 'phone': '9000000048', 'age': 33, 'last_donated': '2023-12-08', 'is_available': 1},
      {'name': 'Palak Jain', 'blood_group': 'O-', 'city': 'Surat', 'phone': '9000000049', 'age': 24, 'last_donated': '2024-03-25', 'is_available': 1},
      {'name': 'Qasim Ali', 'blood_group': 'A+', 'city': 'Vadodara', 'phone': '9000000050', 'age': 30, 'last_donated': '2024-02-28', 'is_available': 1},
    ];
    for (var d in donors) {
      await db.insert('donors', d);
    }

    // INSERT BLOOD INVENTORY
    final inventory = [
      {'blood_group': 'A+', 'units': 15, 'city': 'Ahmedabad'},
      {'blood_group': 'A-', 'units': 5, 'city': 'Ahmedabad'},
      {'blood_group': 'B+', 'units': 12, 'city': 'Ahmedabad'},
      {'blood_group': 'B-', 'units': 3, 'city': 'Ahmedabad'},
      {'blood_group': 'O+', 'units': 18, 'city': 'Ahmedabad'},
      {'blood_group': 'O-', 'units': 4, 'city': 'Ahmedabad'},
      {'blood_group': 'AB+', 'units': 8, 'city': 'Ahmedabad'},
      {'blood_group': 'AB-', 'units': 2, 'city': 'Ahmedabad'},
      {'blood_group': 'A+', 'units': 10, 'city': 'Surat'},
      {'blood_group': 'B+', 'units': 9, 'city': 'Surat'},
      {'blood_group': 'O+', 'units': 14, 'city': 'Surat'},
      {'blood_group': 'AB+', 'units': 6, 'city': 'Surat'},
      {'blood_group': 'A+', 'units': 7, 'city': 'Vadodara'},
      {'blood_group': 'B+', 'units': 8, 'city': 'Vadodara'},
      {'blood_group': 'O+', 'units': 11, 'city': 'Vadodara'},
      {'blood_group': 'A+', 'units': 5, 'city': 'Gandhinagar'},
      {'blood_group': 'O+', 'units': 6, 'city': 'Gandhinagar'},
      {'blood_group': 'A+', 'units': 4, 'city': 'Rajkot'},
      {'blood_group': 'B+', 'units': 5, 'city': 'Rajkot'},
      {'blood_group': 'O+', 'units': 7, 'city': 'Rajkot'},
    ];
    for (var i in inventory) {
      await db.insert('blood_inventory', i);
    }

    // INSERT REQUESTS
    final requests = [
      {'hospital_id': 1, 'blood_group': 'O-', 'units_needed': 2, 'city': 'Ahmedabad', 'status': 'Urgent'},
      {'hospital_id': 2, 'blood_group': 'AB-', 'units_needed': 1, 'city': 'Ahmedabad', 'status': 'Pending'},
      {'hospital_id': 3, 'blood_group': 'B-', 'units_needed': 3, 'city': 'Ahmedabad', 'status': 'Fulfilled'},
      {'hospital_id': 4, 'blood_group': 'A-', 'units_needed': 2, 'city': 'Gandhinagar', 'status': 'Pending'},
      {'hospital_id': 6, 'blood_group': 'O-', 'units_needed': 1, 'city': 'Surat', 'status': 'Urgent'},
      {'hospital_id': 8, 'blood_group': 'AB+', 'units_needed': 4, 'city': 'Rajkot', 'status': 'Pending'},
      {'hospital_id': 9, 'blood_group': 'B+', 'units_needed': 2, 'city': 'Vadodara', 'status': 'Fulfilled'},
      {'hospital_id': 5, 'blood_group': 'A+', 'units_needed': 5, 'city': 'Ahmedabad', 'status': 'Pending'},
    ];
    for (var r in requests) {
      await db.insert('requests', r);
    }
  }

  // ========== DONOR QUERIES ==========
  Future<List<Map<String, dynamic>>> getAllDonors() async {
    final db = await database;
    return await db.query('donors', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getDonorsByBloodGroup(String bloodGroup, String city) async {
    final db = await database;
    return await db.query('donors',
        where: 'blood_group = ? AND city = ? AND is_available = 1',
        whereArgs: [bloodGroup, city]);
  }

  Future<int> insertDonor(Map<String, dynamic> donor) async {
    final db = await database;
    return await db.insert('donors', donor);
  }

  Future<int> updateDonorAvailability(int id, int isAvailable) async {
    final db = await database;
    return await db.update('donors', {'is_available': isAvailable},
        where: 'id = ?', whereArgs: [id]);
  }

  // ========== INVENTORY QUERIES ==========
  Future<List<Map<String, dynamic>>> getInventoryByCity(String city) async {
    final db = await database;
    return await db.query('blood_inventory',
        where: 'city = ?', whereArgs: [city], orderBy: 'blood_group');
  }

  Future<List<Map<String, dynamic>>> getAllInventory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT city, blood_group, SUM(units) as total_units
      FROM blood_inventory
      GROUP BY city, blood_group
      ORDER BY city, blood_group
    ''');
  }

  // ========== REQUEST QUERIES ==========
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT r.*, h.name as hospital_name
      FROM requests r
      JOIN hospitals h ON r.hospital_id = h.id
      ORDER BY r.created_at DESC
    ''');
  }

  Future<int> insertRequest(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('requests', request);
  }

  Future<int> updateRequestStatus(int id, String status) async {
    final db = await database;
    return await db.update('requests', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  // ========== DASHBOARD STATS ==========
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;
    final totalDonors = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM donors'));
    final availableDonors = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM donors WHERE is_available = 1'));
    final totalUnits = Sqflite.firstIntValue(
        await db.rawQuery('SELECT SUM(units) FROM blood_inventory'));
    final pendingRequests = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM requests WHERE status = 'Pending' OR status = 'Urgent'"));
    final urgentRequests = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM requests WHERE status = 'Urgent'"));

    return {
      'totalDonors': totalDonors ?? 0,
      'availableDonors': availableDonors ?? 0,
      'totalUnits': totalUnits ?? 0,
      'pendingRequests': pendingRequests ?? 0,
      'urgentRequests': urgentRequests ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getHospitals() async {
    final db = await database;
    return await db.query('hospitals', orderBy: 'name');
  }
}