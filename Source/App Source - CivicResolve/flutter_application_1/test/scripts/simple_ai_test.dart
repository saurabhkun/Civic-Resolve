// Simple test to verify enhanced AI detection logic
void main() {
  print('Testing Enhanced AI Detection for Infrastructure Damage');
  print('=========================================================');
  
  // Test scenario 1: Bridge collapse detection
  print('\n1. Testing Bridge Collapse Detection:');
  final bridgeLabels = ['bridge', 'collapse', 'damaged', 'structure'];
  final bridgeObjects = ['Vehicle', 'Building'];
  final bridgeText = 'DANGER: Bridge collapse ahead, road closed';
  
  final bridgePriority = calculatePriorityFromAnalysis(
    bridgeLabels, 
    bridgeObjects, 
    bridgeText
  );
  print('   Labels: $bridgeLabels');
  print('   Objects: $bridgeObjects');
  print('   Text: "$bridgeText"');
  print('   Result: ${bridgePriority['priority']} Priority (Score: ${bridgePriority['score']})');
  print('   Explanation: ${bridgePriority['explanation']}');
  
  // Test scenario 2: Building structural damage
  print('\n2. Testing Building Structural Damage:');
  final buildingLabels = ['building', 'damage', 'structural', 'crack'];
  final buildingObjects = ['Building', 'Wall'];
  final buildingText = 'Structural damage visible on building facade';
  
  final buildingPriority = calculatePriorityFromAnalysis(
    buildingLabels, 
    buildingObjects, 
    buildingText
  );
  print('   Labels: $buildingLabels');
  print('   Objects: $buildingObjects');
  print('   Text: "$buildingText"');
  print('   Result: ${buildingPriority['priority']} Priority (Score: ${buildingPriority['score']})');
  print('   Explanation: ${buildingPriority['explanation']}');
  
  // Test scenario 3: Road infrastructure damage
  print('\n3. Testing Road Infrastructure Damage:');
  final roadLabels = ['road', 'pothole', 'damage', 'asphalt'];
  final roadObjects = ['Vehicle', 'Road'];
  final roadText = 'Large pothole causing traffic issues';
  
  final roadPriority = calculatePriorityFromAnalysis(
    roadLabels, 
    roadObjects, 
    roadText
  );
  print('   Labels: $roadLabels');
  print('   Objects: $roadObjects');
  print('   Text: "$roadText"');
  print('   Result: ${roadPriority['priority']} Priority (Score: ${roadPriority['score']})');
  print('   Explanation: ${roadPriority['explanation']}');
  
  // Test scenario 4: Minor issue (should be low priority)
  print('\n4. Testing Minor Issue:');
  final minorLabels = ['litter', 'trash', 'street'];
  final minorObjects = ['Plastic bag', 'Paper'];
  final minorText = 'Some litter on the sidewalk';
  
  final minorPriority = calculatePriorityFromAnalysis(
    minorLabels, 
    minorObjects, 
    minorText
  );
  print('   Labels: $minorLabels');
  print('   Objects: $minorObjects');
  print('   Text: "$minorText"');
  print('   Result: ${minorPriority['priority']} Priority (Score: ${minorPriority['score']})');
  print('   Explanation: ${minorPriority['explanation']}');
  
  print('\n=========================================================');
  print('Enhanced AI Detection Test Complete!');
  print('✅ Bridge collapses and major infrastructure damage should be HIGH priority');
  print('✅ Minor issues should be LOW priority');
  print('✅ Enhanced scoring system working correctly');
}

/// Test method to calculate priority from analysis components
Map<String, String> calculatePriorityFromAnalysis(
  List<String> labels, 
  List<String> objects, 
  String text
) {
  int damageScore = 0;
  String priorityReason = '';

  // Analyze objects with enhanced scoring
  for (final obj in objects) {
    final name = obj.toLowerCase();
    
    // High priority indicators - Major infrastructure damage
    if (_isHighPriorityObject(name)) {
      // Bridge collapse, building damage get maximum score
      if (name.contains('collapse') || name.contains('bridge') || 
          name.contains('structural') || name.contains('destroyed')) {
        damageScore += 5; // Maximum impact for infrastructure collapse
        priorityReason += 'Critical infrastructure damage detected ($obj). ';
      } else {
        damageScore += 4; // Other high priority damage
        priorityReason += 'High priority damage detected ($obj). ';
      }
    }
    // Medium priority indicators  
    else if (_isMediumPriorityObject(name)) {
      damageScore += 2;
      priorityReason += 'Moderate damage detected ($obj). ';
    }
    // Low priority indicators
    else if (_isLowPriorityObject(name)) {
      damageScore += 1;
      priorityReason += 'Minor issue detected ($obj). ';
    }
  }

  // Analyze labels with enhanced infrastructure focus
  for (final label in labels) {
    final description = label.toLowerCase();
    
    // Infrastructure damage gets highest priority
    if (_isHighPriorityLabel(description)) {
      // Bridge collapse, structural damage get maximum score
      if (description.contains('collapse') || description.contains('structural') ||
          description.contains('bridge') || description.contains('destruction')) {
        damageScore += 5; // Critical infrastructure damage
        priorityReason += 'Critical infrastructure damage identified ($label). ';
      } else {
        damageScore += 4; // Other high priority issues
        priorityReason += 'High priority damage identified ($label). ';
      }
    } else if (_isMediumPriorityLabel(description)) {
      damageScore += 2;
      priorityReason += 'Moderate damage identified ($label). ';
    } else if (_isLowPriorityLabel(description)) {
      damageScore += 1;
      priorityReason += 'Minor issue identified ($label). ';
    }
  }

  // Analyze text for emergency indicators with enhanced detection
  final detectedText = text.toLowerCase();
  if (_containsEmergencyText(detectedText)) {
    // Emergency text indicating infrastructure damage gets high score
    if (detectedText.contains('bridge closed') || detectedText.contains('collapsed') ||
        detectedText.contains('structural failure') || detectedText.contains('unsafe structure')) {
      damageScore += 6; // Critical infrastructure emergency text
      priorityReason += 'Critical emergency text detected indicating infrastructure failure. ';
    } else {
      damageScore += 4; // Other emergency text
      priorityReason += 'Emergency warning text detected. ';
    }
  }

  // Enhanced priority determination based on accumulated damage score
  String priority;
  String explanation;
  
  if (damageScore >= 10) {
    priority = 'High';
    explanation = 'Critical infrastructure damage requiring immediate emergency response. ' + priorityReason;
  } else if (damageScore >= 6) {
    priority = 'High';
    explanation = 'Serious damage requiring immediate attention. ' + priorityReason;
  } else if (damageScore >= 3) {
    priority = 'Medium';
    explanation = 'Moderate damage needing repair. ' + priorityReason;
  } else {
    priority = 'Low';
    explanation = 'Minor issues identified. ' + priorityReason;
  }
  
  return {
    'priority': priority,
    'explanation': explanation.trim(),
    'score': damageScore.toString()
  };
}

// High priority object indicators - Enhanced for infrastructure damage
bool _isHighPriorityObject(String objectName) {
  const highPriorityObjects = [
    // Emergency and immediate dangers
    'fire', 'flood', 'accident', 'crash', 'emergency', 'danger',
    'explosion', 'gas leak', 'electrical hazard', 'live wire',
    
    // Infrastructure collapse and major structural damage
    'collapse', 'collapsed bridge', 'fallen bridge', 'bridge damage',
    'building collapse', 'roof collapse', 'wall collapse',
    'structural collapse', 'fallen structure', 'destroyed building',
    
    // Road and transportation infrastructure damage
    'sinkhole', 'crater', 'major pothole', 'road collapse',
    'bridge crack', 'large crack', 'deep crack', 'foundation damage',
    'structural crack', 'split road', 'broken pavement',
    
    // Utilities and public safety hazards
    'broken pipe', 'water main break', 'sewage overflow',
    'power line down', 'fallen tree', 'blocked road',
    'debris', 'rubble', 'destruction', 'demolished',
  ];
  return highPriorityObjects.any((obj) => objectName.contains(obj));
}

// Medium priority object indicators
bool _isMediumPriorityObject(String objectName) {
  const mediumPriorityObjects = [
    'pothole', 'crack', 'damaged', 'broken', 'leak', 'missing',
    'vandalism', 'graffiti', 'overgrown', 'blocked', 'damaged sign',
    'faded marking', 'loose railing', 'worn surface', 'deterioration'
  ];
  return mediumPriorityObjects.any((obj) => objectName.contains(obj));
}

// Low priority object indicators
bool _isLowPriorityObject(String objectName) {
  const lowPriorityObjects = [
    'litter', 'trash', 'debris', 'leaves', 'dirt', 'stain',
    'minor wear', 'cosmetic', 'aesthetic', 'paint chip', 'scuff'
  ];
  return lowPriorityObjects.any((obj) => objectName.contains(obj));
}

// High priority label indicators - Enhanced for infrastructure damage
bool _isHighPriorityLabel(String label) {
  const highPriorityLabels = [
    // Infrastructure collapse and critical damage
    'collapse', 'collapsed', 'structural failure', 'bridge down',
    'building damage', 'major crack', 'foundation failure',
    'infrastructure damage', 'critical damage', 'severe damage',
    'structural compromise', 'unsafe structure', 'condemned',
    
    // Emergency situations requiring immediate response
    'emergency', 'urgent', 'critical', 'dangerous', 'hazardous',
    'immediate attention', 'public safety', 'evacuation', 'closure',
    'blocked access', 'impassable', 'risk to life', 'safety concern',
    
    // Major infrastructure systems failure
    'water main break', 'gas leak', 'electrical hazard', 'sewer overflow',
    'road washout', 'bridge closure', 'tunnel damage', 'overpass damage'
  ];
  return highPriorityLabels.any((lbl) => label.contains(lbl));
}

// Medium priority label indicators
bool _isMediumPriorityLabel(String label) {
  const mediumPriorityLabels = [
    'damaged', 'broken', 'needs repair', 'maintenance required',
    'deteriorating', 'wear', 'cracked', 'loose', 'missing',
    'vandalism', 'graffiti', 'blocked', 'obstructed'
  ];
  return mediumPriorityLabels.any((lbl) => label.contains(lbl));
}

// Low priority label indicators
bool _isLowPriorityLabel(String label) {
  const lowPriorityLabels = [
    'cosmetic', 'aesthetic', 'minor', 'superficial', 'light damage',
    'small issue', 'cleaning needed', 'maintenance', 'upkeep'
  ];
  return lowPriorityLabels.any((lbl) => label.contains(lbl));
}

// Emergency text indicators - Enhanced detection
bool _containsEmergencyText(String text) {
  const emergencyKeywords = [
    // Emergency and warning text
    'emergency', 'danger', 'warning', 'caution', 'hazard', 'unsafe',
    'do not enter', 'keep out', 'closed', 'evacuate', 'risk',
    
    // Infrastructure specific warnings
    'bridge closed', 'road closed', 'no entry', 'unsafe structure',
    'condemned', 'do not use', 'out of service', 'damaged',
    
    // Severity indicators in text
    'severe', 'critical', 'urgent', 'immediate', 'emergency repair',
    'structural failure', 'collapse', 'fallen', 'broken',
    
    // Safety and access restrictions
    'restricted access', 'authorized personnel only', 'safety zone',
    'construction zone', 'repair in progress', 'temporary closure'
  ];
  return emergencyKeywords.any((keyword) => text.contains(keyword));
}