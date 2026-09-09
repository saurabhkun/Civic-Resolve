import 'lib/database_service.dart';

void main() async {
  print('Testing Database Service...');
  
  final databaseService = DatabaseService();
  
  try {
    // Test creating a report
    print('Creating a test report...');
    final report = await databaseService.createReport(
      title: 'Test Report',
      description: 'This is a test report to verify database connectivity',
      category: 'test',
      location: 'Test Location',
      imageUrls: [],
      userId: 'test_user_123',
      coordinates: {'lat': 12.9716, 'lng': 77.5946}, // Bangalore coordinates
    );
    
    if (report != null) {
      print('✅ Report created successfully!');
      print('Report ID: ${report.id}');
      print('Title: ${report.title}');
      print('Status: ${report.status}');
      print('Created At: ${report.createdAt}');
      
      // Test getting user reports
      print('\nFetching user reports...');
      final userReports = await databaseService.getUserReports('test_user_123');
      print('✅ Found ${userReports.length} reports for user');
      
      // Test updating report status
      print('\nUpdating report status...');
      final updated = await databaseService.updateReportStatus(report.id, 'in_progress');
      if (updated) {
        print('✅ Report status updated successfully');
      } else {
        print('❌ Failed to update report status');
      }
      
    } else {
      print('❌ Failed to create report');
    }
    
  } catch (e) {
    print('❌ Error testing database service: $e');
    print('This is expected if MongoDB is not accessible. The app will fallback to local storage.');
  }
  
  print('\nDatabase service test completed.');
}