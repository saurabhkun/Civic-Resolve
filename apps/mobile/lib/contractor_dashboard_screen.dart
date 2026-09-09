import 'package:flutter/material.dart';
import 'language_service.dart';
import 'contractor_profile_page.dart';

class ContractorDashboardScreen extends StatefulWidget {
  const ContractorDashboardScreen({super.key});

  @override
  State<ContractorDashboardScreen> createState() => _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> with TickerProviderStateMixin {
  final LanguageService _languageService = LanguageService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _currentIndex = 0;
  int _activeBids = 8;
  int _activeJobs = 5;
  int _pendingPayments = 3;
  int _newTenders = 12;
  double _monthlyEarnings = 285000; // ₹2.85L
  double _bidWinRate = 0.68; // 68%
  
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
        body: _buildPageContent(),
        bottomNavigationBar: _buildBottomNavigation(),
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
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.engineering_rounded, 
              color: colorScheme.onPrimaryContainer, 
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CivicResolve',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Contractor Portal',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
              if (_pendingPayments > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$_pendingPayments',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => _showNotifications(),
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              color: colorScheme.onPrimaryContainer,
              size: 18,
            ),
          ),
          onPressed: () => _navigateToProfile(),
        ),
      ],
    );
  }

  Widget _buildPageContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildWorksPage();
      case 2:
        return _buildFinancePage();
      case 3:
        return _buildTeamPage();
      case 4:
        return _buildMorePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return AnimatedBuilder(
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
                  // Dynamic Header
                  _buildDynamicHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Performance Summary Cards
                  _buildPerformanceSummary(),
                  
                  const SizedBox(height: 20),
                  
                  // Today's Priority Actions
                  _buildPriorityActionsCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Interactive Map View
                  _buildMapViewCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Smart Alerts Panel
                  _buildSmartAlertsCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions Bar
                  _buildQuickActionsCard(),
                  
                  const SizedBox(height: 80), // Extra bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildPerformanceCard(
            'Monthly Earnings',
            '₹${(_monthlyEarnings / 100000).toStringAsFixed(1)}L',
            Icons.currency_rupee,
            const Color(0xFF4CAF50),
            '+12%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPerformanceCard(
            'Bid Win Rate',
            '${(_bidWinRate * 100).toInt()}%',
            Icons.trending_up,
            const Color(0xFF2196F3),
            '+5%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPerformanceCard(
            'New Tenders',
            '$_newTenders',
            Icons.work_outline,
            const Color(0xFFFF9800),
            'Today',
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good morning' : 
                    now.hour < 17 ? 'Good afternoon' : 'Good evening';
    final dayName = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFF6B73FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, Rajesh',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here is your agenda for $dayName, ${now.day}${_getOrdinalSuffix(now.day)} ${months[now.month - 1]} ${now.year}.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderStat('Active Projects', '$_activeJobs', Icons.engineering),
              const SizedBox(width: 16),
              _buildHeaderStat('Pending Bids', '$_activeBids', Icons.gavel),
              const SizedBox(width: 16),
              _buildHeaderStat('Due Payments', '$_pendingPayments', Icons.payment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildPriorityActionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Priority Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriorityItem(
              priority: 'URGENT',
              color: Colors.red,
              title: 'Bid for \'Park Lighting Tender\' closes in 3 hours.',
              onTap: () => _openTender(),
            ),
            const SizedBox(height: 12),
            _buildPriorityItem(
              priority: 'ACTION REQUIRED',
              color: Colors.orange,
              title: 'Upload completion photos for Job #CR-12345.',
              onTap: () => _openProjectWorkspace(),
            ),
            const SizedBox(height: 12),
            _buildPriorityItem(
              priority: 'INFO',
              color: Colors.green,
              title: 'Payment of ₹45,000 for Job #CR-12100 has been processed.',
              onTap: () => _viewPayments(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityItem({
    required String priority,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priority,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildMapViewCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.map_outlined, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Interactive Map View',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openFullMap(),
                  icon: const Icon(Icons.fullscreen, size: 16),
                  label: const Text('View Full', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[50]!,
                    Colors.blue[100]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[50]!,
                            Colors.blue[100]!,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Map content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 48, color: Colors.blue[600]),
                        const SizedBox(height: 12),
                        Text(
                          'Your Current Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Industrial Area, Phase-1, Chandigarh',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMapPin('3 Active Sites', Colors.blue),
                            _buildMapPin('7 Opportunities', Colors.green),
                            _buildMapPin('4 Team Members', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMapLegend('Active Jobs', Colors.blue, _activeJobs),
                _buildMapLegend('New Tenders', Colors.green, _newTenders),
                _buildMapLegend('Team Members', Colors.orange, 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMapLegend(String label, Color color, int count) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartAlertsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Smart Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSmartAlert(
              icon: Icons.trending_up,
              color: Colors.green,
              title: 'Opportunity Alert',
              message: 'High-value Plumbing tender posted 1km from your location. You have a 92% match score based on your skills and equipment.',
            ),
            const SizedBox(height: 12),
            _buildSmartAlert(
              icon: Icons.star,
              color: Colors.blue,
              title: 'Performance Alert',
              message: 'Your bid win-rate is 25% higher than the average for contractors in your category. Keep it up!',
            ),
            const SizedBox(height: 12),
            _buildSmartAlert(
              icon: Icons.payment,
              color: Colors.orange,
              title: 'Financial Alert',
              message: 'Invoice #INV-056 is 7 days overdue. Send a reminder?',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartAlert({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flash_on, color: Colors.amber[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildEnhancedQuickActionButton(
                  icon: Icons.search,
                  label: 'Find New Tenders',
                  color: const Color(0xFF2196F3),
                  onTap: () => _findTenders(),
                ),
                _buildEnhancedQuickActionButton(
                  icon: Icons.receipt_long,
                  label: 'Add Expense',
                  color: const Color(0xFF4CAF50),
                  onTap: () => _addExpense(),
                ),
                _buildEnhancedQuickActionButton(
                  icon: Icons.description,
                  label: 'Create Invoice',
                  color: const Color(0xFFFF9800),
                  onTap: () => _createInvoice(),
                ),
                _buildEnhancedQuickActionButton(
                  icon: Icons.camera_alt,
                  label: 'Scan Receipt',
                  color: const Color(0xFF9C27B0),
                  onTap: () => _scanReceipt(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorksPage() {
    return const Center(
      child: Text(
        'Works Page\n(Project Hub)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildFinancePage() {
    return const Center(
      child: Text(
        'Finance Page\n(Business Center)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildTeamPage() {
    return const Center(
      child: Text(
        'Team Page\n(For Scaling Businesses)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildMorePage() {
    return const Center(
      child: Text(
        'More Page\n(Control Panel)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.engineering),
          label: 'Works',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_rupee),
          label: 'Finance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Team',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContractorProfilePage()),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications opened')),
    );
  }

  // Action methods
  void _openTender() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening tender details...')),
    );
  }

  void _openProjectWorkspace() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening project workspace...')),
    );
  }

  void _viewPayments() {
    setState(() {
      _currentIndex = 2; // Switch to Finance tab
    });
  }

  void _findTenders() {
    setState(() {
      _currentIndex = 1; // Switch to Works tab
    });
  }

  void _addExpense() {
    setState(() {
      _currentIndex = 2; // Switch to Finance tab
    });
  }

  void _createInvoice() {
    setState(() {
      _currentIndex = 2; // Switch to Finance tab
    });
  }

  void _scanReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening camera for receipt scanning...')),
    );
  }

  void _openFullMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening full map view...')),
    );
  }
}