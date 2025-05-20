import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'hospital_list_screen.dart';
import 'history_screen.dart';

class Gallerypage extends StatefulWidget {
  const Gallerypage({super.key});

  @override
  State<Gallerypage> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<Gallerypage>
    with TickerProviderStateMixin {
  bool isHovered = false;
  double confidence = 0.0;
  double _displayedConfidence = 0.0;
  String prediction = "";
  bool isLoading = false;
  String errorMessage = "";

  late AnimationController _animationController;
  late Animation<double> _confidenceAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // خريطة تحتوي على نصائح لكل نوع مرض
  final Map<String, Map<String, List<String>>> diseaseAdvice = {
    'Enfeksiyonel': {
      'Causes': [
        'Bacteria',
        'Viruses',
        'Fungi',
        'Parasites',
        'Poor hygiene',
        'Contaminated food or water',
        'Close contact with infected individuals',
      ],
      'Prevention': [
        'Regular hand washing',
        'Vaccination',
        'Avoiding contact with infected individuals',
        'Using clean and safe drinking water',
        'Proper food handling and cooking',
        'Using insect protection',
      ],
    },
    'Benign': {
      'Causes': [
        'Genetic factors',
        'Hormonal imbalances',
        'Environmental exposure',
        'Chronic inflammation or irritation',
      ],
      'Prevention': [
        'Regular medical check-ups',
        'Avoid exposure to harmful substances',
        'Maintain a healthy lifestyle',
        'Protect skin from sun exposure',
      ],
    },
    'Malign': {
      'Causes': [
        'Genetic mutations',
        'Tobacco use',
        'Exposure to carcinogens',
        'Chronic infections',
        'Poor diet and inactivity',
        'Family history',
      ],
      'Prevention': [
        'Avoid smoking',
        'Maintain a healthy diet',
        'Regular physical activity',
        'Routine medical screenings',
        'Vaccination',
        'Avoid exposure to harmful substances',
        'Use sun protection',
      ],
    },
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _confidenceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
        setState(() {
          _displayedConfidence = confidence * _confidenceAnimation.value;
        });
      });

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> pickImageFromGallery() async {
    try {
      setState(() {
        errorMessage = "";
        isLoading = true;
      });

      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await classifyImage(_imageFile!);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        errorMessage = "Failed to pick image: ${e.toString()}";
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _saveDiagnosisToHistory() async {
    if (prediction.isEmpty || _imageFile == null) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    final diagnosisEntry = {
      'diagnosis': prediction,
      'confidence': confidence / 100,
      'date': formatter.format(now),
      'imagePath': _imageFile!.path,
      'timestamp': now.millisecondsSinceEpoch,
    };

    final history = prefs.getStringList('diagnosis_history') ?? [];
    history.add(json.encode(diagnosisEntry));
    await prefs.setStringList('diagnosis_history', history);
  }

  Future<void> classifyImage(File imageFile) async {
    const apiUrl =
        // 'https://skin-disease-classifier.graysea-9f97d34a.uaenorth.azurecontainerapps.io/classify';
        "https://skin-classifier.proudmushroom-9dba50dd.uaenorth.azurecontainerapps.io/classify";

    try {
      setState(() {
        errorMessage = "";
        isLoading = true;
        _displayedConfidence = 0.0;
      });

      final extension = p.extension(imageFile.path).toLowerCase();
      final contentType = extension == '.png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: contentType,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);

        setState(() {
          prediction = jsonData['prediction'];
          confidence = jsonData['confidence'] * 100;
          isLoading = false;
        });

        await _saveDiagnosisToHistory();

        _animationController.forward(from: 0).then((_) {
          _pulseController.repeat(reverse: true);
        });
      } else {
        final errorResponse = await response.stream.bytesToString();
        final errorJson = json.decode(errorResponse);

        setState(() {
          errorMessage = errorJson['detail'] ?? "Unknown error occurred";
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $errorMessage")),
        );
      }
    } catch (e) {
      print('Error calling API: $e');
      setState(() {
        errorMessage =
            "Failed to connect to the server. Please check your internet connection.";
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECECEC),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildDiagnosisCard(),
              const SizedBox(height: 20),
              _buildAboutSection(),
              const SizedBox(height: 40),
              _buildFindHelpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 347),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey[400]),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          _buildDiagnosisInfo(),
          const SizedBox(height: 20),
          _buildSelectImageButton(),
          if (_imageFile != null) _buildCapturedImage(),
        ],
      ),
    );
  }

  Widget _buildSelectImageButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : pickImageFromGallery,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B9BDB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              "Select Image from Gallery",
              style: TextStyle(fontSize: 16),
            ),
    );
  }

  Widget _buildCapturedImage() {
    return Column(
      children: [
        const SizedBox(height: 16),
        if (prediction.isNotEmpty) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : () => classifyImage(_imageFile!),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B9BDB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Send for Analysis",
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosisInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shield_outlined, color: Color(0xFF1B9BDB)),
            SizedBox(width: 8),
            Text(
              'AI Diagnosis',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1B9BDB),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          prediction.isEmpty ? "Select image for diagnosis" : prediction,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 8),
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (confidence > 0) _buildConfidenceIndicator(),
      ],
    );
  }

  Widget _buildConfidenceIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(80, 80),
                painter:
                    ConfidenceCirclePainter(confidence: _displayedConfidence),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _confidenceAnimation.value > 0.9
                          ? _pulseAnimation.value
                          : 1.0,
                      child: child,
                    );
                  },
                  child: Text(
                    '${_displayedConfidence.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'AI Confidence',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500),
            ),
            Text(
              'Based on image analysis',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    if (prediction.isEmpty) return const SizedBox();

    // الحصول على النصائح بناءً على نوع المرض
    final advice = diseaseAdvice[prediction] ??
        {
          'Causes': ['Unknown causes for this condition'],
          'Prevention': ['No specific prevention tips available'],
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'About ',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
              TextSpan(
                text: prediction,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B9BDB)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard('Causes', Icons.info_outline, advice['Causes']!),
        const SizedBox(height: 16),
        _buildInfoCard(
            'Prevention', Icons.shield_outlined, advice['Prevention']!),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 4,
            color: Colors.black12,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1B9BDB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                item,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFindHelpButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoogleMapPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B9BDB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: const Text(
        'Find Professional Help',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class ConfidenceCirclePainter extends CustomPainter {
  final double confidence;

  ConfidenceCirclePainter({required this.confidence});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = const Color(0xFFECECEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = const Color(0xFF1B9BDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawCircle(center, radius, circlePaint);

    if (confidence > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * (confidence / 100);

      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ConfidenceCirclePainter oldDelegate) {
    return oldDelegate.confidence != confidence;
  }
}
