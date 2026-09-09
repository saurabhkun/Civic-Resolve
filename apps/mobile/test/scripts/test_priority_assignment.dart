import 'lib/image_analysis_service.dart';

void main() {
  print('🎯 Testing Priority Assignment System...');
  
  // Test cases for description-based analysis
  final testCases = [
    {
      'description': 'Major fire emergency downtown building collapse urgent evacuation needed',
      'expected': 'High',
      'reason': 'Multiple urgent keywords: fire, emergency, collapse, urgent, evacuation'
    },
    {
      'description': 'Severe flooding on Main Street water levels rising rapidly',
      'expected': 'High', 
      'reason': 'Flood + severe keywords'
    },
    {
      'description': 'Bridge structural damage visible cracks inspection needed',
      'expected': 'Medium',
      'reason': 'Structural damage but no immediate emergency keywords'
    },
    {
      'description': 'Small pothole on residential street needs repair',
      'expected': 'Low',
      'reason': 'Minor issue, no emergency indicators'
    },
    {
      'description': 'Earthquake aftermath building collapsed multiple casualties emergency',
      'expected': 'High',
      'reason': 'Earthquake + collapse + casualties + emergency = high severity'
    }
  ];
  
  print('\n=== Priority Assignment Results ===');
  
  int passed = 0;
  int total = testCases.length;
  
  for (int i = 0; i < testCases.length; i++) {
    final testCase = testCases[i];
    final result = ImageAnalysisService.analyzeDescriptionForPriority(testCase['description']!);
    final actualPriority = result['priority']!;
    final expectedPriority = testCase['expected']!;
    
    final success = actualPriority == expectedPriority;
    if (success) passed++;
    
    print('\nTest ${i + 1}: ${success ? "✅ PASS" : "❌ FAIL"}');
    print('Description: "${testCase['description']}"');
    print('Expected: $expectedPriority');
    print('Actual: $actualPriority');
    print('Reason: ${testCase['reason']}');
    
    if (!success) {
      print('❌ Mismatch detected!');
    }
  }
  
  print('\n=== Test Summary ===');
  print('Passed: $passed/$total tests');
  print('Success Rate: ${(passed/total*100).toStringAsFixed(1)}%');
  
  if (passed == total) {
    print('🎉 ALL TESTS PASSED! Priority assignment working 100% effectively!');
  } else {
    print('⚠️ Some tests failed. Priority logic may need adjustment.');
  }
  
  // Test Gemini analysis info
  print('\n=== Gemini Configuration ===');
  final info = ImageAnalysisService.getAnalysisInfo();
  print('API Key: ${info['apiKey']}');
  print('Model: ${info['model']}');
  print('Disaster Categories: ${info['disasterTypes']}');
}