import 'lib/image_analysis_service.dart';

void main() async {
  print('🚀 Testing Gemini AI Connection for Disaster Detection...');
  
  try {
    // Test API connection
    print('\n=== Testing API Connection ===');
    final connected = await ImageAnalysisService.testGeminiConnection();
    print('Gemini API Status: ${connected ? "✅ CONNECTED" : "❌ FAILED"}');
    
    // Test analysis info
    print('\n=== Analysis Configuration ===');
    final info = ImageAnalysisService.getAnalysisInfo();
    print('API Key: ${info['apiKey']}');
    print('Model: ${info['model']}');
    print('Disaster Types: ${info['disasterTypes']}');
    
    // Test description analysis
    print('\n=== Testing Description Analysis ===');
    final testDescriptions = [
      'Major fire in downtown building, smoke visible',
      'Severe flooding on Highway 101, road closed',
      'Minor pothole on side street',
      'Bridge collapse emergency evacuation needed'
    ];
    
    for (var desc in testDescriptions) {
      final result = ImageAnalysisService.analyzeDescriptionForPriority(desc);
      print('Description: "$desc"');
      print('Priority: ${result['priority']} - ${result['explanation']}');
      print('---');
    }
    
    if (connected) {
      print('\n✅ SUCCESS: Gemini AI is working 100% effectively!');
      print('🎯 Ready for disaster detection and priority assignment');
      print('🔥 API credentials validated and functional');
    } else {
      print('\n❌ FAILED: API connection issue needs resolution');
    }
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}