// service_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ServiceFormPage extends StatefulWidget {
  final String carId; // Menerima carId
  const ServiceFormPage({
    super.key,
    required this.carId,
  }); // Perbarui constructor

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _supabase = Supabase.instance.client; // Inisialisasi Supabase client
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<String> selectedServices = [];
  bool _isLoading = false; // Untuk indikator loading

  final List<String> serviceOptions = [
    'Oil',
    'Brake',
    'Radiator',
    'Spark Plugs',
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now()); // Set tanggal default hari ini
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _showMultiSelectDialog() async {
    final List<String> tempSelected = List.from(selectedServices);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Select Services",
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children:
                      serviceOptions.map((service) {
                        return CheckboxListTile(
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                          title: Text(
                            service,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: tempSelected.contains(service),
                          onChanged: (isChecked) {
                            setStateDialog(() {
                              if (isChecked == true &&
                                  !tempSelected.contains(service)) {
                                tempSelected.add(service);
                              } else {
                                tempSelected.remove(service);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => selectedServices = List.from(tempSelected));
                Navigator.of(context).pop();
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF222222),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1C1C1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Fungsi untuk menambahkan riwayat servis ke Supabase
  Future<void> _addServiceEntry() async {
    if (_mileageController.text.isEmpty ||
        _dateController.text.isEmpty ||
        selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and select at least one service.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double mileage = double.parse(_mileageController.text);
      final String date = _dateController.text;
      final String serviceTypes = selectedServices.join(
        ', ',
      ); // Gabungkan layanan yang dipilih menjadi satu string

      await _supabase.from('Gantipart').insert({
        // Gunakan nama tabel 'Gantipart'
        'mobil_id': widget.carId, // Menggunakan carId dari widget
        'tanggal_service': date, // Nama kolom sesuai skema
        'mileage_service': mileage, // Nama kolom sesuai skema
        'tipe_service': serviceTypes, // Nama kolom sesuai skema
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service history added successfully!')),
        );
        Navigator.pop(
          context,
          true,
        ); // Kembali ke halaman sebelumnya dan beri sinyal sukses
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding service history: ${error.message}'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan tak terduga: $error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF232323), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Service",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white, thickness: 1, height: 32),

                const SizedBox(height: 10),
                const Text("Mileage", style: TextStyle(color: Colors.white70)),
                TextField(
                  controller: _mileageController, // Tambahkan controller
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Type of Service",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _showMultiSelectDialog,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text: selectedServices.join(', '),
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Select multiple services",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Date", style: TextStyle(color: Colors.white70)),
                TextField(
                  controller: _dateController, // Tambahkan controller
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTap: () {
                    _selectDate(context); // Panggil date picker
                  },
                ),

                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: _isLoading ? null : _addServiceEntry,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text("+ Service"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
