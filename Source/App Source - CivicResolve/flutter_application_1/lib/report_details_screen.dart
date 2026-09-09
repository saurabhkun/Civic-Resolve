import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'language_service.dart';
import 'category_selection_screen.dart';
import 'confirmation_screen.dart';
import 'image_analysis_service.dart';
import 'python_disaster_classifier.dart';

import 'leaflet_map_service.dart';

class ReportDetailsScreen extends StatefulWidget {
  final ReportCategory category;
  
  const ReportDetailsScreen({super.key, required this.category});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final LanguageService _languageService = LanguageService();
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<File> selectedImages = [];
  String? currentLocation;
  double? currentLatitude;
  double? currentLongitude;
  bool isLoadingLocation = false;
  bool showMap = false;
  
  // AI Priority Detection
  String selectedPriority = 'Medium';
  bool isAnalyzingImage = false;
  String? aiAnalysisResult;
  
  // WebView controller for Leaflet map (mobile/desktop)
  WebViewController? _webViewController;
  // Default coordinates for Solapur, Maharashtra, India
  static const double _defaultLatitude = 17.68687;
  static const double _defaultLongitude = 75.92275;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    
    // Add listener to description field for real-time AI analysis
    _descriptionController.addListener(_onDescriptionChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    _addressController.dispose();
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// Analyzes description text in real-time for priority keywords
  void _onDescriptionChanged() {
    final description = _descriptionController.text.trim();
    if (description.length > 15) { // Only analyze if description has meaningful content
      _analyzeDescriptionOnly(description);
    }
  }

  /// Analyzes only the description text for priority keywords
  void _analyzeDescriptionOnly(String description) {
    final analysis = ImageAnalysisService.analyzeDescriptionForPriority(description);
    final detectedPriority = analysis['priority'] ?? 'Medium';
    final keywords = analysis['keywords'] ?? '';
    
    // Only update priority if we detect high priority keywords
    if (detectedPriority == 'High' && keywords.isNotEmpty) {
      setState(() {
        selectedPriority = detectedPriority;
        aiAnalysisResult = 'AI detected emergency/disaster keywords in description: $keywords. ${analysis['explanation']}';
      });
      
      // Show notification about automatic priority change
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('High priority detected from description keywords: $keywords'),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Details',
            textColor: Colors.white,
            onPressed: () => _showAIAnalysisDialog(),
          ),
        ),
      );
    }
  }

  void _onLanguageChanged() {
    setState(() {});
  }



  void _initializeMap() {
    // Initialize the map with default coordinates
    setState(() {
      currentLatitude = _defaultLatitude;
      currentLongitude = _defaultLongitude;
      showMap = true;
    });
  }

  Future<void> _getCurrentLocationSafely() async {
    setState(() {
      isLoadingLocation = true;
    });
    
    try {
      print('🔄 Starting location detection...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Location services are disabled. Please enable them in your device settings.')),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        throw Exception('Location services are disabled.');
      }

      print('✅ Getting current position...');
      
      // Get the current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      
      print('📍 Position obtained: ${position.latitude}, ${position.longitude}');
      print('🔄 Getting address from coordinates...');
      
      // Get real address from coordinates
      final address = await _reverseGeocode(position.latitude, position.longitude);
      print('🏠 Address resolved: $address');
      
      setState(() {
        currentLocation = address;
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
        if (_addressController.text.isEmpty) {
          _addressController.text = address;
        }
        isLoadingLocation = false;
      });

      // Update web map location
      if (_webViewController != null) {
        await _updateMapLocation(position.latitude, position.longitude);
      }

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location detected successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Location detection failed: $e');
      
      // Fallback to default location (Solapur)
      const mockLatitude = _defaultLatitude;
      const mockLongitude = _defaultLongitude;
      final mockAddress = await _reverseGeocode(mockLatitude, mockLongitude);
      
      setState(() {
        currentLatitude = mockLatitude;
        currentLongitude = mockLongitude;
        currentLocation = mockAddress;
        if (_addressController.text.isEmpty) {
          _addressController.text = mockAddress;
        }
        isLoadingLocation = false;
      });
      
      // Update web map with fallback location
      if (_webViewController != null) {
        await _updateMapLocation(mockLatitude, mockLongitude);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Could not get precise location: ${e.toString()}. Using approximate location for demo.')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      // Use real reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build a comprehensive address string
        String address = '';
        
        // Add street number and name
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        
        // Add locality/neighborhood
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        
        // Add administrative area (state/province)
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        
        // Add country
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }
        
        // Add postal code if available
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          address += ' ' + place.postalCode!;
        }
        
        // Return the formatted address or fallback
        return address.isNotEmpty ? address : _getFallbackAddress(lat, lng);
      }
    } catch (e) {
      print('Reverse geocoding error: $e');
    }
    
    // Fallback to coordinate-based address
    return _getFallbackAddress(lat, lng);
  }
  
  String _getFallbackAddress(double lat, double lng) {
    // Generate a realistic mock address based on coordinates for fallback
    final streetNumbers = [123, 456, 789, 101, 234, 567];
    final streetNames = ['Main Street', 'Oak Avenue', 'Pine Road', 'Elm Drive', 'Maple Lane', 'Cedar Boulevard'];
    final neighborhoods = ['Downtown', 'City Center', 'Riverside', 'Hillcrest', 'Parkview', 'Lakeside'];
    
    final streetNumber = streetNumbers[DateTime.now().millisecond % streetNumbers.length];
    final streetName = streetNames[DateTime.now().second % streetNames.length];
    final neighborhood = neighborhoods[DateTime.now().minute % neighborhoods.length];
    
    return '$streetNumber $streetName, $neighborhood, Your City';
  }

  // WebView-based map methods
  Future<void> _updateMapLocation(double latitude, double longitude) async {
    if (_webViewController != null) {
      await _webViewController!.runJavaScript(
        'updateLocation($latitude, $longitude);'
      );
    }
  }

  Future<void> _setLocationLoading(bool loading) async {
    if (_webViewController != null) {
      await _webViewController!.runJavaScript(
        'setLocationLoading($loading);'
      );
    }
  }

  void _onLocationChangedFromMap(double latitude, double longitude) async {
    setState(() {
      currentLatitude = latitude;
      currentLongitude = longitude;
    });

    // Update address based on coordinates
    try {
      final address = await _reverseGeocode(latitude, longitude);
      if (_addressController.text.isEmpty) {
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      print('Failed to get address: $e');
    }
  }

  Future<void> _handleLocationRequest() async {
    await _setLocationLoading(true);
    await _getCurrentLocationSafely();
    await _setLocationLoading(false);
  }

  Widget _buildImageTile(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Platform-specific image display
            kIsWeb 
              ? Image.network(
                  selectedImages[index].path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    );
                  },
                )
              : Image.file(
                  selectedImages[index],
                  fit: BoxFit.cover,
                ),
            
            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            
            // Remove button
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            
            // Image number indicator
            Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isEnabled ? color.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? color.withValues(alpha: 0.3) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled ? color : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? color : Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Image removed'),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openLocationSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationSearchSheet(),
    );
  }

  Widget _buildInteractiveMap() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 300,
          child: kIsWeb ? _buildWebMap() : _buildMobileMap(),
        ),
      ),
    );
  }

  Widget _buildMobileMap() {
    // For mobile/desktop platforms, use WebView
    return WebViewWidget(
      controller: _getWebViewController(),
    );
  }

  Widget _buildWebMap() {
    // For web platform, show a placeholder with instructions
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Colors.blue[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive Map',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Location: ${currentLatitude?.toStringAsFixed(6) ?? _defaultLatitude.toStringAsFixed(6)}, ${currentLongitude?.toStringAsFixed(6) ?? _defaultLongitude.toStringAsFixed(6)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _getCurrentLocationSafely,
            icon: const Icon(Icons.my_location, size: 20),
            label: const Text('Get Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  WebViewController _getWebViewController() {
    if (_webViewController == null) {
      final double lat = currentLatitude ?? _defaultLatitude;
      final double lng = currentLongitude ?? _defaultLongitude;
      
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'onLocationChanged',
          onMessageReceived: (JavaScriptMessage message) {
            try {
              final data = message.message;
              // Parse the coordinate data from JavaScript
              final regex = RegExp(r'latitude:(\d+\.\d+),longitude:(\d+\.\d+)');
              final match = regex.firstMatch(data);
              if (match != null) {
                final lat = double.parse(match.group(1)!);
                final lng = double.parse(match.group(2)!);
                _onLocationChangedFromMap(lat, lng);
              }
            } catch (e) {
              print('Error parsing location data: $e');
            }
          },
        )
        ..addJavaScriptChannel(
          'requestLocation',
          onMessageReceived: (JavaScriptMessage message) {
            _handleLocationRequest();
          },
        )
        ..loadHtmlString(
          LeafletMapService.getMapHTML(
            latitude: lat,
            longitude: lng,
          ),
        );
    }
    return _webViewController!;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Maximum 5 images allowed'),
            ],
          ),
          backgroundColor: Colors.orange[600],
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        final newImage = File(pickedFile.path);
        setState(() {
          selectedImages.add(newImage);
        });
        
        // Analyze image with AI for priority detection
        _analyzeImageForPriority(newImage);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Image added successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to pick image: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Analyzes uploaded image and description using AI and updates priority automatically
  Future<void> _analyzeImageForPriority(File imageFile) async {
    if (!mounted) return;

    setState(() {
      isAnalyzingImage = true;
      aiAnalysisResult = null;
    });

    try {
      // Show analysis started message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('🤖 AI analyzing image with dual classification...'),
            ],
          ),
          backgroundColor: Colors.blue[700],
          duration: const Duration(seconds: 4),
        ),
      );

      // Get current description text for analysis
      final currentDescription = _descriptionController.text.trim();

      String detectedPriority = 'Medium';
      String explanation = 'Analysis in progress...';
      
      // Try Python classifier first (enhanced analysis)
      try {
        final pythonResult = await PythonDisasterClassifier.enhancedClassification(imageFile.path);
        
        if (pythonResult['success'] == true) {
          detectedPriority = pythonResult['final_priority'] ?? pythonResult['priority'] ?? 'Medium';
          explanation = 'Python AI Analysis: ${pythonResult['priority']}';
          
          if (pythonResult['priority_override'] != null) {
            explanation += '\n${pythonResult['priority_override']}';
          }
          
          if (pythonResult['error'] != null) {
            explanation += '\nNote: ${pythonResult['error']}';
          }
          
          print('🐍 Python Classification Success: $detectedPriority');
        } else {
          throw Exception('Python classifier failed: ${pythonResult['error']}');
        }
      } catch (pythonError) {
        print('⚠️ Python classifier failed, falling back to Flutter AI: $pythonError');
        
        // Fallback to original Flutter AI analysis
        detectedPriority = await ImageAnalysisService.analyzeImageForPriority(
          imageFile, 
          description: currentDescription.isNotEmpty ? currentDescription : null
        );
        explanation = '${ImageAnalysisService.getPriorityExplanation(detectedPriority)}\n\nNote: Used Flutter AI (Python classifier unavailable)';
      }

      if (mounted) {
        setState(() {
          selectedPriority = detectedPriority;
          aiAnalysisResult = explanation;
          isAnalyzingImage = false;
        });

        // Show AI analysis result with enhanced messaging
        String analysisMessage = '🎯 AI Priority: $detectedPriority';
        if (currentDescription.isNotEmpty) {
          analysisMessage += ' (Image + Description Analysis)';
        } else {
          analysisMessage += ' (Image Analysis Only)';
        }

        // Add special messaging for high priority disasters
        if (detectedPriority == 'High') {
          analysisMessage = '🚨 DISASTER DETECTED! Priority: HIGH';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  detectedPriority == 'High' ? Icons.warning_amber_rounded : Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(analysisMessage),
                ),
              ],
            ),
            backgroundColor: ImageAnalysisService.getPriorityColor(detectedPriority),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () => _showAIAnalysisDialog(),
            ),
          ),
        );

        // If high priority detected, show additional warning
        if (detectedPriority == 'High') {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
                  title: const Text('🚨 DISASTER DETECTED'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'AI has detected potential disaster or emergency conditions in your report.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          aiAnalysisResult ?? 'High priority emergency detected.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This report will be marked as HIGH PRIORITY for immediate attention.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Understood'),
                    ),
                  ],
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isAnalyzingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI analysis failed: ${e.toString()}'),
                const SizedBox(height: 4),
                const Text(
                  'Tip: Add disaster keywords in description for automatic priority detection',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Shows detailed AI analysis results
  void _showAIAnalysisDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.smart_toy_rounded,
              color: ImageAnalysisService.getPriorityColor(selectedPriority),
            ),
            const SizedBox(width: 8),
            const Text('AI Analysis Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Detected Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ImageAnalysisService.getPriorityColor(selectedPriority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ImageAnalysisService.getPriorityColor(selectedPriority).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    selectedPriority,
                    style: TextStyle(
                      color: ImageAnalysisService.getPriorityColor(selectedPriority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(aiAnalysisResult ?? 'No analysis details available.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Builds a priority selection option widget
  Widget _buildPriorityOption(String priority, String description, IconData icon, Color color) {
    final isSelected = selectedPriority == priority;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              priority,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitReport() {
    if (_formKey.currentState!.validate()) {
      if (selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Please add at least one image as proof'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (currentLatitude == null || currentLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Please select a location on the map'),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Use the precise address from the address controller
      String finalLocation = _addressController.text.trim();
      if (finalLocation.isEmpty) {
        finalLocation = currentLocation ?? 'Location coordinates: ${currentLatitude!.toStringAsFixed(6)}, ${currentLongitude!.toStringAsFixed(6)}';
      }

      // Navigate to confirmation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            category: widget.category,
            description: _descriptionController.text,
            images: selectedImages,
            location: finalLocation,
            latitude: currentLatitude,
            longitude: currentLongitude,
            priority: selectedPriority,
            aiAnalysisResult: aiAnalysisResult,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Step 2: Provide Details',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Category Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.category.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.category.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.category.icon,
                              color: widget.category.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reporting in category:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                widget.category.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: widget.category.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description Field
                    const Text(
                      'Brief Description *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue in detail. What exactly is the problem? When did you notice it? Any additional context that might help...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide a description of the issue';
                        }
                        if (value.trim().length < 10) {
                          return 'Please provide a more detailed description (at least 10 characters)';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Image Upload Section
                    const Text(
                      'Image/Video Proof * (Required)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Image Upload Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              children: [
                                Icon(
                                  Icons.photo_camera_rounded,
                                  color: const Color(0xFF3B82F6),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Upload Evidence',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: selectedImages.length >= 5 
                                        ? Colors.red[50] 
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${selectedImages.length}/5',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selectedImages.length >= 5 
                                          ? Colors.red[700] 
                                          : Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Image Grid
                            if (selectedImages.isNotEmpty) ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: selectedImages.length,
                                itemBuilder: (context, index) {
                                  return _buildImageTile(index);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Add Image Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAddImageButton(
                                    icon: Icons.camera_alt_rounded,
                                    label: 'Camera',
                                    color: const Color(0xFF3B82F6),
                                    onTap: selectedImages.length < 5 
                                        ? () => _pickImage(ImageSource.camera)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildAddImageButton(
                                    icon: Icons.photo_library_rounded,
                                    label: 'Gallery',
                                    color: const Color(0xFF10B981),
                                    onTap: selectedImages.length < 5 
                                        ? () => _pickImage(ImageSource.gallery)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Upload Instructions
                            if (selectedImages.isEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Add clear photos showing the problem. Multiple angles help us understand the issue better.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Priority Section with AI Integration
                    const Text(
                      'Priority Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // AI Analysis Status
                            if (isAnalyzingImage) ...[
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI analyzing uploaded image...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // AI Analysis Result
                            if (aiAnalysisResult != null && !isAnalyzingImage) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ImageAnalysisService.getPriorityColor(selectedPriority).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: ImageAnalysisService.getPriorityColor(selectedPriority).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.smart_toy_rounded,
                                      color: ImageAnalysisService.getPriorityColor(selectedPriority),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'AI Priority Detection: $selectedPriority',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: ImageAnalysisService.getPriorityColor(selectedPriority),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            aiAnalysisResult!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _showAIAnalysisDialog(),
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: ImageAnalysisService.getPriorityColor(selectedPriority),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Manual Priority Selection
                            const Text(
                              'Select Priority:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPriorityOption('High', 'Immediate attention required', Icons.priority_high, const Color(0xFFEF4444)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPriorityOption('Medium', 'Needs timely action', Icons.remove, const Color(0xFFF59E0B)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPriorityOption('Low', 'Can be addressed later', Icons.low_priority, const Color(0xFF10B981)),
                                ),
                              ],
                            ),
                            
                            if (selectedImages.isEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Upload an image for AI-powered priority detection',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location Section
                    const Text(
                      'Location *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Interactive Map Section
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // Map Interface
                            _buildInteractiveMap(),
                            
                            // Map Controls Overlay
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _openLocationSearch,
                                  icon: const Icon(Icons.search, size: 20),
                                  color: const Color(0xFF3B82F6),
                                  tooltip: 'Search Location',
                                ),
                              ),
                            ),
                            
                            // Center Location Pin
                            const Center(
                              child: Icon(
                                Icons.location_pin,
                                color: Color(0xFF3B82F6),
                                size: 36,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Location Status Banner
                            if (currentLatitude != null && currentLongitude != null)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[600]!.withValues(alpha: 0.9),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Location: ${currentLatitude!.toStringAsFixed(4)}, ${currentLongitude!.toStringAsFixed(4)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address Section
                    const Text(
                      'Problem Address *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Enter the specific address where the problem is located...\nExample: 123 Main Street, Near City Mall, Cityville',
                          prefixIcon: Icon(Icons.home_rounded, color: Color(0xFF3B82F6)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide the address where the problem is located';
                          }
                          if (value.trim().length < 10) {
                            return 'Please provide a more detailed address';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    // Address Helper Info
                    if (currentLatitude == null || currentLongitude == null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap on the map to pinpoint the exact location, then provide the detailed address.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSearchSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search for a location...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF3B82F6)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      // In a real app, implement location search
                    },
                  ),
                ),
              ),
              
              // Google Maps
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 300,
                      child: _buildInteractiveMap(),
                    ),
                  ),
                ),
              ),
              
              // Quick Location Options
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: currentLatitude != null 
                                ? () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Location confirmed!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Confirm Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
      },
    );
  }
}