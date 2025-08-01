import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class BengkelPage extends StatefulWidget {
  const BengkelPage({Key? key}) : super(key: key);

  @override
  State<BengkelPage> createState() => _BengkelPageState();
}

class _BengkelPageState extends State<BengkelPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bengkelList = [];
  bool _isLoading = true;
  String? _selectedLokasi;
  String? _selectedSpesialisasi;

  final List<String> _lokasiOptions = ['Jakarta', 'Yogyakarta', 'Surabaya'];
  final List<String> _spesialisasiOptions = [
    'Engine',
    'Suspension',
    'Body',
  ]; // Translated to English

  @override
  void initState() {
    super.initState();
    _fetchBengkelData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchBengkelData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var query = supabase.from('Bengkel').select('*');

      if (_selectedLokasi != null && _selectedLokasi!.isNotEmpty) {
        query = query.eq('lokasi', _selectedLokasi!);
      }

      if (_selectedSpesialisasi != null && _selectedSpesialisasi!.isNotEmpty) {
        query = query.eq('spesialisasi', _selectedSpesialisasi!);
      }

      final data = await query;
      setState(() {
        _bengkelList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchMapsUrl(String location) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop List'), // Translated to English
        backgroundColor: const Color(0xFF232323),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          // Filter Lokasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Location:', // Translated to English
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._lokasiOptions
                      .map(
                        (lokasi) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(lokasi),
                            selected: _selectedLokasi == lokasi,
                            onSelected: (selected) {
                              setState(() {
                                _selectedLokasi =
                                    (_selectedLokasi == lokasi) ? null : lokasi;
                              });
                              _fetchBengkelData();
                            },
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.grey[800],
                            labelStyle: TextStyle(
                              color:
                                  _selectedLokasi == lokasi
                                      ? Colors.white
                                      : Colors.grey[300],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
          // Filter Spesialisasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Specialization:', // Translated to English
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._spesialisasiOptions
                      .map(
                        (spesialisasi) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(spesialisasi),
                            selected: _selectedSpesialisasi == spesialisasi,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSpesialisasi =
                                    (_selectedSpesialisasi == spesialisasi)
                                        ? null
                                        : spesialisasi;
                              });
                              _fetchBengkelData();
                            },
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.grey[800],
                            labelStyle: TextStyle(
                              color:
                                  _selectedSpesialisasi == spesialisasi
                                      ? Colors.white
                                      : Colors.grey[300],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : _bengkelList.isEmpty
                    ? const Center(
                      child: Text(
                        'No workshops found.', // Translated to English
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _bengkelList.length,
                      itemBuilder: (context, index) {
                        final bengkel = _bengkelList[index];
                        final String lokasiBengkel =
                            bengkel['lokasi'] ??
                            'Unknown Location'; // Translated to English
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          color: const Color(0xFF1A1A1A),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bengkel['nama_bengkel'] ??
                                      'Unknown Name', // Translated to English
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Location: $lokasiBengkel', // Translated to English
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Specialization: ${bengkel['spesialisasi'] ?? 'Unknown'}', // Translated to English
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.map,
                                      color: Colors.blueAccent,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      if (lokasiBengkel != 'Unknown Location') {
                                        // Translated to English
                                        _launchMapsUrl(lokasiBengkel);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Workshop location not available.', // Translated to English
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    tooltip:
                                        'View on Google Maps', // Translated to English
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
