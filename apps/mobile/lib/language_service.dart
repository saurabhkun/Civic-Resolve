import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal() {
    _loadSavedLanguage();
  }

  static const List<Language> supportedLanguages = [
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    Language(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    Language(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    Language(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    Language(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
  ];

  Language _currentLanguage = supportedLanguages[0]; // Default to English

  Language get currentLanguage => _currentLanguage;

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString('selected_language');
      
      if (savedLanguageCode != null) {
        final savedLanguage = supportedLanguages.firstWhere(
          (lang) => lang.code == savedLanguageCode,
          orElse: () => supportedLanguages[0],
        );
        _currentLanguage = savedLanguage;
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading, keep default language
      debugPrint('Error loading saved language: $e');
    }
  }

  // Save language preference and notify listeners
  Future<void> changeLanguage(Language language) async {
    _currentLanguage = language;
    notifyListeners();
    
    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language.code);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  String getTranslation(String key) {
    return _getTranslations()[_currentLanguage.code]?[key] ?? key;
  }

  static Map<String, Map<String, String>> _getTranslations() {
    return {
      'en': {
        'app_name': 'CivicResolve',
        'app_slogan': 'Building Better Communities Together',
        'welcome_to_civicresolve': 'Welcome to CivicResolve',
        'welcome_subtitle': 'Report issues, connect with your community, and help make our city a better place.',
        'get_started': 'Get Started',
        'emergency_report': 'Emergency Report',
        'how_to_report': 'How to Report an Issue',
        'report_guide': 'A quick guide to submitting a report on our platform.',
        'add_photos': 'Add Photos',
        'add_photos_desc': 'A picture is worth a thousand words. Add up to 5 photos to show us what\'s wrong.',
        'pinpoint_location': 'Pinpoint Location',
        'pinpoint_location_desc': 'Use your phone\'s GPS or select a location on the map.',
        'describe_issue': 'Describe the Issue',
        'describe_issue_desc': 'Provide a brief text or voice description of the problem.',
        'track_progress': 'Track Your Progress',
        'track_progress_desc': 'Stay informed about your report\'s status with real-time updates.',
        'get_notified': 'Get Notified When Your Issues Are Resolved',
        'get_notified_desc': 'Stay informed about your report\'s progress. Receive timely updates and notifications.',
        'next': 'Next',
        'back': 'Back',
        'skip': 'Skip',
        'log_in': 'Log In',
        'login_subtitle': 'Welcome back, please enter your details.',
        'email': 'Email',
        'password': 'Password',
        'remember_me': 'Remember me',
        'forgot_password': 'Forgot password?',
        'or_continue_with': 'Or continue with',
        'dont_have_account': 'Don\'t have an account?',
        'sign_up': 'Sign up',
        'status_reported': 'Reported',
        'status_in_progress': 'In Progress',
        'status_resolved': 'Resolved',
      },
      'hi': {
        'app_name': 'CivicResolve',
        'app_slogan': 'बेहतर समुदाय मिलकर बनाते हैं',
        'welcome_to_civicresolve': 'CivicResolve में आपका स्वागत है',
        'welcome_subtitle': 'समस्याओं की रिपोर्ट करें, अपने समुदाय से जुड़ें, और हमारे शहर को बेहतर बनाने में मदद करें।',
        'get_started': 'शुरू करें',
        'emergency_report': 'आपातकालीन रिपोर्ट',
        'how_to_report': 'समस्या की रिपोर्ट कैसे करें',
        'report_guide': 'हमारे प्लेटफॉर्म पर रिपोर्ट जमा करने के लिए एक त्वरित गाइड।',
        'add_photos': 'फोटो जोड़ें',
        'add_photos_desc': 'एक तस्वीर हजार शब्दों के बराबर होती है। हमें दिखाने के लिए 5 तक फोटो जोड़ें कि क्या गलत है।',
        'pinpoint_location': 'स्थान निर्धारित करें',
        'pinpoint_location_desc': 'अपने फोन का GPS उपयोग करें या मानचित्र पर स्थान चुनें।',
        'describe_issue': 'समस्या का वर्णन करें',
        'describe_issue_desc': 'समस्या का संक्षिप्त पाठ या आवाज विवरण प्रदान करें।',
        'track_progress': 'अपनी प्रगति ट्रैक करें',
        'track_progress_desc': 'रीयल-टाइम अपडेट के साथ अपनी रिपोर्ट की स्थिति के बारे में सूचित रहें।',
        'get_notified': 'जब आपकी समस्याएं हल हो जाएं तो सूचना प्राप्त करें',
        'get_notified_desc': 'अपनी रिपोर्ट की प्रगति के बारे में सूचित रहें। समय पर अपडेट और सूचनाएं प्राप्त करें।',
        'next': 'आगे',
        'back': 'पीछे',
        'skip': 'छोड़ें',
        'log_in': 'लॉग इन',
        'login_subtitle': 'वापस आपका स्वागत है, कृपया अपनी जानकारी दर्ज करें।',
        'email': 'ईमेल',
        'password': 'पासवर्ड',
        'remember_me': 'मुझे याद रखें',
        'forgot_password': 'पासवर्ड भूल गए?',
        'or_continue_with': 'या जारी रखें',
        'dont_have_account': 'खाता नहीं है?',
        'sign_up': 'साइन अप',
        'status_reported': 'रिपोर्ट किया गया',
        'status_in_progress': 'प्रगति में',
        'status_resolved': 'हल हो गया',
      },
      'mr': {
        'app_name': 'CivicResolve',
        'app_slogan': 'चांगले समुदाय एकत्र बनवतात',
        'welcome_to_civicresolve': 'CivicResolve मध्ये आपले स्वागत आहे',
        'welcome_subtitle': 'समस्या नोंदवा, आपल्या समुदायाशी जुडा आणि आपले शहर चांगले बनवण्यात मदत करा।',
        'get_started': 'सुरुवात करा',
        'emergency_report': 'आपत्कालीन अहवाल',
        'how_to_report': 'समस्या कशी नोंदवायची',
        'report_guide': 'आमच्या प्लॅटफॉर्मवर अहवाल सबमिट करण्यासाठी एक द्रुत मार्गदर्शक।',
        'add_photos': 'फोटो जोडा',
        'add_photos_desc': 'एक चित्र हजार शब्दांच्या बरोबरीचे असते। आम्हाला दाखवण्यासाठी ५ पर्यंत फोटो जोडा।',
        'pinpoint_location': 'स्थान निश्चित करा',
        'pinpoint_location_desc': 'आपल्या फोनचा GPS वापरा किंवा नकाशावर स्थान निवडा।',
        'describe_issue': 'समस्येचे वर्णन करा',
        'describe_issue_desc': 'समस्येचे संक्षिप्त मजकूर किंवा आवाजातील वर्णन द्या।',
        'track_progress': 'आपली प्रगती ट्रॅक करा',
        'track_progress_desc': 'रिअल-टाइम अपडेटसह आपल्या अहवालाच्या स्थितीची माहिती ठेवा।',
        'get_notified': 'समस्या सुटल्यावर सूचना मिळवा',
        'get_notified_desc': 'आपल्या अहवालाच्या प्रगतीची माहिती ठेवा। वेळेवर अपडेट आणि सूचना मिळवा।',
        'next': 'पुढे',
        'back': 'मागे',
        'skip': 'सोडा',
        'log_in': 'लॉग इन',
        'login_subtitle': 'परत आपले स्वागत आहे, कृपया आपले तपशील प्रविष्ट करा।',
        'email': 'ईमेल',
        'password': 'पासवर्ड',
        'remember_me': 'मला लक्षात ठेवा',
        'forgot_password': 'पासवर्ड विसरलात?',
        'or_continue_with': 'किंवा पुढे चला',
        'dont_have_account': 'खाते नाही?',
        'sign_up': 'साइन अप',
        'status_reported': 'नोंदवले',
        'status_in_progress': 'प्रगतीत',
        'status_resolved': 'सुटले',
      },
      'te': {
        'app_name': 'CivicResolve',
        'app_slogan': 'మెరుగైన సంఘాలను కలిసి నిర్మిస్తున్నాము',
        'welcome_to_civicresolve': 'CivicResolve కి స్వాగతం',
        'welcome_subtitle': 'సమస్యలను నివేదించండి, మీ కమ్యూనిటీతో కనెక్ట్ అవ్వండి మరియు మా నగరాన్ని మెరుగైన ప్రదేశంగా మార్చడంలో సహాయపడండి।',
        'get_started': 'ప్రారంభించండి',
        'emergency_report': 'అత్యవసర నివేదిక',
        'how_to_report': 'సమస్యను ఎలా నివేదించాలి',
        'report_guide': 'మా ప్లాట్‌ఫారమ్‌లో నివేదికను సమర్పించడానికి శీఘ్ర గైడ్।',
        'add_photos': 'ఫోటోలు జోడించండి',
        'add_photos_desc': 'చిత్రం వేయి పదాలకు సమానం. ఏమి తప్పుగా ఉందో చూపించడానికి 5 వరకు ఫోటోలు జోడించండి।',
        'pinpoint_location': 'స్థానాన్ని గుర్తించండి',
        'pinpoint_location_desc': 'మీ ఫోన్ GPS ని ఉపయోగించండి లేదా మ్యాప్‌లో స్థానాన్ని ఎంచుకోండి।',
        'describe_issue': 'సమస్యను వివరించండి',
        'describe_issue_desc': 'సమస్య యొక్క క్లుప్త వచనం లేదా వాయిస్ వివరణను అందించండి।',
        'track_progress': 'మీ పురోగతిని ట్రాక్ చేయండి',
        'track_progress_desc': 'రియల్-టైమ్ అప్‌డేట్‌లతో మీ నివేదిక స్థితి గురించి తెలుసుకోండి।',
        'get_notified': 'మీ సమస్యలు పరిష్కరించబడినప్పుడు నోటిఫికేషన్ పొందండి',
        'get_notified_desc': 'మీ నివేదిక పురోగతి గురించి తెలుసుకోండి. సకాలంలో అప్‌డేట్‌లు మరియు నోటిఫికేషన్‌లను స్వీకరించండి।',
        'next': 'తదుపరి',
        'back': 'వెనుకకు',
        'skip': 'దాటవేయండి',
        'log_in': 'లాగిన్',
        'login_subtitle': 'తిరిగి స్వాగతం, దయచేసి మీ వివరాలను నమోదు చేయండి।',
        'email': 'ఇమెయిల్',
        'password': 'పాస్‌వర్డ్',
        'remember_me': 'నన్ను గుర్తుంచుకో',
        'forgot_password': 'పాస్‌వర్డ్ మర్చిపోయారా?',
        'or_continue_with': 'లేదా కొనసాగించండి',
        'dont_have_account': 'ఖాతా లేదా?',
        'sign_up': 'సైన్ అప్',
        'status_reported': 'నివేదించబడింది',
        'status_in_progress': 'ప్రగతిలో',
        'status_resolved': 'పరిష్కరించబడింది',
      },
      'ta': {
        'app_name': 'CivicResolve',
        'app_slogan': 'சிறந்த சமூகங்களை ஒன்றாக உருவாக்குகிறோம்',
        'welcome_to_civicresolve': 'CivicResolve க்கு வரவேற்கிறோம்',
        'welcome_subtitle': 'பிரச்சினைகளைப் புகாரளியுங்கள், உங்கள் சமூகத்துடன் இணையுங்கள், எங்கள் நகரத்தை சிறந்த இடமாக மாற்ற உதவுங்கள்।',
        'get_started': 'தொடங்குங்கள்',
        'emergency_report': 'அவசர அறிக்கை',
        'how_to_report': 'சிக்கலை எவ்வாறு புகாரளிப்பது',
        'report_guide': 'எங்கள் தளத்தில் அறிக்கையை சமர்பிக்க விரைவான வழிகாட்டி।',
        'add_photos': 'புகைப்படங்களைச் சேர்க்கவும்',
        'add_photos_desc': 'ஒரு படம் ஆயிரம் வார்த்தைகளுக்கு சமம். என்ன தவறு என்பதைக் காட்ட 5 வரை புகைப்படங்களைச் சேர்க்கவும்.',
        'pinpoint_location': 'இடத்தைக் குறிப்பிடுங்கள்',
        'pinpoint_location_desc': 'உங்கள் ஃபோனின் GPS ஐப் பயன்படுத்துங்கள் அல்லது வரைபடத்தில் இடத்தைத் தேர்ந்தெடுக்கவும்.',
        'describe_issue': 'சிக்கலை விவரிக்கவும்',
        'describe_issue_desc': 'பிரச்சினையின் சுருக்கமான உரை அல்லது குரல் விளக்கத்தை வழங்கவும்.',
        'track_progress': 'உங்கள் முன்னேற்றத்தைக் கண்காணிக்கவும்',
        'track_progress_desc': 'நிகழ்நேர புதுப்பிப்புகளுடன் உங்கள் அறிக்கையின் நிலையைப் பற்றி தெரிந்து கொள்ளுங்கள்.',
        'get_notified': 'உங்கள் சிக்கல்கள் தீர்க்கப்படும்போது அறிவிப்பு பெறுங்கள்',
        'get_notified_desc': 'உங்கள் அறிக்கையின் முன்னேற்றத்தைப் பற்றி தெரிந்து கொள்ளுங்கள். சரியான நேரத்தில் புதுப்பிப்புகள் மற்றும் அறிவிப்புகளைப் பெறுங்கள்.',
        'next': 'அடுத்து',
        'back': 'பின்னால்',
        'skip': 'தவிர்க்கவும்',
        'log_in': 'உள்நுழையவும்',
        'login_subtitle': 'மீண்டும் வரவேற்கிறோம், தயவுசெய்து உங்கள் விவரங்களை உள்ளிடவும்.',
        'email': 'மின்னஞ்சல்',
        'password': 'கடவுச்சொல்',
        'remember_me': 'என்னை நினைவில் வைத்துக் கொள்ளுங்கள்',
        'forgot_password': 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?',
        'or_continue_with': 'அல்லது தொடரவும்',
        'dont_have_account': 'கணக்கு இல்லையா?',
        'sign_up': 'பதிவுபெறு',
        'status_reported': 'புகாரளிக்கப்பட்டது',
        'status_in_progress': 'செயல்பாட்டில்',
        'status_resolved': 'தீர்க்கப்பட்டது',
      },
      'ml': {
        'app_name': 'CivicResolve',
        'app_slogan': 'മികച്ച കമ്മ്യൂണിറ്റികൾ ഒരുമിച്ച് നിർമ്മിക്കുന്നു',
        'welcome_to_civicresolve': 'CivicResolve ലേക്ക് സ്വാഗതം',
        'welcome_subtitle': 'പ്രശ്നങ്ങൾ റിപ്പോർട്ട് ചെയ്യുക, നിങ്ങളുടെ കമ്മ്യൂണിറ്റിയുമായി ബന്ധപ്പെടുക, ഞങ്ങളുടെ നഗരത്തെ മികച്ച സ്ഥലമാക്കാൻ സഹായിക്കുക.',
        'get_started': 'ആരംഭിക്കുക',
        'emergency_report': 'അടിയന്തര റിപ്പോർട്ട്',
        'how_to_report': 'പ്രശ്നം എങ്ങനെ റിപ്പോർട്ട് ചെയ്യാം',
        'report_guide': 'ഞങ്ങളുടെ പ്ലാറ്റ്ഫോമിൽ റിപ്പോർട്ട് സമർപ്പിക്കുന്നതിനുള്ള വേഗമേറിയ ഗൈഡ്.',
        'add_photos': 'ഫോട്ടോകൾ ചേർക്കുക',
        'add_photos_desc': 'ഒരു ചിത്രം ആയിരം വാക്കുകൾക്ക് തുല്യമാണ്. എന്താണ് തെറ്റ് എന്ന് കാണിക്കാൻ 5 വരെ ഫോട്ടോകൾ ചേർക്കുക.',
        'pinpoint_location': 'സ്ഥലം നിശ്ചയിക്കുക',
        'pinpoint_location_desc': 'നിങ്ങളുടെ ഫോണിന്റെ GPS ഉപയോഗിക്കുക അല്ലെങ്കിൽ മാപ്പിൽ സ്ഥലം തിരഞ്ഞെടുക്കുക.',
        'describe_issue': 'പ്രശ്നം വിവരിക്കുക',
        'describe_issue_desc': 'പ്രശ്നത്തിന്റെ ഹ്രസ്വ വാചകം അല്ലെങ്കിൽ ശബ്ദ വിവരണം നൽകുക.',
        'track_progress': 'നിങ്ങളുടെ പുരോഗതി ട്രാക്ക് ചെയ്യുക',
        'track_progress_desc': 'റിയൽ-ടൈം അപ്ഡേറ്റുകളോടെ നിങ്ങളുടെ റിപ്പോർട്ടിന്റെ നില അറിയുക.',
        'get_notified': 'നിങ്ങളുടെ പ്രശ്നങ്ങൾ പരിഹരിക്കുമ്പോൾ അറിയിപ്പ് ലഭിക്കുക',
        'get_notified_desc': 'നിങ്ങളുടെ റിപ്പോർട്ടിന്റെ പുരോഗതിയെക്കുറിച്ച് അറിയുക. സമയബന്ധിതമായ അപ്ഡേറ്റുകളും അറിയിപ്പുകളും സ്വീകരിക്കുക.',
        'next': 'അടുത്തത്',
        'back': 'പിന്നോട്ട്',
        'skip': 'ഒഴിവാക്കുക',
        'log_in': 'ലോഗിൻ',
        'login_subtitle': 'തിരികെ സ്വാഗതം, നിങ്ങളുടെ വിശദാംശങ്ങൾ എൻട്രി ചെയ്യുക.',
        'email': 'ഇമെയിൽ',
        'password': 'പാസ്‌വേഡ്',
        'remember_me': 'എന്നെ ഓർത്തിരിക്കുക',
        'forgot_password': 'പാസ്‌വേഡ് മറന്നോ?',
        'or_continue_with': 'അല്ലെങ്കിൽ തുടരുക',
        'dont_have_account': 'അക്കൗണ്ട് ഇല്ലേ?',
        'sign_up': 'സൈൻ അപ്പ്',
        'status_reported': 'റിപ്പോർട്ട് ചെയ്തു',
        'status_in_progress': 'പുരോഗതിയിൽ',
        'status_resolved': 'പരിഹരിച്ചു',
      },
    };
  }
}