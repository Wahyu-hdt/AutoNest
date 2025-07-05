import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<Map<String, String>> faqList = [
    {
      "question": "Question 1",
      "answer":
          "Aplikasi ini adalah platform pintar yang dirancang untuk membantu pemilik kendaraan memantau kondisi mobil mereka secara real-time. Dengan aplikasi ini, Anda dapat melihat status kendaraan, jadwal servis, lokasi bengkel rekomendasi, serta notifikasi peringatan servis secara otomatis.",
    },
    {
      "question": "Question 2",
      "answer":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec malesuada ex non lorem gravida molestie. Etiam vitae tortor eget sem tincidunt condimentum. Vivamus dapibus quis sapien scelerisque hendrerit.",
    },
    {"question": "Question 3", "answer": "Answer for question 3."},
    {"question": "Question 4", "answer": "Answer for question 4."},
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
