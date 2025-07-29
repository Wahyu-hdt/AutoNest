import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'service_form_page.dart';

class StatusDetailPage extends StatefulWidget {
  final String carId; // Add carId as a required parameter
  final String lastServiceDate;
  final String nextServiceDate;
  final String overallCondition;

  const StatusDetailPage({
    super.key,
    required this.carId, // Make carId required
    required this.lastServiceDate,
    required this.nextServiceDate,
    required this.overallCondition,
  });

  @override
  State<StatusDetailPage> createState() => _StatusDetailPageState();
}

class _StatusDetailPageState extends State<StatusDetailPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _componentServiceHistory = [];
  List<Map<String, dynamic>> _allServiceHistory = [];
  bool _isLoading = true;

  String _displayedLastServiceDate = 'N/A';
  String _displayedLastServiceMileage = 'N/A';

  @override
  void initState() {
    super.initState();
    _fetchServiceHistory();
  }

  Future<void> _fetchServiceHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final String? userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        // Handle not logged in case
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in.')),
          );
        }
        setState(() {
          _componentServiceHistory = [];
          _allServiceHistory = [];
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> responseAll = await _supabase
          .from('Gantipart')
          .select()
          .eq('mobil_id', widget.carId)
          .order(
            'tanggal_service',
            ascending: false,
          ); // Urutkan berdasarkan tanggal terbaru

      _allServiceHistory = responseAll;

      // --- LOGIKA BARU UNTUK MENDAPATKAN SERVIS TERAKHIR SECARA KESELURUHAN ---
      if (_allServiceHistory.isNotEmpty) {
        final latestServiceEntry =
            _allServiceHistory.first; // Karena sudah diurutkan descending
        final DateTime latestDate = DateTime.parse(
          latestServiceEntry['tanggal_service'],
        );
        _displayedLastServiceDate = DateFormat('dd/MM/yyyy').format(latestDate);
        _displayedLastServiceMileage =
            latestServiceEntry['mileage_service']?.toStringAsFixed(0) ?? 'N/A';
      } else {
        _displayedLastServiceDate =
            widget.lastServiceDate; // Fallback ke prop jika tidak ada riwayat
        _displayedLastServiceMileage = 'N/A';
      }

      final Map<String, Map<String, dynamic>> latestComponentServices = {};
      for (var service in responseAll) {
        final String serviceType = service['tipe_service'] ?? 'Unknown';
        if (!latestComponentServices.containsKey(serviceType) ||
            (latestComponentServices[serviceType]!['tanggal_service'] as String)
                    .compareTo(service['tanggal_service'] as String) <
                0) {
          latestComponentServices[serviceType] = service;
        }
      }
      _componentServiceHistory = latestComponentServices.values.toList();
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching service history: ${error.message}'),
          ),
        );
      }
      setState(() {
        _componentServiceHistory = [];
        _allServiceHistory = [];
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $error')),
        );
      }
      setState(() {
        _componentServiceHistory = [];
        _allServiceHistory = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Data riwayat servis
  void _showServiceHistoryDialog(
    BuildContext context,
    List<Map<String, dynamic>> history,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            "Service History",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child:
                history.isEmpty
                    ? const Center(
                      child: Text(
                        'No service history available.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final DateTime serviceDate =
                            item['tanggal_service'] != null
                                ? DateTime.parse(item['tanggal_service'])
                                : DateTime.now();
                        final String formattedDate = DateFormat(
                          'dd/MM/yyyy', // Mengubah format tanggal
                        ).format(serviceDate);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date: $formattedDate",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "KM: ${item['mileage_service']?.toStringAsFixed(0) ?? 'N/A'} KM",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "Type: ${item['tipe_service'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Divider(color: Colors.white24),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'oil':
        return Icons.oil_barrel;
      case 'brake':
        return Icons.build_circle;
      case 'radiator':
        return Icons.battery_charging_full;
      case 'spark plugs':
        return Icons.electrical_services;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Stack(
                children: [
                  Positioned.fill(
                    top: 200,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/car_status.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 330,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.25),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const Text(
                                'Vehicle Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 350),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "SERVICES",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        () => _showServiceHistoryDialog(
                                          context,
                                          _allServiceHistory,
                                        ),
                                    child: const Text(
                                      "History",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Services Status",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        Text(
                                          "Last Service : $_displayedLastServiceDate (${_displayedLastServiceMileage} KM)\nNext Service : ${DateFormat('dd/MM/yyyy').format(DateFormat('dd MMMM yyyy').parse(widget.nextServiceDate))}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white30, height: 32),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Overall Condition",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.overallCondition,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white30, height: 32),
                              const Text(
                                "Component Service",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 80,
                                child:
                                    _componentServiceHistory.isEmpty
                                        ? const Center(
                                          child: Text(
                                            'No component service records found.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                        : PageView.builder(
                                          itemCount:
                                              _componentServiceHistory.length,
                                          controller: PageController(
                                            viewportFraction: 0.9,
                                          ),
                                          itemBuilder: (context, index) {
                                            final item =
                                                _componentServiceHistory[index];
                                            final DateTime serviceDate =
                                                item['tanggal_service'] != null
                                                    ? DateTime.parse(
                                                      item['tanggal_service'],
                                                    )
                                                    : DateTime.now();
                                            final String
                                            formattedDate = DateFormat(
                                              'dd/MM/yyyy', // Mengubah format tanggal
                                            ).format(serviceDate);
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF0F0F0F,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.white30,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            _getServiceIcon(
                                                              item['tipe_service'] ??
                                                                  '',
                                                            ),
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              item['tipe_service'] ??
                                                                  'N/A',
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 14,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        const Text(
                                                          "Last Changed",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Text(
                                                          formattedDate,
                                                          style: const TextStyle(
                                                            color:
                                                                Colors
                                                                    .blueAccent,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceFormPage(carId: widget.carId),
            ),
          );
          if (result == true) {
            _fetchServiceHistory();
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
