import 'lib/image_analysis_service.dart';

void main() {
  print('🌊 Testing FLOOD Detection - Should Always Be HIGH Priority');
  
  // Test flood-related descriptions
  final floodTests = [
    'Major flooding in downtown area',
    'Water damage from storm flooding', 
    'Severe flood, roads submerged',
    'Flash flood emergency evacuation',
    'City flooded after heavy rain',
    'Building flooded water damage',
    'Street flooding traffic blocked'
  ];
  
  print('\n=== FLOOD PRIORITY TESTS ===');
  
  for (int i = 0; i < floodTests.length; i++) {
    final description = floodTests[i];
    final result = ImageAnalysisService.analyzeDescriptionForPriority(description);
    final priority = result['priority']!;
    
    final success = priority == 'High';
    print('\nFlood Test ${i + 1}: ${success ? "✅ PASS" : "❌ FAIL"}');
    print('Description: "$description"');
    print('Priority: $priority ${success ? "(CORRECT)" : "(WRONG - SHOULD BE HIGH)"}');
  }
  
  // Test other disasters too
  final disasterTests = [
    'Building on fire emergency',
    'Earthquake building collapsed', 
    'Hurricane wind damage severe',
    'Explosion at factory urgent',
    'Bridge collapse evacuation needed'
  ];
  
  print('\n=== OTHER DISASTER TESTS ===');
  
  for (int i = 0; i < disasterTests.length; i++) {
    final description = disasterTests[i];
    final result = ImageAnalysisService.analyzeDescriptionForPriority(description);
    final priority = result['priority']!;
    
    final success = priority == 'High';
    print('\nDisaster Test ${i + 1}: ${success ? "✅ PASS" : "❌ FAIL"}');
    print('Description: "$description"');  
    print('Priority: $priority ${success ? "(CORRECT)" : "(WRONG - SHOULD BE HIGH)"}');
  }
  
  print('\n🎯 ALL NATURAL DISASTERS SHOULD NOW BE HIGH PRIORITY!');
  print('🔧 Enhanced detection system active');
}