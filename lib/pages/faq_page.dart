import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<Map<String, String>> faqList = [
    {
      "question": "What is the AutoNest app and what does it do?",
      "answer":
          "This application is a smart platform designed to help vehicle owners monitor their car's condition in real-time. With this app, you can view vehicle status, service schedules, recommended workshop locations, and automatic service reminder notifications.",
    },
    {
      "question": "How do I use the vehicle status check feature?",
      "answer":
          "You just need to go to the main page of the application. There, you will immediately see the vehicle status such as mileage, last service information, and whether there are any warnings. For more detailed information, simply press the 'Check Status' button.",
    },
    {
      "question": "Can I find nearby workshops through this app?",
      "answer":
          "Certainly! This app provides a workshop search feature based on location. You can filter by area (such as Jakarta, Surabaya, etc.) and also by the type of service you need (such as battery, oil, or tires).",
    },
    {
      "question": "Is my data safe within this application?",
      "answer":
          "Your data security is our priority. We use strong encryption and authentication to ensure your personal information and vehicle data remain safe and are not misused by third parties.",
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
              Color(0xFF232323), // top
              Color(0xFF000000), // bottom
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(backgroundColor: Colors.transparent, elevation: 0),

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
