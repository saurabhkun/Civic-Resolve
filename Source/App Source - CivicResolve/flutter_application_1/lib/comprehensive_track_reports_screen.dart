import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'comprehensive_database_service.dart';
import 'comprehensive_report_models.dart';
import 'admin_actions_screen.dart';
import 'auth_service.dart';
import 'language_service.dart';
import 'dashboard_screen.dart';

class ComprehensiveTrackReportsScreen extends StatefulWidget {
  const ComprehensiveTrackReportsScreen({super.key});

  @override
  State<ComprehensiveTrackReportsScreen> createState() => _ComprehensiveTrackReportsScreenState();
}

class _ComprehensiveTrackReportsScreenState extends State<ComprehensiveTrackReportsScreen> 
    with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  final ComprehensiveDatabaseService _databaseService = ComprehensiveDatabaseService();
  final _searchController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'All';
  String _sortBy = 'Newest';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isAdmin = false;

  List<ComprehensiveReportModel> _allReports = [];
  List<ComprehensiveReportModel> _filteredReports = [];
  
  // Enhanced caching and performance optimization
  List<ComprehensiveReportModel> _cachedReports = [];
  DateTime? _lastCacheTime;
  StreamSubscription<List<ComprehensiveReportModel>>? _reportsSubscription;
  
  // Performance optimization variables
  Timer? _searchDebounceTimer;
  bool _isRefreshing = false;
  bool _hasInitialLoad = false;
  Map<String, ComprehensiveReportModel> _reportIndexMap = {};
  final Duration _cacheValidDuration = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    _initializeAnimations();
    _checkAdminStatus();
    _initializeReportsStream();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _reportsSubscription?.cancel();
    _searchDebounceTimer?.cancel();
    _animationController.dispose();
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Animation controller for card press effect
  void _animateCardPress(bool isPressed) {
    // This provides subtle feedback for card interactions
    // The InkWell already provides ripple effects
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _staggerController.forward();
  }

  void _checkAdminStatus() {
    final authService = AuthService.instance;
    setState(() {
      _isAdmin = authService.isAdmin;
    });
  }

  void _initializeReportsStream() {
    final stopwatch = Stopwatch()..start();
    final authService = AuthService.instance;
    final userId = authService.userEmail ?? '';
    
    print('⚡ Ultra-fast initialization starting for user: $userId');
    
    // INSTANT UI: Show skeleton immediately (0ms delay)
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    
    // Check if we have valid cached data first for instant loading
    if (_hasValidCachedData() && !_isRefreshing) {
      print('🚀 Lightning load: cached data (${_cachedReports.length} reports) in ${stopwatch.elapsedMilliseconds}ms');
      setState(() {
        _allReports = _cachedReports;
        _applyFiltersAndSearch();
        _isLoading = false;
        _hasError = false;
        _errorMessage = '';
        _hasInitialLoad = true;
      });
      
      // Trigger animations immediately
      _animationController.forward();
      _staggerController.forward();
      
      // Still fetch fresh data in background for real-time updates
      _fetchFreshDataInBackground(userId);
      stopwatch.stop();
      print('✅ Cached UI loaded in ${stopwatch.elapsedMilliseconds}ms');
      return;
    }
    
    print('🔄 Fetching fresh reports data...');
    
    // Cancel existing subscription
    _reportsSubscription?.cancel();
    
    try {
      Stream<List<ComprehensiveReportModel>> reportsStream;
      
      if (_isAdmin) {
        print('👑 Admin mode: Setting up stream for all reports');
        reportsStream = _databaseService.getAllReportsStream();
      } else {
        print('👤 User mode: Setting up stream for user reports');
        reportsStream = _databaseService.getUserReportsStream(userId);
      }
      
      // Ultra-fast stream with optimized timeout
      _reportsSubscription = reportsStream
          .timeout(
            const Duration(seconds: 3), // Reduced timeout for faster response
            onTimeout: (sink) {
              print('⏰ Stream timeout after ${stopwatch.elapsedMilliseconds}ms');
              sink.addError('Connection timeout. Please check your internet connection.');
            },
          )
          .listen(
            (reports) {
              final loadTime = stopwatch.elapsedMilliseconds;
              if (mounted) {
                // Detect status changes for real-time feedback
                _detectAndHandleStatusChanges(reports);
                
                // Create indexed map for O(1) lookups
                _reportIndexMap = {for (var report in reports) report.id: report};
                
                setState(() {
                  _allReports = reports;
                  _applyFiltersAndSearch();
                  _isLoading = false;
                  _hasError = false;
                  _errorMessage = '';
                  _hasInitialLoad = true;
                  _isRefreshing = false;
                });
                
                // Trigger smooth animations
                _animationController.forward();
                _staggerController.forward();
                
                // Smart caching with validation
                _cacheReportsDataSmart(reports);
                
                print('⚡ Real-time data loaded: ${reports.length} reports in ${loadTime}ms');
                _logStatusDistribution(reports);
                stopwatch.stop();
              }
            },
            onError: (error) {
              print('❌ Reports stream error after ${stopwatch.elapsedMilliseconds}ms: $error');
              if (mounted) {
                setState(() {
                  _hasError = !_hasValidCachedData();
                  _errorMessage = _formatErrorMessage(error);
                  _isLoading = false;
                  _isRefreshing = false;
                });
                
                // Load cached data if available
                if (_hasValidCachedData()) {
                  _loadCachedDataSmart();
                }
              }
            },
            cancelOnError: false,
          );
    } catch (e) {
      print('❌ Error initializing reports stream: $e');
      if (mounted) {
        setState(() {
          _hasError = !_hasValidCachedData();
          _errorMessage = 'Failed to connect to server. Please try again.';
          _isLoading = false;
          _isRefreshing = false;
        });
        
        if (_hasValidCachedData()) {
          _loadCachedDataSmart();
        }
      }
    }
  }

  /// Check if cached data is still valid
  bool _hasValidCachedData() {
    if (_cachedReports.isEmpty || _lastCacheTime == null) return false;
    
    final now = DateTime.now();
    final cacheAge = now.difference(_lastCacheTime!);
    return cacheAge < _cacheValidDuration;
  }

  /// Fetch fresh data in background without showing loading
  Future<void> _fetchFreshDataInBackground(String userId) async {
    try {
      final freshReports = _isAdmin 
          ? await _databaseService.getAllReportsComprehensive()
          : await _databaseService.getUserReportsComprehensive(userId);
      
      if (mounted && freshReports.isNotEmpty) {
        // Only update if data actually changed
        if (!_listsAreEqual(_allReports, freshReports)) {
          setState(() {
            _allReports = freshReports;
            _applyFiltersAndSearch();
          });
          _cacheReportsDataSmart(freshReports);
        }
      }
    } catch (e) {
      // Silent fail for background updates
      print('Background refresh failed: $e');
    }
  }

  /// Smart caching with deduplication
  Future<void> _cacheReportsDataSmart(List<ComprehensiveReportModel> reports) async {
    try {
      _cachedReports = List.from(reports);
      _lastCacheTime = DateTime.now();
      _reportIndexMap = {for (var report in reports) report.id: report};
      print('✅ Smart cached ${reports.length} reports with indexing');
    } catch (e) {
      print('⚠️ Failed to cache reports: $e');
    }
  }

  /// Load cached data with smart updates
  Future<void> _loadCachedDataSmart() async {
    try {
      if (_cachedReports.isNotEmpty) {
        print('📱 Loading smart cached reports');
        setState(() {
          _allReports = _cachedReports;
          _applyFiltersAndSearch();
          _hasInitialLoad = true;
        });
      }
    } catch (e) {
      print('❌ Error loading cached data: $e');
    }
  }

  /// Check if two lists are equal (simple comparison)
  bool _listsAreEqual(List<ComprehensiveReportModel> list1, List<ComprehensiveReportModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || list1[i].status != list2[i].status) {
        return false;
      }
    }
    return true;
  }

  /// Detect and handle status changes and admin notes updates for real-time feedback
  void _detectAndHandleStatusChanges(List<ComprehensiveReportModel> newReports) {
    if (_allReports.isEmpty) return; // First load
    
    // Create maps for efficient comparison
    final oldReportsMap = {for (var report in _allReports) report.id: report};
    final newReportsMap = {for (var report in newReports) report.id: report};
    
    // Detect status and admin notes changes
    for (var newReport in newReports) {
      final oldReport = oldReportsMap[newReport.id];
      if (oldReport != null) {
        // Check for status changes
        if (oldReport.status != newReport.status) {
          _handleStatusChange(oldReport, newReport);
        }
        
        // Check for admin notes changes
        if (oldReport.adminNotesCount != newReport.adminNotesCount) {
          _handleAdminNotesChange(oldReport, newReport);
        }
      }
    }
  }

  /// Handle individual status changes with user feedback
  void _handleStatusChange(ComprehensiveReportModel oldReport, ComprehensiveReportModel newReport) {
    print('🔄 Status change detected: ${oldReport.title} - ${oldReport.status.displayName} → ${newReport.status.displayName}');
    
    // Show user feedback for status changes
    if (mounted) {
      final statusColor = _getStatusColor(newReport.status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getStatusIcon(newReport.status),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Updated',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${newReport.title} → ${newReport.status.displayName}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: statusColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// Handle admin notes change notifications
  void _handleAdminNotesChange(ComprehensiveReportModel oldReport, ComprehensiveReportModel newReport) {
    print('📝 Admin notes change detected: ${oldReport.title} - Notes: ${oldReport.adminNotesCount} → ${newReport.adminNotesCount}');
    
    if (mounted) {
      final notesAdded = newReport.adminNotesCount - oldReport.adminNotesCount;
      if (notesAdded > 0) {
        // Show admin notes update notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.note_add,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Notes Added',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${newReport.title} - ${notesAdded} new note${notesAdded > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// Get icon for status
  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return Icons.upload_outlined;
      case ReportStatus.review:
        return Icons.rate_review_outlined;
      case ReportStatus.assigned:
        return Icons.assignment_outlined;
      case ReportStatus.progress:
        return Icons.hourglass_bottom_outlined;
      case ReportStatus.resolved:
        return Icons.check_circle_outline;
    }
  }

  /// Log status distribution for debugging
  void _logStatusDistribution(List<ComprehensiveReportModel> reports) {
    final statusCounts = <ReportStatus, int>{};
    for (var report in reports) {
      statusCounts[report.status] = (statusCounts[report.status] ?? 0) + 1;
    }
    
    print('📊 Status Distribution:');
    for (var entry in statusCounts.entries) {
      print('   ${entry.key.displayName}: ${entry.value}');
    }
  }

  /// Format error messages to be user-friendly
  String _formatErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Connection timeout. Please check your internet connection and try again.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return 'Access denied. Please log in again.';
    } else if (errorString.contains('server')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Unable to load reports. Please try again.';
    }
  }

  /// Cache reports data for offline access
  Future<void> _cacheReportsData(List<ComprehensiveReportModel> reports) async {
    try {
      // Simple in-memory cache - you could enhance this with SharedPreferences
      _cachedReports = List.from(reports);
      _lastCacheTime = DateTime.now();
      print('✅ Cached ${reports.length} reports');
    } catch (e) {
      print('⚠️ Failed to cache reports: $e');
    }
  }

  /// Load cached data as fallback
  Future<void> _loadCachedData() async {
    try {
      if (_cachedReports.isNotEmpty) {
        print('📱 Loading cached reports as fallback');
        setState(() {
          _allReports = _cachedReports;
          _applyFiltersAndSearch();
        });
        
        // Show a message about cached data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('📱 Showing cached data. Pull to refresh for latest updates.'),
              backgroundColor: Colors.orange[700],
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Refresh',
                textColor: Colors.white,
                onPressed: () => _refreshData(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading cached data: $e');
    }
  }

  /// Enhanced refresh with smart loading states
  Future<void> _refreshData() async {
    if (_isRefreshing) return; // Prevent multiple simultaneous refreshes
    
    print('🔄 Smart refreshing reports data...');
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // Show brief refresh feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('🔄 Refreshing reports...'),
              ],
            ),
            duration: const Duration(milliseconds: 800),
            backgroundColor: Colors.blue[700],
          ),
        );
      }
      
      // Force reinitialize the stream for fresh data
      _initializeReportsStream();
      
      // Wait briefly for the stream to connect
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      print('❌ Refresh error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Refresh failed: ${_formatErrorMessage(e)}'),
            backgroundColor: Colors.orange[700],
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _refreshData(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void _applyFiltersAndSearch() {
    // Cancel any pending search debounce
    _searchDebounceTimer?.cancel();
    
    // Use debounced search for better performance
    _searchDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      _performFilteringAndSearch();
    });
  }

  void _performFilteringAndSearch() {
    if (!mounted) return;
    
    List<ComprehensiveReportModel> filtered;
    
    // Use indexed map for faster lookups if available
    if (_reportIndexMap.isNotEmpty && _searchQuery.isEmpty && _selectedFilter == 'All') {
      filtered = _allReports;
    } else {
      filtered = List.from(_allReports);
    }

    // Optimized search filter with early termination
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      filtered = filtered.where((report) {
        // Check title first (most likely match)
        if (report.title.toLowerCase().contains(searchLower)) return true;
        // Then description
        if (report.description.toLowerCase().contains(searchLower)) return true;
        // Then location
        if (report.location.toLowerCase().contains(searchLower)) return true;
        // Finally category
        return report.categoryDisplayName?.toLowerCase().contains(searchLower) ?? false;
      }).toList();
    }

    // Apply status filter with O(1) lookup for common cases
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Submitted':
          filtered = filtered.where((r) => r.status == ReportStatus.submitted).toList();
          break;
        case 'Review':
          filtered = filtered.where((r) => r.status == ReportStatus.review).toList();
          break;
        case 'Assigned':
          filtered = filtered.where((r) => r.status == ReportStatus.assigned).toList();
          break;
        case 'Progress':
          filtered = filtered.where((r) => r.status == ReportStatus.progress).toList();
          break;
        case 'Resolved':
          filtered = filtered.where((r) => r.status == ReportStatus.resolved).toList();
          break;
        case 'High Priority':
          filtered = filtered.where((r) => r.priority == ReportPriority.high).toList();
          break;
      }
    }

    // Optimized sorting with cached comparison weights
    switch (_sortBy) {
      case 'Newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Priority':
        filtered.sort((a, b) => _getPriorityWeight(b.priority).compareTo(_getPriorityWeight(a.priority)));
        break;
      case 'Status':
        filtered.sort((a, b) => a.status.displayName.compareTo(b.status.displayName));
        break;
    }

    // Update state only if data actually changed
    if (!_listsAreEqualSimple(_filteredReports, filtered)) {
      setState(() {
        _filteredReports = filtered;
      });
    }
  }

  /// Simple equality check for performance
  bool _listsAreEqualSimple(List<ComprehensiveReportModel> list1, List<ComprehensiveReportModel> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }

  int _getPriorityWeight(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.high:
        return 3;
      case ReportPriority.medium:
        return 2;
      case ReportPriority.low:
        return 1;
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _applyFiltersAndSearch();
  }

  void _onFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedFilter = value;
      });
      _applyFiltersAndSearch();
    }
  }

  void _onSortChanged(String? value) {
    if (value != null) {
      setState(() {
        _sortBy = value;
      });
      _applyFiltersAndSearch();
    }
  }

  Future<void> _openReportDetails(ComprehensiveReportModel report) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReportDetailsModal(report),
    );
  }

  Future<void> _openAdminActions(ComprehensiveReportModel report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminActionsScreen(report: report),
      ),
    );

    if (result == true) {
      // Refresh the data if admin made changes
      _initializeReportsStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: _buildBody(colorScheme),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: Text(_isAdmin ? 'All Reports (Admin)' : 'My Reports'),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _initializeReportsStream(),
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    return Column(
      children: [
        // Always show search and filters
        _buildSearchAndFilters(colorScheme),
        _buildReportsCount(colorScheme),
        
        // Content area with improved loading
        Expanded(
          child: _buildContentArea(colorScheme),
        ),
      ],
    );
  }

  Widget _buildContentArea(ColorScheme colorScheme) {
    // Always show immediate UI elements - never blank screen
    if (_isLoading && !_hasInitialLoad) {
      return _buildEnhancedLoadingState(colorScheme);
    }

    if (_hasError && _allReports.isEmpty) {
      return _buildErrorState(colorScheme);
    }

    if (_filteredReports.isEmpty && !_isLoading) {
      return _buildEmptyState(colorScheme);
    }

    return _buildReportsList(colorScheme);
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Skeleton loading cards
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Show 3 skeleton cards
              itemBuilder: (context, index) {
                return _buildSkeletonCard(colorScheme);
              },
            ),
          ),
          // Enhanced loading indicator with animation
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.5, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  child: const Text('Loading reports...'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we fetch your reports',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                _buildShimmerContainer(80, 24, colorScheme),
                const SizedBox(width: 8),
                _buildShimmerContainer(60, 20, colorScheme),
                const Spacer(),
                _buildShimmerContainer(24, 24, colorScheme),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title skeleton
            _buildShimmerContainer(200, 16, colorScheme),
            const SizedBox(height: 4),
            _buildShimmerContainer(120, 14, colorScheme),
            const SizedBox(height: 8),
            
            // Description skeleton
            _buildShimmerContainer(double.infinity, 12, colorScheme),
            const SizedBox(height: 4),
            _buildShimmerContainer(250, 12, colorScheme),
            const SizedBox(height: 12),
            
            // Footer skeleton
            Row(
              children: [
                _buildShimmerContainer(16, 16, colorScheme),
                const SizedBox(width: 4),
                _buildShimmerContainer(100, 12, colorScheme),
                const Spacer(),
                _buildShimmerContainer(80, 12, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.3, end: 0.8),
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: width == double.infinity ? null : width,
          height: height,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(value * 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingState(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instant header with immediate feedback
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 6.28, // 2π for full rotation
                      child: Icon(
                        Icons.sync,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loading your reports...',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'This should only take a moment',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Enhanced skeleton cards with staggered animation
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Show 5 skeleton cards for better visual feedback
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildEnhancedSkeletonCard(colorScheme, index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSkeletonCard(ColorScheme colorScheme, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with priority badge skeleton
            Row(
              children: [
                _buildShimmerContainer(70 + (index * 10), 24, colorScheme),
                const SizedBox(width: 8),
                _buildShimmerContainer(50, 18, colorScheme),
                const Spacer(),
                _buildShimmerContainer(24, 24, colorScheme),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title and description
            _buildShimmerContainer(180 + (index * 20), 16, colorScheme),
            const SizedBox(height: 8),
            _buildShimmerContainer(double.infinity, 12, colorScheme),
            const SizedBox(height: 4),
            _buildShimmerContainer(200 + (index * 30), 12, colorScheme),
            const SizedBox(height: 12),
            
            // Footer with location and time
            Row(
              children: [
                _buildShimmerContainer(16, 16, colorScheme),
                const SizedBox(width: 6),
                _buildShimmerContainer(100 + (index * 15), 12, colorScheme),
                const Spacer(),
                _buildShimmerContainer(60, 12, colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading reports',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _initializeReportsStream(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced search bar with smooth animations
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _searchQuery.isEmpty 
                    ? const Icon(Icons.search, key: ValueKey('search'))
                    : Icon(Icons.search, color: colorScheme.primary, key: const ValueKey('search_active')),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          key: const ValueKey('clear'),
                          icon: Icon(Icons.clear, color: colorScheme.error),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 12),
          // Enhanced filters with smooth transitions
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        'All',
                        'Submitted',
                        'Review', 
                        'Assigned',
                        'Progress',
                        'Resolved',
                        'High Priority'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              color: _selectedFilter == value ? colorScheme.primary : colorScheme.onSurface,
                              fontWeight: _selectedFilter == value ? FontWeight.w600 : FontWeight.normal,
                            ),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                      onChanged: _onFilterChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: InputDecoration(
                        labelText: 'Sort by',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ['Newest', 'Oldest', 'Priority', 'Status'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              color: _sortBy == value ? colorScheme.primary : colorScheme.onSurface,
                              fontWeight: _sortBy == value ? FontWeight.w600 : FontWeight.normal,
                            ),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                      onChanged: _onSortChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsCount(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredReports.length} ${_filteredReports.length == 1 ? 'report' : 'reports'}',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
            const Text(' (filtered)'),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final isSearching = _searchQuery.isNotEmpty;
    final hasFilters = _selectedFilter != 'All';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching || hasFilters ? Icons.search_off : Icons.description_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching || hasFilters
                ? 'No matching reports found'
                : 'No reports yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isSearching || hasFilters
                  ? 'Try adjusting your search terms or filters'
                  : 'Your submitted reports will appear here once they\'re processed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (isSearching || hasFilters) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSearching)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      _applyFiltersAndSearch();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Search'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                if (isSearching && hasFilters) const SizedBox(width: 12),
                if (hasFilters)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'All';
                      });
                      _applyFiltersAndSearch();
                    },
                    icon: const Icon(Icons.filter_alt_off),
                    label: const Text('Clear Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Submit a Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportsList(ColorScheme colorScheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredReports.length,
            physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even with few items
            itemBuilder: (context, index) {
              final report = _filteredReports[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildReportCard(report, colorScheme),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(ComprehensiveReportModel report, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _openReportDetails(report),
                onTapDown: (_) => _animateCardPress(true),
                onTapUp: (_) => _animateCardPress(false),
                onTapCancel: () => _animateCardPress(false),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced header with smooth status animations
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(report.status),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusColor(report.status).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Text(report.statusDisplay),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(report.priority),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.priority.displayName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isAdmin)
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () => _openAdminActions(report),
                      tooltip: 'Admin Actions',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Report title and category
              Text(
                report.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.categoryDisplayName ?? report.category,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              // Description (truncated)
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              
              // Footer with details
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    report.submittedTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              
              // Admin notes indicator with smooth animation
              if (report.adminNotesCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          child: Text(
                            '${report.adminNotesCount} admin note${report.adminNotesCount == 1 ? '' : 's'}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportDetailsModal(ComprehensiveReportModel report) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Report Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _buildDetailedReportView(report, colorScheme),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedReportView(ComprehensiveReportModel report, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status and Priority Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      report.categoryDisplayName ?? report.category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '📝 ${report.statusDisplay}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${report.priority.displayName} (priority level from high, medium, low)',
                  style: TextStyle(
                    color: _getPriorityColor(report.priority),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Description Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(report.description),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Details Section
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Category:', report.categoryDisplayName ?? report.category),
                _buildDetailRow('Location:', report.location),
                _buildDetailRow('Reporter:', report.reporterName ?? 'Unknown'),
                _buildDetailRow('Contact:', report.contactNumber ?? 'Not provided'),
                _buildDetailRow('Aadhar Number:', report.aadharNumber ?? 'Not provided'),
                _buildDetailRow('Submitted:', report.submittedTime),
                _buildDetailRow('Last Updated:', report.lastUpdatedTime),
                if (report.imageUrls.isNotEmpty)
                  _buildDetailRow('Images', '${report.imageUrls.length} image(s)'),
                _buildDetailRow('Location', 'GPS coordinates'),
                Text(
                  report.gpsDisplay,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Admin Actions Section (if admin notes exist)
        if (report.adminNotesCount > 0) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Report states
                  const Text(
                    'Report states:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusIndicator('Submitted', report.status == ReportStatus.submitted),
                  _buildStatusIndicator('Review', report.status == ReportStatus.review),
                  _buildStatusIndicator('Assigned', report.status == ReportStatus.assigned),
                  _buildStatusIndicator('Progress', report.status == ReportStatus.progress),
                  _buildStatusIndicator('Resolved', report.status == ReportStatus.resolved),
                  
                  const SizedBox(height: 16),
                  
                  // Admin Notes placeholder
                  Row(
                    children: [
                      const Text(
                        'Admin Notes',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${report.adminNotesCount} note${report.adminNotesCount == 1 ? '' : 's'})',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isAdmin)
                    const Text(
                      'If the data is added here then it should reflect in report details in track my reports page',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  else
                    const Text(
                      'Admin notes are visible to administrators only',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 16,
            color: isActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            '- $status',
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      },
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: const Icon(Icons.add),
      label: const Text('New Report'),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return Colors.blue;
      case ReportStatus.review:
        return Colors.orange;
      case ReportStatus.assigned:
        return Colors.purple;
      case ReportStatus.progress:
        return Colors.amber[700]!;
      case ReportStatus.resolved:
        return Colors.green;
    }
  }

  Color _getPriorityColor(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.high:
        return Colors.red;
      case ReportPriority.medium:
        return Colors.orange;
      case ReportPriority.low:
        return Colors.green;
    }
  }
}