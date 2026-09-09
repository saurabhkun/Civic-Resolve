import 'dart:io';
import 'package:test/test.dart';
import '../lib/image_analysis_service.dart';

void main() {
  group('Enhanced Gemini AI Image Analysis Tests', () {
    test('Description-based flood detection should return High priority', () async {
      // Test with flood description
      final result = ImageAnalysisService.analyzeDescriptionForPriority(
        'Major flooding in downtown area, water levels rising rapidly, emergency evacuation needed'
      );
      
      expect(result['priority'], equals('High'));
      expect(result['explanation'], contains('EMERGENCY') || result['explanation']!.contains('DISASTER'));
      print('✅ Flood description test: ${result['priority']} - ${result['explanation']}');
    });

    test('Description-based bridge collapse should return High priority', () async {
      final result = ImageAnalysisService.analyzeDescriptionForPriority(
        'Bridge collapse on Highway 101, major structural failure, road closed indefinitely'
      );
      
      expect(result['priority'], equals('High'));
      print('✅ Bridge collapse test: ${result['priority']} - ${result['explanation']}');
    });

    test('Gemini response parsing should handle various formats', () {
      // Test structured response
      final response1 = '''
PRIORITY: High
DISASTER_TYPE: Flood
SEVERITY: Severe
EXPLANATION: Major flooding visible with submerged vehicles and infrastructure
''';
      
      final result1 = ImageAnalysisService.parseGeminiResponse(response1);
      expect(result1, equals('High'));
      print('✅ Structured response test: $result1');

      // Test unstructured response with keywords
      final response2 = 'I can see severe flooding with water damage throughout the area. This is a major disaster requiring immediate attention.';
      
      final result2 = ImageAnalysisService.parseGeminiResponse(response2);
      expect(result2, equals('High'));
      print('✅ Keyword response test: $result2');

      // Test normal infrastructure issue
      final response3 = 'This appears to be a moderate pothole that needs maintenance attention.';
      
      final result3 = ImageAnalysisService.parseGeminiResponse(response3);
      expect(result3, equals('Medium'));
      print('✅ Normal issue test: $result3');
    });

    test('Priority color mapping should be correct', () {
      expect(ImageAnalysisService.getPriorityColor('High').value, equals(0xFFFF0000)); // Red
      expect(ImageAnalysisService.getPriorityColor('Medium').value, equals(0xFFFF9800)); // Orange  
      expect(ImageAnalysisService.getPriorityColor('Low').value, equals(0xFF4CAF50)); // Green
      print('✅ Color mapping test passed');
    });

    test('Priority explanations should be informative', () {
      final highExplanation = ImageAnalysisService.getPriorityExplanation('High');
      expect(highExplanation, contains('High Priority'));
      expect(highExplanation, contains('Immediate attention'));
      
      final mediumExplanation = ImageAnalysisService.getPriorityExplanation('Medium');
      expect(mediumExplanation, contains('Medium Priority'));
      expect(mediumExplanation, contains('Moderate'));
      
      print('✅ Explanation test passed');
    });
  });
}

// Helper extension to make parseGeminiResponse accessible for testing
extension TestHelpers on ImageAnalysisService {
  static String parseGeminiResponse(String response) {
    return ImageAnalysisService.parseGeminiResponseForTesting(response);
  }
}