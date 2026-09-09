import 'package:flutter/material.dart';
import 'language_service.dart';
import 'category_selection_screen.dart';
import 'track_reports_screen.dart';
import 'notifications_screen.dart';
import 'notification_service.dart';
import 'emergency_contacts_screen.dart';
import 'map_view_screen.dart';
import 'language_selection_screen.dart';
import 'profile_page.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAdmin;
  
  const DashboardScreen({super.key, this.isAdmin = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _openReportsCount = 7; // Mock data
  
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _animationController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(),
        drawer: _buildSidebar(),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Hero Section
                      _buildWelcomeHeroCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Dashboard Cards with staggered animation
                      _buildAnimatedDashboardCard(
                        title: 'Report a New Issue',
                        description: 'Spotted a problem? Let us know and help improve your community',
                        icon: Icons.report_problem_outlined,
                        buttonText: 'Create Report',
                        onTap: () => _navigateToReportIssue(),
                        animationDelay: 0,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildAnimatedDashboardCard(
                        title: 'Track My Reports',
                        description: 'View the status of your submitted issues and their progress',
                        icon: Icons.visibility_outlined,
                        buttonText: 'View Reports',
                        badge: _openReportsCount > 0 ? '$_openReportsCount Open' : null,
                        onTap: () => _navigateToTrackReports(),
                        animationDelay: 100,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildAnimatedDashboardCard(
                        title: 'Emergency Contacts',
                        description: 'Quick access to local emergency services and important contacts',
                        icon: Icons.emergency,
                        buttonText: 'Emergency Help',
                        onTap: () => _showEmergencyContacts(),
                        animationDelay: 200,
                        isEmergency: true,
                      ),
                      
                      if (widget.isAdmin) ...[
                        const SizedBox(height: 16),
                        _buildAnimatedDashboardCard(
                          title: 'Admin Analytics',
                          description: 'View comprehensive reports statistics and community insights',
                          icon: Icons.analytics_rounded,
                          buttonText: 'View Analytics',
                          onTap: () => _navigateToAnalytics(),
                          animationDelay: 300,
                        ),
                      ],
                      
                      const SizedBox(height: 80), // Extra bottom padding
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 3,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        style: IconButton.styleFrom(
          highlightColor: colorScheme.primary.withValues(alpha: 0.1),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded, 
              color: colorScheme.onPrimaryContainer, 
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'CivicResolve',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // Notification Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => _navigateToNotifications(),
            icon: ValueListenableBuilder<int>(
              valueListenable: NotificationService().unreadCountNotifier,
              builder: (context, unreadCount, child) {
                return Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.onSurface,
                      size: 24,
                    ),
                    // Notification badge
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            style: IconButton.styleFrom(
              highlightColor: colorScheme.primary.withValues(alpha: 0.1),
              splashFactory: InkRipple.splashFactory,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            icon: Hero(
              tag: 'user_avatar',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded, 
                  color: colorScheme.onPrimary, 
                  size: 22,
                ),
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'status',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Verified User',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          'Aadhaar Verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(Icons.notifications_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('Notifications'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'language',
                child: Row(
                  children: [
                    Icon(Icons.language_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    const Text('Language'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Text('Log out', style: TextStyle(color: colorScheme.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleProfileMenuAction(value),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeroCard() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 12,
      shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Purple
              Color(0xFFA855F7), // Purple
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isAdmin ? 'Admin Dashboard' : 'Welcome to CivicResolve',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.isAdmin 
                            ? 'Manage reports and oversee community issues'
                            : 'Make your community better, one report at a time',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Verified Account',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Local Area',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDashboardCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    required int animationDelay,
    String? badge,
    bool isEmergency = false,
  }) {
    // Define vibrant colors for different card types
    Color getCardColor() {
      if (isEmergency) return const Color(0xFFDC2626); // Strong Emergency Red
      if (title.contains('Report')) return const Color(0xFF0EA5E9); // Sky Blue
      if (title.contains('Track')) return const Color(0xFFF59E0B); // Amber
      if (title.contains('Admin')) return const Color(0xFF059669); // Emerald
      return const Color(0xFF3B82F6); // Default blue
    }
    
    Color getGradientStart() {
      if (isEmergency) return const Color(0xFFDC2626); // Strong Emergency Red
      if (title.contains('Report')) return const Color(0xFF0EA5E9); // Sky Blue
      if (title.contains('Track')) return const Color(0xFFF59E0B); // Amber
      if (title.contains('Admin')) return const Color(0xFF059669); // Emerald
      return const Color(0xFF3B82F6);
    }
    
    Color getGradientEnd() {
      if (isEmergency) return const Color(0xFFEF4444); // Bright Emergency Red
      if (title.contains('Report')) return const Color(0xFF38BDF8); // Light Sky Blue
      if (title.contains('Track')) return const Color(0xFFFBBF24); // Light Amber
      if (title.contains('Admin')) return const Color(0xFF34D399); // Light Emerald
      return const Color(0xFF64B5F6);
    }
    
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final delay = animationDelay / 1000.0;
        final progress = Curves.easeOutCubic.transform(
          (((_staggerController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0)),
        );
        
        return Transform.translate(
          offset: Offset(0, (1 - progress) * 50),
          child: Opacity(
            opacity: progress,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Card(
                    elevation: 8,
                    shadowColor: getCardColor().withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            getGradientStart(),
                            getGradientEnd(),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: getCardColor().withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      icon, 
                                      color: Colors.white, 
                                      size: 32,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (badge != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        badge,
                                        style: TextStyle(
                                          color: getCardColor(),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: onTap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: getCardColor(),
                                    elevation: 4,
                                    shadowColor: Colors.black.withValues(alpha: 0.2),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        buttonText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: getCardColor(),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: getCardColor(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return NavigationDrawer(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      onDestinationSelected: _handleDrawerNavigation,
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_rounded, 
                    color: colorScheme.onPrimary, 
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CivicResolve',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isAdmin ? 'Admin Panel' : 'Citizen Portal',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.add_circle_outline_rounded),
          label: Text('Report New Issue'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.track_changes_rounded),
          label: Text('Track My Reports'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.map_rounded),
          label: Text('Map View'),
        ),
        if (widget.isAdmin)
          NavigationDrawerDestination(
            icon: Icon(Icons.analytics_rounded),
            label: Text('Analytics'),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.notifications_rounded),
          label: Text('Notifications'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.person_rounded),
          label: Text('Profile'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.emergency_rounded),
          label: Text('Emergency Contacts'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.language_rounded),
          label: Text('Language'),
        ),
      ],
    );
  }

  void _handleDrawerNavigation(int index) {
    Navigator.pop(context); // Close drawer first
    
    // Adjust index for admin-only analytics item
    int adjustedIndex = index;
    if (!widget.isAdmin && index >= 4) {
      adjustedIndex = index + 1; // Skip the analytics index
    }
    
    switch (adjustedIndex) {
      case 0: // Dashboard - do nothing, already here
        break;
      case 1: // Report New Issue
        _navigateToReportIssue();
        break;
      case 2: // Track My Reports
        _navigateToTrackReports();
        break;
      case 3: // Map View
        _navigateToMapView();
        break;
      case 4: // Analytics (admin only)
        if (widget.isAdmin) _navigateToAnalytics();
        break;
      case 5: // Notifications
        _navigateToNotifications();
        break;
      case 6: // Profile
        _navigateToProfile();
        break;
      case 7: // Emergency Contacts
        _showEmergencyContacts();
        break;
      case 8: // Language
        _showLanguageSelector();
        break;
    }
  }

  void _handleProfileMenuAction(String action) {
    switch (action) {
      case 'profile':
        _navigateToProfile();
        break;
      case 'notifications':
        _navigateToNotifications();
        break;
      case 'language':
        _showLanguageSelector();
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  void _navigateToReportIssue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategorySelectionScreen()),
    );
  }

  void _navigateToTrackReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrackReportsScreen()),
    );
  }

  void _navigateToMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapViewScreen()),
    );
  }

  void _navigateToAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics screen coming soon!')),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _showEmergencyContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()),
    );
  }

  void _showLanguageSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
    );
  }

  void _handleLogout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}