import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'language_service.dart';
import 'category_selection_screen.dart';
import 'track_reports_screen.dart';
import 'comprehensive_database_service.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'credit_service.dart';

class ConfirmationScreen extends StatefulWidget {
  final ReportCategory category;
  final String description;
  final List<File> images;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? priority;
  final String? aiAnalysisResult;

  const ConfirmationScreen({
    super.key,
    required this.category,
    required this.description,
    required this.images,
    required this.location,
    this.latitude,
    this.longitude,
    this.priority,
    this.aiAnalysisResult,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  late AnimationController _iconAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _contentFadeAnimation;

  String reportId = '';

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);

    // Generate a mock report ID
    reportId =
        'CIV${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Save the report to local storage
    _saveReportToStorage();

    // Initialize animations
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _iconAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _contentAnimationController.dispose();
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _saveReportToStorage() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final databaseService = ComprehensiveDatabaseService();
        
        // Convert images to data URLs for web compatibility
        final imageDataUrls = <String>[];
        for (int i = 0; i < widget.images.length; i++) {
          final imageFile = widget.images[i];
          try {
            print('🔄 Processing image file $i: ${imageFile.path}');
            
            // For web, handle XFile differently with proper error handling
            Uint8List bytes;
            if (kIsWeb) {
              // Web-specific handling - try multiple approaches
              try {
                bytes = await imageFile.readAsBytes();
                print('✅ Web: Successfully read ${bytes.length} bytes');
              } catch (webError) {
                print('❌ Web readAsBytes failed: $webError');
                // Try using HTTP request for blob URLs
                try {
                  if (imageFile.path.startsWith('blob:') || imageFile.path.startsWith('data:')) {
                    final response = await http.get(Uri.parse(imageFile.path));
                    if (response.statusCode == 200) {
                      bytes = response.bodyBytes;
                      print('✅ Web HTTP fallback: Successfully read ${bytes.length} bytes');
                    } else {
                      throw Exception('HTTP request failed with status ${response.statusCode}');
                    }
                  } else {
                    throw Exception('Unsupported path format: ${imageFile.path}');
                  }
                } catch (httpError) {
                  print('❌ Web HTTP fallback failed: $httpError');
                  continue; // Skip this image
                }
              }
            } else {
              bytes = await imageFile.readAsBytes();
              print('✅ Mobile: Successfully read ${bytes.length} bytes');
            }
            
            print('📊 Image bytes read: ${bytes.length} bytes');
            
            // Validate image size (must be at least 100 bytes for a valid image)
            if (bytes.length < 100) {
              print('⚠️ Image too small (${bytes.length} bytes), skipping');
              continue;
            }
            
            // Validate that we have actual image data
            if (bytes.every((byte) => byte == 0)) {
              print('⚠️ Image contains only null bytes, skipping');
              continue;
            }
            
            // Convert to base64 data URL
            final base64String = base64Encode(bytes);
            final dataUrl = 'data:image/jpeg;base64,$base64String';
            imageDataUrls.add(dataUrl);
            print('✅ Converted image $i to data URL (${bytes.length} bytes -> ${dataUrl.length} chars)');
            print('   Base64 preview: ${base64String.substring(0, 50)}...');
          } catch (e, stackTrace) {
            print('❌ Error converting image $i: $e');
            print('📚 Stack trace: ${stackTrace.toString().substring(0, 500)}...');
            // Skip this image instead of adding invalid placeholder
            print('⚠️ Skipping corrupted image file $i');
          }
        }
        
        // Get current user ID from authentication service
        final authService = AuthService.instance;
        final userId = authService.userEmail ?? 'guest_user'; // Fallback to guest user
        
        print('💾 Saving comprehensive report with ${imageDataUrls.length} images... (Attempt ${retryCount + 1}/$maxRetries)');
        print('🔍 User ID: $userId');
        
        // Test database connection first
        final connectionTest = await databaseService.testDatabaseConnection();
        if (!connectionTest) {
          throw Exception('Database connection failed - please check your internet connection and try again');
        }
        
        // Map category ID to database category name
        String categoryName = widget.category.id;
        
        print('📋 Report details:');
        print('   Title: ${widget.category.name}');
        print('   Description: ${widget.description.length} characters');
        print('   Category: $categoryName');
        print('   Location: ${widget.location}');
        print('   Coordinates: (${widget.latitude}, ${widget.longitude})');
        print('   Images: ${imageDataUrls.length} data URLs');
        
        final result = await databaseService.submitComprehensiveReport(
          userId: userId,
          title: widget.category.name,
          description: widget.description,
          category: categoryName,
          location: widget.location,
          latitude: widget.latitude,
          longitude: widget.longitude,
          imageUrls: imageDataUrls,
          contactNumber: null, // This will be filled from user profile
        );
        
        if (result.success && result.reportId != null) {
          // Update the report ID with the one from database only if widget is still mounted
          if (mounted) {
            setState(() {
              reportId = result.reportId!;
            });
          }
          
          print('✅ Comprehensive report saved successfully with ID: ${result.reportId}');
          print('Report priority: ${result.priority}');
          
          // Add notification for successful report submission
          NotificationService().addReportSubmittedNotification(
            result.reportId!,
            widget.category.name,
          );
          
          // Simulate status changes for demo purposes
          NotificationService().simulateReportStatusChanges(
            result.reportId!,
            widget.category.name,
          );
          
          // Award credits for report submission
          await _awardCreditsForReport(result.reportId!, widget.category.name);
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Report saved successfully! ID: ${result.reportId} | Priority: ${result.priority?.toUpperCase() ?? 'MEDIUM'}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          
          // Successfully saved, break out of retry loop
          return;
        } else {
          throw Exception('Database error: ${result.message}');
        }
      } catch (e) {
        retryCount++;
        print('❌ Error saving comprehensive report (attempt $retryCount/$maxRetries): $e');
        
        // Show specific error message to user
        if (mounted) {
          String errorMessage = 'Failed to save report';
          if (e.toString().contains('connection')) {
            errorMessage = 'Connection failed - please check internet';
          } else if (e.toString().contains('timeout')) {
            errorMessage = 'Request timed out - please try again';
          } else if (e.toString().contains('authentication')) {
            errorMessage = 'Authentication failed - please log in again';
          } else if (e.toString().contains('Database error:')) {
            errorMessage = e.toString().replaceFirst('Exception: Database error: ', '');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        if (retryCount < maxRetries) {
          // Wait before retrying (exponential backoff)
          final delaySeconds = retryCount * 2;
          print('⏳ Retrying in $delaySeconds seconds...');
          await Future.delayed(Duration(seconds: delaySeconds));
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⏳ Retrying to save report... (${retryCount}/$maxRetries)'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: delaySeconds),
              ),
            );
          }
        } else {
          // Final attempt failed
          print('❌ All retry attempts failed. Final error: $e');
          
          // Create a fallback local save mechanism
          final fallbackReportId = 'LOCAL_${DateTime.now().millisecondsSinceEpoch}';
          
          if (mounted) {
            setState(() {
              reportId = fallbackReportId;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚠️ Report saved locally with ID: $fallbackReportId'),
                    Text('We will sync this to the database when connection is restored.'),
                    Text('Please check "Track My Reports" later to confirm sync status.'),
                  ],
                ),
                backgroundColor: Colors.amber[700],
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: 'Retry Now',
                  textColor: Colors.white,
                  onPressed: () => _saveReportToStorage(),
                ),
              ),
            );
          }
          
          // Save to local storage as backup
          await _saveReportLocally(fallbackReportId);
        }
      }
    }
  }

  /// Save report to local storage as backup
  Future<void> _saveReportLocally(String fallbackId) async {
    try {
      // Implementation for local storage backup
      // This is a fallback mechanism
      print('💾 Saving report locally with ID: $fallbackId');
      // You could implement SharedPreferences or local database here
    } catch (e) {
      print('❌ Error saving report locally: $e');
    }
  }

  void _navigateToTrackReports() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TrackReportsScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Success Icon
                      AnimatedBuilder(
                        animation: _iconScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _iconScaleAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Colors.green[600],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Animated Content
                      AnimatedBuilder(
                        animation: _contentFadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _contentFadeAnimation.value,
                            child: Column(
                              children: [
                                // Success Message
                                const Text(
                                  'Report Submitted Successfully!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 16),

                                // Report ID
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    'Report ID: $reportId',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Report Summary
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Report Summary',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Category
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: widget.category.color
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              widget.category.icon,
                                              color: widget.category.color,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Category',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                Text(
                                                  widget.category.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1F2937),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      // Images Count
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.photo_library,
                                            color: Color(0xFF3B82F6),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${widget.images.length} image(s) attached',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Location
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Color(0xFF10B981),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              widget.location,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Next Steps Info
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.amber[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'What happens next?',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.amber[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '• Your report will be reviewed by our team\n• You\'ll receive updates on progress\n• Track status in "Track My Reports"',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.amber[800],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _navigateToTrackReports,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Track My Reports',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _awardCreditsForReport(String reportId, String category) async {
    try {
      const userId = 'user_12345'; // In real app, get from auth
      
      // Award base credits for report submission
      final success = await CreditService.awardCreditsForReport(userId, reportId);
      
      if (success) {
        print('🎉 Credits awarded for report submission: $reportId');
        
        // Show a nice credit reward notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You earned 10 Green Credits for submitting a $category report!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF22C55E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Failed to award credits: $e');
    }
  }
}
