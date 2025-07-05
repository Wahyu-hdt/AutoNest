import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCarPage extends StatefulWidget {
  final Map<String, dynamic>?
  carData; // Nullable for adding new car, non-null for editing

  const AddCarPage({super.key, this.carData});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _yearOfManufactureController =
      TextEditingController();
  final TextEditingController _lastServiceMileageController =
      TextEditingController();
  // We don't need controllers for current_mileage or next_service_interval here,
  // as they are either derived on add, or updated via HomePage's mechanism.

  String? _selectedCarType;
  String? _selectedTransmission;
  String? _selectedFuelType;

  bool _isEditing = false;
  bool _isLoading = false;

  // Definisi daftar item untuk Dropdown
  final List<String> _carTypes = [
    'Sport',
    'Sedan',
    'Hatchback',
    'SUV',
    'Truck',
  ];
  final List<String> _transmissions = ['Automatic', 'Manual'];
  final List<String> _fuelTypes = [
    'Petrol',
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.carData != null) {
      _isEditing = true;
      _nameController.text = widget.carData!['nama_mobil'] ?? '';
      _brandController.text = widget.carData!['brand'] ?? '';
      _yearOfManufactureController.text =
          (widget.carData!['year_of_manufacturer'] ?? '').toString();
      _lastServiceMileageController.text =
          (widget.carData!['last_service_mileage'] ?? '').toString();

      // CAR TYPE
      final String? carTypeFromDb = widget.carData!['jenis_mobil'];
      if (carTypeFromDb != null) {
        if (_carTypes.contains(carTypeFromDb)) {
          _selectedCarType = carTypeFromDb;
        } else {
          // Handle cases where DB value might be slightly different, e.g., "Sport Car" vs "Sport"
          if (carTypeFromDb == 'Sport Car') {
            _selectedCarType = 'Sport';
          } else {
            _selectedCarType = null; // Default to null if not found
          }
        }
      } else {
        _selectedCarType = null;
      }

      // FUEL TYPE
      final String? fuelTypeFromDb =
          widget.carData!['fuel_type']?.toString().trim();
      if (fuelTypeFromDb != null) {
        String? foundFuelType;
        for (var type in _fuelTypes) {
          if (type.toLowerCase() == fuelTypeFromDb.toLowerCase()) {
            foundFuelType = type;
            break;
          }
        }

        if (foundFuelType != null) {
          _selectedFuelType = foundFuelType;
        } else {
          _selectedFuelType = null;
          print(
            'Warning: Fuel Type "$fuelTypeFromDb" from DB not found in _fuelTypes list.',
          );
        }
      } else {
        _selectedFuelType = null;
      }
      _selectedTransmission = widget.carData!['transmission'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _yearOfManufactureController.dispose();
    _lastServiceMileageController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
        return;
      }

      final double lastServiceMileage = double.parse(
        _lastServiceMileageController.text,
      );

      Map<String, dynamic> carDataToSave = {
        'nama_mobil': _nameController.text,
        'brand': _brandController.text,
        'year_of_manufacturer': int.parse(_yearOfManufactureController.text),
        'jenis_mobil': _selectedCarType,
        'transmission': _selectedTransmission,
        'fuel_type': _selectedFuelType,
        'last_service_mileage': lastServiceMileage,
        'user_profil_id': userId,
      };

      if (!_isEditing) {
        // jika menambahkan mobil baru. inisiasi current_mileage and next_service_interval
        // current_mileage mula mula akan sama dengan last_service_mileage
        carDataToSave['current_mileage'] = lastServiceMileage;
        // next_service_interval adalah 10000km dari awal last_service_mileage
        carDataToSave['next_service_interval'] = lastServiceMileage + 10000.0;
      }

      if (_isEditing) {
        await _supabase
            .from('Mobil')
            .update(carDataToSave)
            .eq('id', widget.carData!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully Updated Car Info')),
          );
          Navigator.pop(
            context,
            true,
          ); // Kembali dan beritahu HomePage untuk refresh
        }
      } else {
        await _supabase.from('Mobil').insert(carDataToSave);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully Added The Car')),
          );
          Navigator.pop(
            context,
            true,
          ); // Kembali dan beritahu HomePage untuk refresh
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${error.message}')));
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Car' : 'Add New Car',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Car Name',
                        icon: Icons.directions_car,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _brandController,
                        labelText: 'Brand',
                        icon: Icons.branding_watermark,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter brand';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _yearOfManufactureController,
                        labelText: 'Year of Manufacture',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter year';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        labelText: 'Car Type',
                        value: _selectedCarType,
                        icon: Icons.category,
                        items: _carTypes, // Menggunakan variabel _carTypes
                        onChanged: (value) {
                          setState(() {
                            _selectedCarType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select car type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        labelText: 'Transmission',
                        value: _selectedTransmission,
                        icon: Icons.settings,
                        items:
                            _transmissions, // Menggunakan variabel _transmissions
                        onChanged: (value) {
                          setState(() {
                            _selectedTransmission = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select transmission';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        labelText: 'Fuel Type',
                        value: _selectedFuelType,
                        icon: Icons.local_gas_station,
                        items: _fuelTypes, // Menggunakan variabel _fuelTypes
                        onChanged: (value) {
                          setState(() {
                            _selectedFuelType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select fuel type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // last_service_mileage: Only editable if Add Car, not if Edit Car
                      _buildTextField(
                        controller: _lastServiceMileageController,
                        labelText: 'Last Service Mileage (km)',
                        icon: Icons.history,
                        keyboardType: TextInputType.number,
                        // Logika kondisional untuk readOnly dan enabled
                        readOnly: _isEditing, // readOnly jika sedang edit
                        enabled:
                            !_isEditing, // enabled jika tidak sedang edit (yaitu add)
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last service mileage';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid mileage';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Last Service Mileage (km)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: Icon(
                            Icons.history,
                            color: Colors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            // Border color based on whether it's enabled or not
                            borderSide: BorderSide(
                              color:
                                  _isEditing ? Colors.white12 : Colors.white30,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          filled: true,
                          // Fill color based on whether it's enabled or not
                          fillColor:
                              _isEditing
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white10,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    _isEditing ? 'Update Car' : 'Add Car',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
    InputDecoration? decoration,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration:
          decoration ??
          InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: Icon(icon, color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.white10,
          ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: Colors.white10,
      ),
      dropdownColor: const Color(0xFF222222),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white70,
      onChanged: onChanged,
      validator: validator,
      items:
          items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
    );
  }
}
