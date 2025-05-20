import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? expandedIndex;

  final List<FAQSection> sections = [
    FAQSection(
      title: 'General Usage',
      questions: [
        FAQItem(
            question: 'How does the DermexAI app work?',
            answer:
                'DermexAI uses artificial intelligence to analyze skin images and identify common skin conditions. The user captures a photo of the affected area, and the model processes it to provide an initial result within seconds.'),
        FAQItem(
            question: 'How can I perform a skin analysis?',
            answer:
                'You can either take a photo using your camera or upload one from your device. The app will automatically analyze it and display the result.'),
        FAQItem(
            question: 'How long does the image analysis take?',
            answer: 'The analysis usually takes between 3 to 5 seconds.'),
        FAQItem(
            question: 'Can I review my past scans?',
            answer: 'Yes you can in the History page'),
        FAQItem(
            question: 'Does the app provide direct medical consultations?',
            answer:
                'No, the app does not provide direct medical consultations. It is always recommended to consult a healthcare professional.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 640 ? 0 : 10,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width > 640 ? 25 : 16,
              ),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 640 ? 24 : 16,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigate back to the previous screen
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECECEC),
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: const Icon(Icons.arrow_back_ios),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'FAQs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sections.length,
                      itemBuilder: (context, sectionIndex) {
                        return FAQSectionWidget(
                          section: sections[sectionIndex],
                          expandedIndex: expandedIndex,
                          onExpand: (index) {
                            setState(() {
                              expandedIndex =
                                  expandedIndex == index ? null : index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FAQSection {
  final String title;
  final List<FAQItem> questions;

  FAQSection({required this.title, required this.questions});
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class FAQSectionWidget extends StatelessWidget {
  final FAQSection section;
  final int? expandedIndex;
  final Function(int) onExpand;

  const FAQSectionWidget({
    Key? key,
    required this.section,
    required this.expandedIndex,
    required this.onExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Text(
            section.title,
            style: const TextStyle(
              color: Color(0xFF1B9BDB),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        ...section.questions
            .map((question) => FAQItemWidget(
                  item: question,
                  isExpanded:
                      expandedIndex == section.questions.indexOf(question),
                  onTap: () => onExpand(section.questions.indexOf(question)),
                ))
            .toList(),
      ],
    );
  }
}

class FAQItemWidget extends StatelessWidget {
  final FAQItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQItemWidget({
    Key? key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isExpanded ? const Color(0xFFECECEC) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 20,
                      color: const Color(0xFF1F2937),
                    ),
                  ],
                ),
                if (isExpanded && item.answer.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    item.answer,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1F2937),
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
