// import 'package:flutter/material.dart';

// class ServiceFormPage extends StatefulWidget {
//   const ServiceFormPage({super.key});

//   @override
//   State<ServiceFormPage> createState() => _ServiceFormPageState();
// }

// class _ServiceFormPageState extends State<ServiceFormPage> {
//   final List<String> serviceOptions = [
//     'Oil',
//     'Brake',
//     'Radiator',
//     'Spark Plugs',
//   ];

//   List<String> selectedServices = [];

//   void _showMultiSelectDialog() async {
//     final List<String> tempSelected = List.from(selectedServices);

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.black,
//           title: const Text(
//             "Select Services",
//             style: TextStyle(color: Colors.white),
//           ),
//           content: StatefulBuilder(
//             builder: (context, setStateDialog) {
//               return SingleChildScrollView(
//                 child: Column(
//                   children: serviceOptions.map((service) {
//                     return CheckboxListTile(
//                       activeColor: Colors.white,
//                       checkColor: Colors.black,
//                       title: Text(service,
//                           style: const TextStyle(color: Colors.white)),
//                       value: tempSelected.contains(service),
//                       onChanged: (isChecked) {
//                         setStateDialog(() {
//                           if (isChecked == true &&
//                               !tempSelected.contains(service)) {
//                             tempSelected.add(service);
//                           } else {
//                             tempSelected.remove(service);
//                           }
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() => selectedServices = List.from(tempSelected));
//                 Navigator.of(context).pop();
//               },
//               child: const Text("OK", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true, // penting agar gradient sampai ke atas
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const BackButton(color: Colors.white),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF232323), // Atas
//               Colors.black,       // Bawah
//             ],
//           ),
//         ),
//         child: SafeArea( // menjaga isi tidak nabrak status bar
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Service",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Divider(color: Colors.white, thickness: 1, height: 32),

//                 const SizedBox(height: 10),
//                 const Text("Mileage", style: TextStyle(color: Colors.white70)),
//                 TextField(
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white10,
//                     border:
//                         OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//                 const Text("Type of Service",
//                     style: TextStyle(color: Colors.white70)),
//                 const SizedBox(height: 6),
//                 GestureDetector(
//                   onTap: _showMultiSelectDialog,
//                   child: AbsorbPointer(
//                     child: TextField(
//                       controller: TextEditingController(
//                           text: selectedServices.join(', ')),
//                       style: const TextStyle(color: Colors.white),
//                       decoration: InputDecoration(
//                         hintText: "Select multiple services",
//                         hintStyle: const TextStyle(color: Colors.white54),
//                         filled: true,
//                         fillColor: Colors.white10,
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8)),
//                         suffixIcon: const Icon(Icons.arrow_drop_down,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//                 const Text("Date", style: TextStyle(color: Colors.white70)),
//                 TextField(
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.white10,
//                     border:
//                         OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onTap: () {
//                     // Tambahkan date picker handler di sini
//                   },
//                 ),

//                 const SizedBox(height: 40),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: OutlinedButton(
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       side: const BorderSide(color: Colors.white),
//                     ),
//                     onPressed: () {
//                       debugPrint("Mileage, Selected: $selectedServices");
//                     },
//                     child: const Text("+ Service"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({super.key});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final List<String> serviceOptions = [
    'Oil',
    'Brake',
    'Radiator',
    'Spark Plugs',
  ];

  List<String> selectedServices = [];

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
                  children: serviceOptions.map((service) {
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
            colors: [
              Color(0xFF232323),
              Colors.black,
            ],
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
                const Text("Type of Service",
                    style: TextStyle(color: Colors.white70)),
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
                        suffixIcon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Date", style: TextStyle(color: Colors.white70)),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTap: () {
                    // Date picker bisa ditambahkan di sini
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
                    onPressed: () {
                      debugPrint("Selected Services: $selectedServices");
                    },
                    child: const Text("+ Service"),
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
