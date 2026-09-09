import 'lib/image_analysis_service.dart';

void main() {
  print('🚨 DISASTER PHOTO DETECTION SYSTEM TEST 🚨');
  print('=========================================================');
  
  // Test disaster descriptions that should trigger HIGH priority
  final disasterTests = [
    {
      'scenario': '🌊 FLOOD EMERGENCY WITH PHOTO',
      'description': 'Massive flooding in downtown area, water levels rising rapidly, bridge collapse visible in photo, immediate evacuation needed',
      'expectedPriority': 'High',
      'keywordsShouldInclude': ['flood', 'bridge collapse', 'evacuation']
    },
    {
      'scenario': '🌉 BRIDGE COLLAPSE PHOTO',
      'description': 'Bridge collapsed on highway in photo, structural failure evident, road completely blocked, emergency response required',
      'expectedPriority': 'High',
      'keywordsShouldInclude': ['bridge collapse', 'structural failure', 'emergency']
    },
    {
      'scenario': '🏢 BUILDING DAMAGE PHOTO',
      'description': 'Severe structural damage to apartment building visible in image, foundation cracks, unsafe conditions, residents evacuated',
      'expectedPriority': 'High',
      'keywordsShouldInclude': ['structural damage', 'unsafe conditions', 'evacuated']
    },
    {
      'scenario': '🔥 FIRE OUTBREAK PHOTO',
      'description': 'Building fire spreading rapidly as shown in photo, smoke visible, fire department responding, immediate danger to nearby structures',
      'expectedPriority': 'High',
      'keywordsShouldInclude': ['fire', 'immediate danger']
    },
    {
      'scenario': '⛽ GAS LEAK WITH PHOTO',
      'description': 'Major gas leak detected near shopping center, visible damage in photo, area evacuated, emergency crews on scene',
      'expectedPriority': 'High',
      'keywordsShouldInclude': ['gas leak', 'evacuated', 'emergency']
    },
    {
      'scenario': '🕳️ POTHOLE PHOTO',
      'description': 'Large pothole on main street shown in photo, causing vehicle damage, needs repair',
      'expectedPriority': 'Medium',
      'keywordsShouldInclude': ['pothole']
    },
    {
      'scenario': '🗑️ LITTER PHOTO',
      'description': 'Some trash scattered on sidewalk as shown in photo, minor cosmetic issue',
      'expectedPriority': 'Low',
      'keywordsShouldInclude': ['trash', 'cosmetic']
    }
  ];

  print('\n🔍 TESTING DESCRIPTION + PHOTO ANALYSIS:');
  print('==========================================');

  int passedTests = 0;
  int totalTests = disasterTests.length;

  for (int i = 0; i < disasterTests.length; i++) {
    final test = disasterTests[i];
    print('\n${i + 1}. ${test['scenario']}');
    print('   📝 Description: "${test['description']}"');
    
    // Analyze description (this simulates what happens when photo + description are analyzed)
    final analysis = ImageAnalysisService.analyzeDescriptionForPriority(test['description'] as String);
    final detectedPriority = analysis['priority'];
    final keywords = analysis['keywords'];
    final score = analysis['score'];
    final explanation = analysis['explanation'];
    
    print('   🎯 AI Result: $detectedPriority Priority (Score: $score)');
    print('   🔑 Keywords Found: $keywords');
    print('   📊 Expected: ${test['expectedPriority']} Priority');
    
    // Check if test passed
    bool testPassed = detectedPriority == test['expectedPriority'];
    
    // Also check if expected keywords were found
    final expectedKeywords = test['keywordsShouldInclude'] as List<String>;
    bool keywordsFound = expectedKeywords.any((keyword) => 
      keywords?.toLowerCase().contains(keyword.toLowerCase()) ?? false);
    
    if (testPassed && (expectedKeywords.isEmpty || keywordsFound)) {
      print('   ✅ TEST PASSED');
      passedTests++;
    } else {
      print('   ❌ TEST FAILED');
      if (!testPassed) {
        print('      Priority mismatch: got $detectedPriority, expected ${test['expectedPriority']}');
      }
      if (!keywordsFound && expectedKeywords.isNotEmpty) {
        print('      Missing expected keywords: $expectedKeywords');
      }
    }
    
    print('   💭 AI Explanation: $explanation');
  }

  print('\n=========================================================');
  print('📊 DISASTER PHOTO DETECTION TEST RESULTS:');
  print('   ✅ Passed: $passedTests/$totalTests tests');
  print('   📈 Success Rate: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%');
  
  if (passedTests == totalTests) {
    print('   🎉 EXCELLENT! All disaster detection tests passed!');
    print('   🔥 Your AI can now properly detect disasters in photos + descriptions!');
  } else {
    print('   ⚠️  Some tests failed. AI system may need additional tuning.');
  }
  
  print('\n🚀 HOW TO TEST WITH ACTUAL PHOTOS:');
  print('   1. 📱 Open the app in Chrome');
  print('   2. 🖼️  Upload a disaster photo (flood, collapse, fire, etc.)');
  print('   3. ✍️  Add description with disaster keywords');
  print('   4. 👀 Watch AI automatically detect HIGH priority!');
  print('   5. 🚨 Look for "DISASTER DETECTED!" popup message');
  
  print('\n🎯 DISASTER KEYWORDS THAT TRIGGER HIGH PRIORITY:');
  print('   • Floods: "flood", "flooding", "water rising"');
  print('   • Infrastructure: "bridge collapse", "building collapse"');
  print('   • Emergencies: "gas leak", "fire", "explosion"');
  print('   • Safety: "evacuation", "emergency", "immediate danger"');
  
  print('\n✨ Enhanced AI system ready for disaster detection!');
}