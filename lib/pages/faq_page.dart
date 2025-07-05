import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<Map<String, String>> faqList = [
    {
      "question": "Apa itu aplikasi AutoNet dan apa fungsinya?",
      "answer":
          "Aplikasi ini adalah platform pintar yang dirancang untuk membantu pemilik kendaraan memantau kondisi mobil mereka secara real-time. Dengan aplikasi ini, Anda dapat melihat status kendaraan, jadwal servis, lokasi bengkel rekomendasi, serta notifikasi peringatan servis secara otomatis.",
    },
    {
      "question":
          "Bagaimana cara menggunakan fitur pengecekan status kendaraan?",
      "answer":
          "Anda hanya perlu masuk ke halaman utama aplikasi. Di sana, Anda akan langsung melihat status kendaraan seperti jarak tempuh, informasi servis terakhir, dan apakah ada peringatan atau tidak. Untuk informasi lebih detail, cukup tekan tombol Check Status",
    },
    {
      "question":
          "Apakah saya bisa menemukan bengkel terdekat melalui aplikasi ini?",
      "answer":
          "Tentu! Aplikasi ini menyediakan fitur pencarian bengkel berdasarkan lokasi. Anda bisa memfilter berdasarkan daerah (seperti Jakarta, Surabaya, dll.) dan juga berdasarkan jenis layanan yang Anda butuhkan (seperti aki, oli, atau ban).",
    },
    {
      "question": "Apakah data saya aman di dalam aplikasi ini?",
      "answer":
          "Keamanan data Anda adalah prioritas kami. Kami menggunakan enkripsi dan autentikasi yang kuat untuk memastikan informasi pribadi dan data kendaraan Anda tetap aman dan tidak disalahgunakan oleh pihak ketiga.",
    },
  ];

  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    expanded = List.generate(faqList.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF232323), // atas
              Color(0xFF000000), // bawah
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Image.asset(
                  'assets/images/hamburg.png',
                  height: 24,
                  width: 24,
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "FAQ",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lato',
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFCFCFCF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 32,
                  ),
                  child: ListView.builder(
                    itemCount: faqList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            collapsedIconColor: Colors.black,
                            iconColor: Colors.black,
                            onExpansionChanged: (val) {
                              setState(() => expanded[index] = val);
                            },
                            title: Text(
                              faqList[index]['question']!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Lato',
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  faqList[index]['answer']!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'Lato',
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
