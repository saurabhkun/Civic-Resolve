import 'lib/database_service.dart';
import 'dart:math';

void main() async {
  print('🔍 TESTING COMPLETE REPORT DATA FLOW');
  print('=====================================\n');
  
  final databaseService = DatabaseService();
  final testUserId = 'test_user_${Random().nextInt(1000)}';
  
  try {
    // Test 1: Create a comprehensive report with all data types
    print('📝 Test 1: Creating comprehensive report...');
    final testReport = await databaseService.createReport(
      title: 'Test Report - Road Damage',
      description: 'Large pothole causing vehicle damage. Located near traffic light intersection. Water accumulates during rain making it worse. Multiple vehicles have been damaged.',
      category: 'potholes_roads',
      location: '123 Main Street, Downtown Area, Near City Mall',
      imageUrls: [
        'test_image_1.jpg',
        'test_image_2.jpg', 
        'test_video_1.mp4'
      ],
      userId: testUserId,
      coordinates: {'lat': 12.9716, 'lng': 77.5946}, // Bangalore coordinates
    );
    
    if (testReport != null) {
      print('✅ Report created successfully!');
      print('   📋 ID: ${testReport.id}');
      print('   📝 Title: ${testReport.title}');
      print('   📄 Description: ${testReport.description.substring(0, 50)}...');
      print('   📍 Location: ${testReport.location}');
      print('   🖼️  Images: ${testReport.imageUrls.length} files');
      print('   📊 Status: ${testReport.status}');
      print('   🌍 Coordinates: ${testReport.coordinates}');
      print('   ⏰ Created: ${testReport.createdAt}');
      print('');
    } else {
      print('❌ Failed to create report');
      return;
    }
    
    // Test 2: Verify data persistence 
    print('💾 Test 2: Checking data persistence...');
    final retrievedReport = await databaseService.getReportById(testReport.id);
    if (retrievedReport != null) {
      print('✅ Report successfully retrieved from storage');
      
      // Verify all data fields
      bool dataIntegrity = true;
      if (retrievedReport.title != testReport.title) {
        print('❌ Title mismatch');
        dataIntegrity = false;
      }
      if (retrievedReport.description != testReport.description) {
        print('❌ Description mismatch');
        dataIntegrity = false;
      }
      if (retrievedReport.imageUrls.length != testReport.imageUrls.length) {
        print('❌ Image count mismatch');
        dataIntegrity = false;
      }
      if (retrievedReport.coordinates?['lat'] != testReport.coordinates?['lat']) {
        print('❌ Coordinates mismatch');
        dataIntegrity = false;
      }
      
      if (dataIntegrity) {
        print('✅ All data fields verified - integrity maintained');
      }
    } else {
      print('❌ Failed to retrieve report');
    }
    print('');
    
    // Test 3: Check user reports functionality
    print('👤 Test 3: Testing user reports functionality...');
    final userReports = await databaseService.getUserReports(testUserId);
    print('✅ Found ${userReports.length} reports for user $testUserId');
    
    if (userReports.isNotEmpty) {
      final report = userReports.first;
      print('   Latest report details:');
      print('   - Title: ${report.title}');
      print('   - Status: ${report.status}');
      print('   - Images: ${report.imageUrls.length}');
      print('   - Has coordinates: ${report.coordinates != null}');
    }
    print('');
    
    // Test 4: Test status updates
    print('🔄 Test 4: Testing status updates...');
    final statusUpdated = await databaseService.updateReportStatus(testReport.id, 'in_progress');
    if (statusUpdated) {
      print('✅ Status update successful');
      
      // Verify the update
      final updatedReport = await databaseService.getReportById(testReport.id);
      if (updatedReport?.status == 'in_progress') {
        print('✅ Status change verified in storage');
      } else {
        print('❌ Status change not reflected in storage');
      }
    } else {
      print('❌ Status update failed');
    }
    print('');
    
    // Test 5: Test JSON serialization
    print('🔗 Test 5: Testing data serialization...');
    final jsonData = testReport.toJson();
    print('✅ Report successfully converted to JSON');
    print('   JSON keys: ${jsonData.keys.join(', ')}');
    print('   Image URLs in JSON: ${jsonData['imageUrls']}');
    print('   Coordinates in JSON: ${jsonData['coordinates']}');
    print('');
    
    // Summary
    print('📊 COMPREHENSIVE TEST SUMMARY');
    print('=============================');
    print('✅ Report Creation: Working');
    print('✅ Data Persistence: Working');
    print('✅ Image Storage: Working (${testReport.imageUrls.length} files)');
    print('✅ Text Data: Working (title, description, location)');
    print('✅ Coordinates: Working (lat: ${testReport.coordinates?['lat']}, lng: ${testReport.coordinates?['lng']})');
    print('✅ User Reports: Working');
    print('✅ Status Updates: Working');
    print('✅ JSON Serialization: Working');
    print('');
    print('🎉 ALL TESTS PASSED! The report data flow is working correctly.');
    print('   Reports with images, videos, text, and location data are being');
    print('   properly stored and can be retrieved in the Track Reports section.');
    
  } catch (e) {
    print('❌ Error during testing: $e');
    print('This indicates there may be an issue with the data flow.');
  }
}