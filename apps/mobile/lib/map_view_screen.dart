import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'language_service.dart';
import 'leaflet_map_service.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  Position? _currentPosition;
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _selectedView = 'Map';
  bool _showSatellite = false;
  
  WebViewController? _webViewController;
  
  // Enhanced nearby reports data with more realistic information
  final List<Map<String, dynamic>> _nearbyReports = [
    {
      'id': '1',
      'title': '🚨 Flood Emergency - Solapur Highway',
      'description': 'Heavy flooding blocking main highway, multiple vehicles stranded. Emergency services needed urgently.',
      'category': 'Emergency',
      'status': 'Active',
      'distance': 0.8,
      'latitude': 17.6869,
      'longitude': 75.9228,
      'priority': 'High',
      'reportedTime': '15 mins ago',
      'icon': Icons.flood,
      'color': Colors.red,
      'severity': 'Critical',
      'affected': '200+ people',
    },
    {
      'id': '2',
      'title': '🔥 Building Fire - Commercial Complex',
      'description': 'Fire reported in 3-story commercial building. Fire department on scene, evacuation in progress.',
      'category': 'Emergency',
      'status': 'In Progress',
      'distance': 1.2,
      'latitude': 17.6850,
      'longitude': 75.9250,
      'priority': 'High',
      'reportedTime': '32 mins ago',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'severity': 'Critical',
      'affected': '50+ people',
    },
    {
      'id': '3',
      'title': '🚧 Major Road Damage - Pune Road',
      'description': 'Large section of road collapsed after heavy rains. Traffic diverted, repairs ongoing.',
      'category': 'Infrastructure',
      'status': 'Reported',
      'distance': 2.1,
      'latitude': 17.6889,
      'longitude': 75.9200,
      'priority': 'High',
      'reportedTime': '1 hour ago',
      'icon': Icons.construction,
      'color': Colors.orange,
      'severity': 'Major',
      'affected': 'Main traffic route',
    },
    {
      'id': '4',
      'title': '💡 Street Lighting Outage - Siddheshwar Area',
      'description': 'Multiple street lights not working in residential area causing safety concerns.',
      'category': 'Infrastructure',
      'status': 'In Progress',
      'distance': 0.5,
      'latitude': 17.6859,
      'longitude': 75.9270,
      'priority': 'Medium',
      'reportedTime': '2 hours ago',
      'icon': Icons.lightbulb_outline,
      'color': Colors.orange,
      'severity': 'Moderate',
      'affected': '500+ residents',
    },
    {
      'id': '5',
      'title': '🗑️ Waste Management Crisis - Hotgi Road',
      'description': 'Garbage trucks unable to access area due to flooding. Waste accumulating rapidly.',
      'category': 'Sanitation',
      'status': 'Reported',
      'distance': 1.8,
      'latitude': 17.6840,
      'longitude': 75.9280,
      'priority': 'Medium',
      'reportedTime': '3 hours ago',
      'icon': Icons.delete_outline,
      'color': Colors.brown,
      'severity': 'Moderate',
      'affected': '1000+ residents',
    },
    {
      'id': '6',
      'title': '⚡ Power Outage - Industrial Zone',
      'description': 'Complete power failure in industrial area affecting factories and businesses.',
      'category': 'Utilities',
      'status': 'In Progress',
      'distance': 3.2,
      'latitude': 17.6830,
      'longitude': 75.9180,
      'priority': 'High',
      'reportedTime': '45 mins ago',
      'icon': Icons.power_off,
      'color': Colors.red,
      'severity': 'Major',
      'affected': '20+ businesses',
    },
    {
      'id': '7',
      'title': '🏥 Medical Emergency - Accident Site',
      'description': 'Multi-vehicle accident on bypass road. Ambulances dispatched, medical aid required.',
      'category': 'Emergency',
      'status': 'Active',
      'distance': 2.5,
      'latitude': 17.6820,
      'longitude': 75.9320,
      'priority': 'High',
      'reportedTime': '8 mins ago',
      'icon': Icons.local_hospital,
      'color': Colors.red,
      'severity': 'Critical',
      'affected': '8+ people',
    },
    {
      'id': '8',
      'title': '🌊 Water Pipeline Burst - Railway Station Area',
      'description': 'Major water main burst flooding railway underpass. Water supply disrupted.',
      'category': 'Utilities',
      'status': 'Reported',
      'distance': 1.5,
      'latitude': 17.6870,
      'longitude': 75.9240,
      'priority': 'High',
      'reportedTime': '1.5 hours ago',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'severity': 'Major',
      'affected': '5000+ residents',
    },
  ];

  final List<String> _filterOptions = [
    'All', 'Emergency', 'Infrastructure', 'Utilities', 'Sanitation'
  ];
  
  final List<String> _viewOptions = ['Map', 'List', 'Analytics'];

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _getCurrentLocation();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      
      // Initialize web map if on web
      if (kIsWeb && _currentPosition != null) {
        _initializeWebMap();
      }
    } catch (e) {
      _showLocationError('Failed to get location: $e');
    }
  }
  
  Future<void> _initializeWebMap() async {
    if (_currentPosition == null) return;
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Map is ready, can add additional setup here
          },
        ),
      )
      ..loadHtmlString(
        LeafletMapService.getEnhancedMapHTML(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          zoom: 14.0,
          reports: _getFilteredReports(),
        ),
      );
  }

  void _showLocationError(String message) {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isLoading = true;
            });
            _getCurrentLocation();
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredReports() {
    if (_selectedFilter == 'All') {
      return _nearbyReports;
    }
    return _nearbyReports.where((report) => report['category'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'active':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'emergency':
        return Icons.emergency;
      case 'infrastructure':
        return Icons.construction;
      case 'utilities':
        return Icons.power;
      case 'sanitation':
        return Icons.cleaning_services;
      default:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        title: Text(
          _selectedView == 'Map' ? '🗺️ Enhanced Map' : 
          _selectedView == 'List' ? '📋 Reports List' : '📊 Analytics',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_module),
            onSelected: (value) {
              setState(() {
                _selectedView = value;
              });
            },
            itemBuilder: (context) => _viewOptions.map((view) {
              return PopupMenuItem<String>(
                value: view,
                child: Row(
                  children: [
                    Icon(
                      view == 'Map' ? Icons.map :
                      view == 'List' ? Icons.list :
                      Icons.analytics,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(view),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _getCurrentLocation();
            },
            icon: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: const Icon(Icons.my_location),
                );
              },
            ),
            tooltip: 'Get Current Location',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Enhanced Filter Bar
                _buildEnhancedFilterBar(),
                
                // Content based on selected view
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    switch (_selectedView) {
      case 'Map':
        return _buildMapView();
      case 'List':
        return _buildListView();
      case 'Analytics':
        return _buildAnalyticsView();
      default:
        return _buildMapView();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_searching,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Getting your location...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please ensure location permissions are enabled',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (_currentPosition == null) {
      return const Center(
        child: Text(
          'Location not available',
          style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      );
    }

    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _webViewController != null
              ? WebViewWidget(controller: _webViewController!)
              : const Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      // For mobile, show a placeholder or native map implementation
      return _buildMobileMapPlaceholder();
    }
  }

  Widget _buildMobileMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.green.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: Colors.blue.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enhanced Map View',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Interactive map with reports and real-time data',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_currentPosition != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '📍 Your Location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final filteredReports = _getFilteredReports();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return _buildEnhancedReportCard(report);
      },
    );
  }

  Widget _buildAnalyticsView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Reports Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildTrendChart(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final highPriorityCount = _nearbyReports.where((r) => r['priority'] == 'High').length;
    final emergencyCount = _nearbyReports.where((r) => r['category'] == 'Emergency').length;
    final activeCount = _nearbyReports.where((r) => r['status'] == 'Active').length;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('🚨 High Priority', highPriorityCount.toString(), Colors.red),
        _buildStatCard('⚡ Emergencies', emergencyCount.toString(), Colors.orange),
        _buildStatCard('🔥 Active Reports', activeCount.toString(), Colors.blue),
        _buildStatCard('📍 Total Reports', _nearbyReports.length.toString(), Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            '📈 Report Trends (Last 7 Days)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(
                'Interactive chart would be displayed here\nshowing report trends over time',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFilterBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selectedColor: const Color(0xFF3B82F6),
                    backgroundColor: Colors.white,
                    elevation: isSelected ? 4 : 1,
                    shadowColor: Colors.black26,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      
                      // Update map if in web view
                      if (kIsWeb && _webViewController != null) {
                        _initializeWebMap();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showSatellite = !_showSatellite;
                });
              },
              icon: Icon(
                _showSatellite ? Icons.satellite_alt : Icons.map,
                color: _showSatellite ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
              ),
              tooltip: _showSatellite ? 'Street View' : 'Satellite View',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedReportCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority and category
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getPriorityColor(report['priority']).withOpacity(0.1),
                  _getPriorityColor(report['priority']).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(report['priority']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(report['category']),
                    color: _getPriorityColor(report['priority']),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(report['priority']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              report['priority'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(report['status']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              report['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(report['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${report['distance']} km',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          
          // Description and details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Additional info for enhanced reports
                if (report['severity'] != null || report['affected'] != null) ...[
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (report['severity'] != null) ...[
                        const Icon(Icons.warning_amber, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Severity: ${report['severity']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (report['affected'] != null) ...[
                        const Icon(Icons.people, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Affected: ${report['affected']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          report['reportedTime'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Navigate to report location on map
                            if (_selectedView != 'Map') {
                              setState(() {
                                _selectedView = 'Map';
                              });
                            }
                          },
                          icon: const Icon(Icons.location_on, size: 18),
                          tooltip: 'Show on Map',
                          color: const Color(0xFF3B82F6),
                        ),
                        IconButton(
                          onPressed: () {
                            // Share report
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Report "${report['title']}" shared'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          tooltip: 'Share Report',
                          color: const Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to report creation with current location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.add_location_alt, color: Colors.white),
                SizedBox(width: 8),
                Text('Creating new report from current location...'),
              ],
            ),
            backgroundColor: const Color(0xFF3B82F6),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      },
      backgroundColor: const Color(0xFF3B82F6),
      foregroundColor: Colors.white,
      elevation: 8,
      label: const Text(
        'Report Issue',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.add_location_alt),
    );
  }
}