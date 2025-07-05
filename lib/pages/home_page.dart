// lib/home_page.dart
import 'package:autonest/pages/add_car_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _carData; // Untuk menyimpan data mobil yang ditampilkan
  List<Map<String, dynamic>>?
  _allUserCars; // List semua mobil user untuk Drawer
  bool _isLoading = true; // Indikator loading
  String _currentStatus = "LOADING"; // Status servis

  final TextEditingController _currentMileageInputController =
      TextEditingController();

  final Map<String, String> _carImagePaths = {
    'Sport': 'assets/images/car.png',
    'Sedan': 'assets/images/sedan.png',
    'Hatchback': 'assets/images/hatchback66.png',
    'SUV': 'assets/images/suv.png',
    'Truck': 'assets/images/truck.png',
  };

  @override
  void initState() {
    super.initState();
    _fetchCarData(); // Ambil data mobil utama (pertama) saat inisialisasi
    _fetchAllUserCars(); // Ambil semua data mobil untuk menu samping
  }

  @override
  void dispose() {
    _currentMileageInputController.dispose();
    super.dispose();
  }

  // Mengambil data mobil utama yang akan ditampilkan di Home Page
  // Kini dapat mengambil mobil spesifik berdasarkan ID (yang bertipe String UUID)
  Future<void> _fetchCarData({String? carIdToFetch}) async {
    // Ubah tipe dari int? menjadi String?
    setState(() {
      _isLoading = true;
    });

    try {
      final String? userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Pengguna belum login.')),
          );
        }
        setState(() {
          _carData = null; // Pastikan _carData null jika tidak ada pengguna
          _currentStatus = "NO_CAR";
          _isLoading = false;
        });
        return;
      }

      dynamic query = _supabase
          .from('Mobil')
          .select()
          .eq('user_profil_id', userId);

      if (carIdToFetch != null) {
        // Jika ID mobil spesifik disediakan, ambil mobil tersebut
        query = query.eq('id', carIdToFetch); // Sesuaikan dengan tipe String
      } else {
        // Jika tidak ada ID spesifik, ambil mobil pertama berdasarkan tanggal dibuat
        query = query.order('created_at', ascending: true).limit(1);
      }

      final response = await query.maybeSingle();

      if (response == null) {
        _carData = null;
        _currentStatus = "NO_CAR";
      } else {
        _carData = response;
        _calculateServiceStatus();
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil data mobil: ${error.message}'),
          ),
        );
      }
      _carData =
          null; // Pastikan _carData null jika ada PostgrestException lain
      _currentStatus = "ERROR"; // Atau status lain untuk menunjukkan error
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan tak terduga: $error')),
        );
      }
      _carData = null; // Pastikan _carData null jika ada error tak terduga
      _currentStatus = "ERROR";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mengambil semua data mobil yang terhubung dengan user yang sedang login
  Future<void> _fetchAllUserCars() async {
    try {
      final String? userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _allUserCars = [];
        });
        return;
      }
      final List<Map<String, dynamic>> response = await _supabase
          .from('Mobil')
          .select()
          .eq('user_profil_id', userId);
      setState(() {
        _allUserCars = response;
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching all cars: ${error.message}')),
        );
      }
      setState(() {
        _allUserCars = []; // Set empty list on error
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan tak terduga: $error')),
        );
      }
      setState(() {
        _allUserCars = []; // Set empty list on error
      });
    }
  }

  // Metode untuk menandai servis selesai, akan dipanggil dari pop-up
  Future<void> _markServiceDoneFromPopup() async {
    if (_carData == null) return;

    // Pastikan currentMileageInputController memiliki nilai valid
    final String currentMileageText = _currentMileageInputController.text;
    if (currentMileageText.isEmpty ||
        double.tryParse(currentMileageText) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid current mileage.'),
          ),
        );
      }
      return;
    }

    final double currentMileage = double.parse(currentMileageText);
    // Setel interval servis berikutnya menjadi 10.000 km dari mileage saat ini
    final double newNextServiceInterval = currentMileage + 10000.0;

    // Tutup pop-up sebelum menampilkan loading di background
    if (mounted) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase
          .from('Mobil')
          .update({
            'current_mileage': currentMileage, // Update current mileage juga
            'last_service_mileage': currentMileage,
            'next_service_interval': newNextServiceInterval,
          })
          .eq('id', _carData!['id']);

      // Panggil _fetchCarData dengan ID mobil yang sedang aktif
      await _fetchCarData(
        carIdToFetch: _carData!['id'] as String,
      ); // Ubah dari int menjadi String
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service and mileage updated successfully!'),
          ),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating service: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected Error: $error')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metode untuk mengupdate hanya current mileage dari pop-up
  Future<void> _updateCurrentMileageFromPopup() async {
    if (_carData == null) return;

    final String currentMileageText = _currentMileageInputController.text;
    if (currentMileageText.isEmpty ||
        double.tryParse(currentMileageText) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid current mileage.'),
          ),
        );
      }
      return;
    }

    final double newCurrentMileage = double.parse(currentMileageText);

    // Tutup pop-up sebelum menampilkan loading di background
    if (mounted) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase
          .from('Mobil')
          .update({'current_mileage': newCurrentMileage})
          .eq('id', _carData!['id']);

      // Panggil _fetchCarData dengan ID mobil yang sedang aktif
      await _fetchCarData(
        carIdToFetch: _carData!['id'] as String,
      ); // Ubah dari int menjadi String
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current mileage updated successfully!'),
          ),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating mileage: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected Error: $error')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateServiceStatus() {
    if (_carData == null) {
      _currentStatus = "NO_CAR";
      return;
    }

    // Pastikan nilai adalah double, gunakan null-aware operator dan default jika null
    final double currentMileage =
        (_carData!['current_mileage'] as num?)?.toDouble() ?? 0.0;
    final double nextServiceInterval =
        (_carData!['next_service_interval'] as num?)?.toDouble() ?? 0.0;

    if (currentMileage >= nextServiceInterval) {
      _currentStatus = "SERVICE_OVERDUE";
    } else if (nextServiceInterval - currentMileage <= 2000) {
      _currentStatus = "SERVICE_SOON";
    } else {
      _currentStatus = "ALL_GOOD";
    }
  }

  // Mengembalikan path gambar mobil berdasarkan jenis
  String _getCarImagePath(String carType) {
    // Default gambar jika carType tidak ditemukan di _carImagePaths
    return _carImagePaths[carType] ?? 'assets/images/Car Image.png';
  }

  // Mengembalikan teks status utama
  String _getStatusMainText() {
    switch (_currentStatus) {
      case "SERVICE_OVERDUE":
        return 'SERVICE\nOVERDUE';
      case "SERVICE_SOON":
        return 'SERVICE\nSOON';
      case "ALL_GOOD":
        return 'ALL\nGOOD';
      case "NO_CAR":
        return 'NO CAR\nADDED';
      case "ERROR": // Tambahkan case untuk error
        return 'ERROR\nLOADING';
      default:
        return 'LOADING';
    }
  }

  // warna untuk teks status
  Color _getStatusMainTextColor() {
    return Colors.white;
  }

  // widget status di bagian bawah
  Widget _buildStatusCard() {
    if (_carData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Please add a car to view its status',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Navigasi ke AddCarPage untuk menambahkan mobil baru
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const AddCarPage(), // Tidak ada carData untuk menambahkan
                  ),
                );
                // Jika mobil baru ditambahkan, refresh data
                if (result == true) {
                  _fetchCarData();
                  _fetchAllUserCars(); // Refresh daftar mobil di drawer juga
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Add Car Now'),
            ),
          ],
        ),
      );
    }

    // Pastikan nilai adalah double, gunakan null-aware operator dan default jika null
    final double currentMileage =
        (_carData!['current_mileage'] as num?)?.toDouble() ?? 0.0;
    final double nextServiceInterval =
        (_carData!['next_service_interval'] as num?)?.toDouble() ?? 0.0;

    Color cardColor;
    IconData cardIcon;
    String titleText;
    String descriptionText;
    String nextServiceLine;

    // Logika untuk tanggal servis berikutnya (simulasi)
    DateTime nextServiceDateTime;
    if (_currentStatus == "SERVICE_OVERDUE") {
      // Jika overdue, anggap servis terakhir adalah ketika overdue terdeteksi
      nextServiceLine = 'Your vehicle needs maintenance now.';
    } else {
      // Jika ALL_GOOD atau SERVICE_SOON, hitung tanggal berdasarkan interval
      int daysRemaining =
          ((nextServiceInterval - currentMileage) / 100)
              .ceil(); // Estimasi kasar 100km per hari
      if (daysRemaining < 0)
        daysRemaining = 0; // Hindari hari negatif jika sudah overdue
      nextServiceDateTime = DateTime.now().add(Duration(days: daysRemaining));
      nextServiceLine =
          'Next Service ${DateFormat('dd MMMM').format(nextServiceDateTime)}'; // Menggunakan format lengkap
    }

    switch (_currentStatus) {
      case "SERVICE_OVERDUE":
        cardColor = const Color(0xFFE53935);
        cardIcon = Icons.warning_amber;
        titleText = 'Service overdue !';
        descriptionText = 'Your vehicle needs maintenance now.';
        break;
      case "SERVICE_SOON":
        cardColor = const Color(0xFFCDDC39);
        cardIcon = Icons.hourglass_empty;
        titleText = 'Service due soon !';
        descriptionText = 'Your vehicle needs maintenance now.';
        break;
      case "ALL_GOOD":
        cardColor = const Color(0xFF38B000);
        cardIcon = Icons.check_circle_outline;
        titleText = 'No service required.';
        descriptionText = "Everything's is running perfectly.";
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(cardIcon, color: Colors.white, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_currentStatus == "ALL_GOOD")
                      const Icon(Icons.thumb_up, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      titleText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  descriptionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ), // Diubah menjadi Colors.white
                ),
                const SizedBox(height: 4),
                Text(
                  nextServiceLine,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Metode untuk menampilkan pop-up update mileage
  void _showUpdateMileagePopup() {
    if (_carData == null) return;

    // Inisialisasi controller dengan current mileage mobil saat ini
    _currentMileageInputController.text =
        (_carData!['current_mileage'] as num?)?.toStringAsFixed(0) ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222222), // Warna background pop-up
          title: const Text(
            'Update Mileage',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentMileageInputController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Current Mileage (km)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            // Panggil _markServiceDoneFromPopup yang juga akan mengupdate current mileage
                            _markServiceDoneFromPopup();
                          },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Update Last Service Mileage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Warna untuk tombol servis
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        _updateCurrentMileageFromPopup();
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Warna untuk tombol update
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Mileage'),
            ),
          ],
        );
      },
    );
  }

  // Metode untuk menampilkan pop-up konfirmasi delete
  void _showDeleteConfirmationPopup(String carId) {
    // Ubah tipe dari int menjadi String
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222222),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this car?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup pop-up
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup pop-up
                _deleteCar(carId); // Panggil fungsi delete
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna merah untuk delete
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Metode untuk menghapus mobil dari Supabase
  Future<void> _deleteCar(String carId) async {
    // Ubah tipe dari int menjadi String
    setState(() {
      _isLoading = true;
    });
    try {
      await _supabase.from('Mobil').delete().eq('id', carId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car deleted successfully!')),
        );
      }
      // Setelah delete, panggil _fetchCarData tanpa ID spesifik
      // Ini akan memuat mobil pertama yang tersisa atau menunjukkan "no car"
      await _fetchCarData();
      await _fetchAllUserCars(); // Refresh daftar mobil di drawer juga
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting car: ${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected Error: $error')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Jika tidak ada data mobil, tampilkan halaman "Add Car"
    if (_carData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            // Menggunakan Builder untuk context yang tepat
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Buka Drawer
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                // TODO: Handle profile action
              },
            ),
          ],
        ),
        drawer: _buildAppDrawer(), // Menggunakan metode terpisah untuk Drawer
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child:
                _buildStatusCard(), // Langsung gunakan _buildStatusCard untuk menampilkan "no car" state
          ),
        ),
      );
    }

    // Ekstrak data sebelum ditampilkan. Gunakan null-aware operator untuk mencegah 'Null is not a subtype of double'
    final String carName = _carData!['nama_mobil'] ?? 'Mobil Anda';
    final String carType = _carData!['jenis_mobil'] ?? 'Sport';
    final double currentMileage =
        (_carData!['current_mileage'] as num?)?.toDouble() ?? 0.0;
    final double nextServiceInterval =
        (_carData!['next_service_interval'] as num?)?.toDouble() ?? 0.0;
    final double lastServiceMileage =
        (_carData!['last_service_mileage'] as num?)?.toDouble() ?? 0.0;

    // Perhitungan progress bar
    double progressValue;
    String mileageProgressText;

    // Jarak yang harus ditempuh dalam satu siklus servis (misal 10.000 km)
    const double serviceCycleDistance = 10000.0;

    // Pindah logika perhitungan ini di sini, setelah memastikan _carData tidak null
    double distanceCoveredInCurrentCycle = currentMileage - lastServiceMileage;

    if (distanceCoveredInCurrentCycle < 0) {
      distanceCoveredInCurrentCycle = 0;
    }

    progressValue = distanceCoveredInCurrentCycle / serviceCycleDistance;
    progressValue = progressValue.clamp(0.0, 1.0);

    mileageProgressText =
        '${NumberFormat('#,##0').format(currentMileage)} km / ${NumberFormat('#,##0').format(nextServiceInterval)} ';

    // Mendapatkan lebar layar untuk perhitungan persentase
    double screenWidth = MediaQuery.of(context).size.width;

    // Tentukan lebar gambar sebagai persentase dari lebar layar.
    // Misalnya, 70% dari lebar layar.
    // Sesuaikan nilai multiplier ini (0.7) sesuai kebutuhan desain Anda.
    // --- PERUBAHAN DI SINI: MENINGKATKAN PERSENTASE LEBAR KE 80% ---
    final double imageCalculatedWidth =
        screenWidth * 0.8; // 80% dari lebar layar
    // --- AKHIR PERUBAHAN ---

    // Tentukan tinggi gambar secara proporsional atau tetap.
    // Untuk menjaga rasio aspek dan konsistensi, lebih baik tentukan salah satu (misal lebar)
    // dan biarkan 'fit: BoxFit.contain' yang mengatur tinggi.
    // Jika Anda benar-benar ingin tinggi tetap, Anda bisa gunakan:
    // final double imageCalculatedHeight = screenHeight * 0.3; // Misal 30% dari tinggi layar
    // Namun, jika rasio aspek gambar berbeda, ini bisa membuat gambar terlihat berbeda.
    // Untuk menjaga rasio aspek dan memastikan gambar tidak terpotong,
    // yang terbaik adalah hanya menentukan satu dimensi (misal lebar) dan gunakan BoxFit.contain.
    // Atau, jika Anda ingin ukuran tetap (misal 200x200), tentukan keduanya.

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Background utama
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          // Menggunakan Builder untuk context yang tepat
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Buka Drawer
              },
            );
          },
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  carName,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(width: 4),
              ],
            ),
            Text(
              carType,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: _buildAppDrawer(), // Menggunakan metode terpisah untuk Drawer
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(35, 35, 35, 0.5), Color(0xFF000000)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0, left: 0),
                            child: Text(
                              _getStatusMainText(),
                              style: TextStyle(
                                fontSize: 72,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.bold,
                                color: _getStatusMainTextColor(),
                              ),
                            ),
                          ),
                        ),
                        // PERUBAHAN UTAMA DI SINI: Menggunakan ukuran persentase dari lebar layar
                        Padding(
                          padding: const EdgeInsets.only(top: 130),
                          child: Image.asset(
                            _getCarImagePath(carType),
                            width:
                                imageCalculatedWidth, // Lebar berdasarkan persentase
                            // height: imageCalculatedHeight, // Opsional: jika ingin tinggi juga persentase
                            fit:
                                BoxFit
                                    .contain, // Memastikan gambar tidak terpotong dan rasio aspek terjaga
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigasi ke Detail Status Mobil'),
                          ),
                        );
                        // TODO: Implement navigation to actual detail page if needed
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(35, 35, 35, 0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.lock_open,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "CHECK STATUS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        // Menggunakan tanggal saat ini untuk "Updated vehicle status"
                        "Updated vehicle status ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ), // Atur padding jika perlu
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.speed,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Mileage',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // ICON EDIT DIPINDAHKAN KE SINI
                                  GestureDetector(
                                    onTap:
                                        _showUpdateMileagePopup, // Memanggil pop-up
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$mileageProgressText km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: Colors.grey[700],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _currentStatus == "SERVICE_OVERDUE"
                                  ? const Color(0xFFE53935)
                                  : _currentStatus == "SERVICE_SOON"
                                  ? const Color(0xFFCDDC39)
                                  : const Color(0xFF38B000),
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24), // Jarak setelah mileage bar
                    // Kartu Status (ALL GOOD / SERVICE SOON / SERVICE OVERDUE)
                    _buildStatusCard(),
                    const SizedBox(height: 20),

                    _buildCarInformationDisplay(
                      _carData!,
                    ), // Pass the fetched car data
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Metode untuk membangun Drawer (menu samping)
  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF222222), // Background gelap untuk drawer
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(
                0xFF333333,
              ), // Warna sedikit lebih terang untuk header
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Your Cars',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your vehicles here',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            // Tombol "Add New Car"
            leading: const Icon(Icons.add_circle_outline, color: Colors.white),
            title: const Text(
              'Add New Car',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context); // Tutup drawer
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCarPage()),
              );
              if (result == true) {
                // Setelah menambah mobil baru, ambil mobil pertama dan refresh daftar semua mobil
                _fetchCarData();
                _fetchAllUserCars();
              }
            },
          ),
          const Divider(color: Colors.white24),
          Expanded(
            // Daftar mobil yang terhubung dengan user
            child:
                _allUserCars == null || _allUserCars!.isEmpty
                    ? const Center(
                      child: Text(
                        'No other cars added yet.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _allUserCars!.length,
                      itemBuilder: (context, index) {
                        final car = _allUserCars![index];
                        return ListTile(
                          title: Text(
                            car['nama_mobil'] ?? 'Unknown Car',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            car['jenis_mobil'] ?? 'Type N/A',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              // Panggil pop-up konfirmasi delete
                              _showDeleteConfirmationPopup(
                                car['id'] as String,
                              ); // Ubah dari int menjadi String
                            },
                          ),
                          onTap: () async {
                            // Logika untuk mengganti mobil yang aktif ditampilkan
                            // Pastikan mobil yang dipilih ada dan memiliki 'id'
                            if (car['id'] != null) {
                              setState(() {
                                _carData =
                                    car; // Set mobil yang dipilih sebagai mobil utama
                                _calculateServiceStatus(); // Hitung ulang status servis untuk mobil baru
                              });
                              Navigator.pop(context); // Tutup drawer
                              // Refresh daftar semua mobil (penting jika ada perubahan di luar tab)
                              await _fetchAllUserCars();
                            }
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInformationDisplay(Map<String, dynamic> carData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(35, 35, 35, 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CAR INFORMATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // Pastikan _carData tidak null sebelum diteruskan
                  if (_carData != null) {
                    // Navigasi ke AddCarPage untuk mengedit mobil
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddCarPage(
                              carData: _carData!,
                            ), // Teruskan _carData (variabel state)
                      ),
                    );
                    // Jika ada perubahan (result true), refresh data mobil yang sedang ditampilkan
                    if (result == true) {
                      _fetchCarData(
                        carIdToFetch: _carData!['id'] as String,
                      ); // Ubah dari int menjadi String
                      _fetchAllUserCars(); // Refresh all cars in the drawer
                    }
                  }
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20, thickness: 1),
          _buildInfoRow(
            icon: Icons.directions_car,
            label: 'Name',
            value: carData['nama_mobil'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.branding_watermark,
            label: 'Brand',
            value: carData['brand'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Year of Manufacture',
            value: carData['year_of_manufacturer']?.toString() ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.car_rental,
            label: 'Car Type',
            value: carData['jenis_mobil'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.settings,
            label: 'Transmission',
            value: carData['transmission'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.local_gas_station,
            label: 'Fuel Type',
            value: carData['fuel_type'] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  // Helper widget for each info row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
