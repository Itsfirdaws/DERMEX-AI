import 'dart:io';

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile.dart';
import 'settings_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _diagnosisHistory = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDiagnosisHistory();
  }

  Future<void> _loadDiagnosisHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('diagnosis_history') ?? [];

    setState(() {
      _diagnosisHistory = history.map((entry) {
        final data = json.decode(entry);
        return {
          'diagnosis': data['diagnosis'],
          'confidence': data['confidence'],
          'date': data['date'],
          'imagePath': data['imagePath'],
          'timestamp': data['timestamp'],
        };
      }).toList();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_searchQuery.isEmpty) {
      return _diagnosisHistory;
    }
    return _diagnosisHistory.where((entry) {
      final diagnosis = entry['diagnosis'].toString().toLowerCase();
      final date = entry['date'].toString().toLowerCase();
      return diagnosis.contains(_searchQuery.toLowerCase()) ||
          date.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Text(
                        'History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const Spacer(),
                      if (_diagnosisHistory.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmClearHistory(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Search Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search By Diagnosis or Date',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_filteredHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No diagnosis history yet'
                          : 'No results found',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ..._filteredHistory.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildHistoryCard(entry),
                      )),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const DotNavBar(),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final severity = entry['confidence'] > 70
        ? 'Immediate medical care required'
        : entry['confidence'] > 40
            ? 'Consult a doctor if symptoms persist'
            : 'Monitor condition';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: entry['imagePath'] != null
                ? Image.file(
                    File(entry['imagePath']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      entry['date'] ?? 'Unknown date',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry['confidence']?.toStringAsFixed(1) ?? '0'}%',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  entry['diagnosis'] ?? 'Unknown diagnosis',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 21),
                Row(
                  children: [
                    Icon(Icons.warning,
                        size: 16,
                        color: entry['confidence'] > 70
                            ? Colors.red
                            : const Color(0xFF4B5563)),
                    const SizedBox(width: 8),
                    Text(
                      severity,
                      style: TextStyle(
                        color: entry['confidence'] > 70
                            ? Colors.red
                            : const Color(0xFF4B5563),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all diagnosis history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('diagnosis_history');
      setState(() {
        _diagnosisHistory = [];
      });
    }
  }
}

class DotNavBar extends StatefulWidget {
  const DotNavBar({Key? key}) : super(key: key);

  @override
  _DotNavBarState createState() => _DotNavBarState();
}

class _DotNavBarState extends State<DotNavBar> {
  var _selectedTab = _SelectedTab.history;

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });

    switch (_selectedTab) {
      case _SelectedTab.home:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case _SelectedTab.history:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
        break;
      case _SelectedTab.settings:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
      case _SelectedTab.profile:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DotNavigationBar(
      currentIndex: _SelectedTab.values.indexOf(_selectedTab),
      onTap: _handleIndexChanged,
      dotIndicatorColor: Colors.black,
      marginR: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      paddingR: const EdgeInsets.only(bottom: 5, top: 5),
      borderRadius: 50,
      backgroundColor: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 2),
        )
      ],
      items: [
        DotNavigationBarItem(
          icon: const Icon(Icons.home),
          selectedColor: Colors.blue,
        ),
        DotNavigationBarItem(
          icon: const Icon(Icons.history),
          selectedColor: Colors.blue,
        ),
        DotNavigationBarItem(
          icon: const Icon(Icons.settings),
          selectedColor: Colors.blue,
        ),
        DotNavigationBarItem(
          icon: const Icon(Icons.person),
          selectedColor: Colors.blue,
        ),
      ],
      itemPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}

enum _SelectedTab { home, history, settings, profile }