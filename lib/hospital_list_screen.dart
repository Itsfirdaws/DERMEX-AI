import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({Key? key}) : super(key: key);

  @override
  _HospitalMapScreenState createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<GoogleMapPage> {
  late GoogleMapController mapController;
  LatLng? _center;
  List<dynamic> hospitals = [];
  bool isLoading = false;
  final Set<Marker> _markers = {};
  bool showHospitals = false;
  final FocusNode _searchFocusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();

  final String apiKey = 'AIzaSyCMGrIYfgUZ7yQ7kt9SOtHBEGwscbBFDUM';
  final Color primaryColor = const Color(0xFF1B9BDB);
  final Color secondaryColor = const Color(0xFF0D8AC7);
  final Color accentColor = const Color(0xFFFF7043);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  // دالة للحصول على الموقع الحالي للمستخدم
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable location services',
              textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App cannot be used without location permission',
              textAlign: TextAlign.center),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(_center!));
    }
  }

  // دالة لجلب المستشفيات القريبة من الموقع الحالي
  Future<void> fetchNearbyHospitals() async {
    if (_center == null) return;

    setState(() {
      isLoading = true;
      showHospitals = true;
    });

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_center!.latitude},${_center!.longitude}&radius=10000&type=hospital&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            hospitals = data['results'];
            _addHospitalMarkers();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          _showError('No nearby hospitals found');
        }
      } else {
        setState(() => isLoading = false);
        _showError('Server connection error');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('An unexpected error occurred');
    }
  }

  // دالة لإضافة علامات المستشفيات على الخريطة
  void _addHospitalMarkers() {
    _markers.clear();
    for (var hospital in hospitals) {
      final lat = hospital['geometry']['location']['lat'];
      final lng = hospital['geometry']['location']['lng'];
      _markers.add(
        Marker(
          markerId: MarkerId(hospital['place_id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: hospital['name'],
            snippet: hospital['vicinity'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  // دالة لعرض رسائل الخطأ
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: Colors.red,
      ),
    );
  }

  // دالة لتحريك الكاميرا إلى موقع معين
  void _moveCameraToPlace(double lat, double lng, String name) {
    final newPos = LatLng(lat, lng);
    mapController.animateCamera(CameraUpdate.newLatLngZoom(newPos, 15));
    setState(() {
      _center = newPos;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: newPos,
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _center == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 20),
                  Text(
                    'Loading current location...',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 14,
                  ),
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: _markers,
                  compassEnabled: true,
                  buildingsEnabled: true,
                ),

                // صندوق البحث - التصميم الجديد
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(
                                  _searchFocusNode.hasFocus ? 0.2 : 0.1),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // أيقونة البحث مع التدرج اللوني
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child:
                              Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GooglePlaceAutoCompleteTextField(
                            textEditingController: _searchController,
                            googleAPIKey: apiKey,
                            focusNode: _searchFocusNode,
                            inputDecoration: InputDecoration(
                              hintText: "Search for a place in Saudi Arabia",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 99, 99, 99),
                                fontSize: 16,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            textStyle: TextStyle(
                              color: const Color.fromARGB(221, 255, 255, 255),
                              fontSize: 16,
                            ),
                            debounceTime: 400,
                            countries: const ["sa"],
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (prediction) {
                              final lat = double.parse(prediction.lat!);
                              final lng = double.parse(prediction.lng!);
                              final name = prediction.description!;
                              _moveCameraToPlace(lat, lng, name);
                              _searchFocusNode.unfocus();
                            },
                            itemClick: (prediction) {
                              _searchController.text = prediction.description!;
                              _searchFocusNode.unfocus();
                            },
                            itemBuilder:
                                (context, index, Prediction prediction) =>
                                    Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on, color: primaryColor),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      prediction.description ?? "",
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              221, 255, 255, 255)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                            },
                            child:
                                Icon(Icons.close, color: Colors.grey, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),

                // زر الموقع الحالي
                Positioned(
                  bottom: 120,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'location',
                    backgroundColor: Colors.white,
                    onPressed: _determinePosition,
                    child: Icon(Icons.my_location, color: primaryColor),
                  ),
                ),

                // زر المستشفيات
                Positioned(
                  bottom: 190,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'hospitals',
                    backgroundColor: primaryColor,
                    onPressed: fetchNearbyHospitals,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Icon(Icons.local_hospital, color: Colors.white),
                  ),
                ),

                // مقبض الورقة المنزلقة من الأسفل
                if (showHospitals)
                  Positioned(
                    bottom: 270,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                // قائمة المستشفيات
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: showHospitals
                      ? 0
                      : -MediaQuery.of(context).size.height * 0.7,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // المقبض القابل للسحب
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),

                        // العنوان
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nearby Hospitals',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => showHospitals = false),
                              ),
                            ],
                          ),
                        ),

                        // القائمة
                        Expanded(
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: primaryColor))
                              : hospitals.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/no_data.svg',
                                            height: 150,
                                            color: Colors.grey[300],
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            'No nearby hospitals',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          TextButton(
                                            onPressed: fetchNearbyHospitals,
                                            child: Text(
                                              'Retry',
                                              style: TextStyle(
                                                  color: primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.only(top: 10),
                                      itemCount: hospitals.length,
                                      itemBuilder: (context, index) {
                                        final hospital = hospitals[index];
                                        return InkWell(
                                          onTap: () {
                                            final lat = hospital['geometry']
                                                ['location']['lat'];
                                            final lng = hospital['geometry']
                                                ['location']['lng'];
                                            _moveCameraToPlace(
                                                lat, lng, hospital['name']);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                    Icons.local_hospital,
                                                    color: primaryColor),
                                              ),
                                              title: Text(
                                                hospital['name'] ??
                                                    'Unknown name',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              subtitle: Text(
                                                hospital['vicinity'] ??
                                                    'Unknown location',
                                                style: TextStyle(
                                                    color: Colors.grey[600]),
                                              ),
                                              trailing: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  if (hospital['rating'] !=
                                                      null)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.star,
                                                            color: Colors.amber,
                                                            size: 18),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          hospital['rating']
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black87),
                                                        ),
                                                      ],
                                                    ),
                                                  if (hospital[
                                                          'opening_hours'] !=
                                                      null)
                                                    Text(
                                                      hospital['opening_hours']
                                                              ['open_now']
                                                          ? 'Open now'
                                                          : 'Closed now',
                                                      style: TextStyle(
                                                        color: hospital[
                                                                    'opening_hours']
                                                                ['open_now']
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                ],
                                              ),
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
    );
  }
}
