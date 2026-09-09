import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_profile_screen.dart';
import 'app_preferences.dart';

class ContractorProfilePage extends StatefulWidget {
  const ContractorProfilePage({super.key});

  @override
  State<ContractorProfilePage> createState() => _ContractorProfilePageState();
}

class _ContractorProfilePageState extends State<ContractorProfilePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data
  final double _rating = 4.8;
  final int _completedJobs = 127;
  final int _activeProjects = 5;
  final double _totalEarnings = 2850000; // ₹28.5L
  final int _yearsExperience = 8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
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
        backgroundColor: Colors.grey[50],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 320,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      onPressed: () => _editProfile(),
                    ),
                  ],
                ),
              ];
            },
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildPerformanceTab(),
                      _buildEquipmentTab(),
                      _buildComplianceTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFF667EEA),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            children: [
              // Profile Picture and Name
              Row(
                children: [
                  Hero(
                    tag: 'contractor_avatar',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.engineering,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rajesh Kumar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Civil Engineering Contractor',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber[300], size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '$_rating',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '($_completedJobs reviews)',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Stats Cards
              Row(
                children: [
                  _buildStatCard('Active Projects', '$_activeProjects', Icons.engineering),
                  const SizedBox(width: 12),
                  _buildStatCard('Completed', '$_completedJobs', Icons.check_circle),
                  const SizedBox(width: 12),
                  _buildStatCard('Experience', '${_yearsExperience}Y', Icons.timeline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Performance'),
          Tab(text: 'Equipment'),
          Tab(text: 'Compliance'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Information
          _buildSectionCard(
            title: 'Business Information',
            icon: Icons.business,
            children: [
              _buildInfoRow('Company Name', 'Kumar Construction Pvt. Ltd.'),
              _buildInfoRow('GST Number', '29ABCDE1234F1Z5'),
              _buildInfoRow('PAN Number', 'ABCDE1234F'),
              _buildInfoRow('License Number', 'CL/2019/12345'),
              _buildInfoRow('Registration Date', 'March 15, 2019'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contact Information
          _buildSectionCard(
            title: 'Contact Information',
            icon: Icons.contact_phone,
            children: [
              _buildInfoRow('Mobile', '+91 98765 43210'),
              _buildInfoRow('Email', 'rajesh@kumarconstruction.com'),
              _buildInfoRow('Office Address', '123, Industrial Area, Phase-1, Chandigarh'),
              _buildInfoRow('City', 'Chandigarh'),
              _buildInfoRow('State', 'Punjab'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Specializations
          _buildSectionCard(
            title: 'Specializations',
            icon: Icons.star_outline,
            children: [
              _buildSpecializationChips([
                'Road Construction',
                'Building Construction',
                'Water Supply',
                'Electrical Work',
                'Plumbing',
                'Landscaping',
              ]),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bank Details
          _buildSectionCard(
            title: 'Bank Details',
            icon: Icons.account_balance,
            children: [
              _buildInfoRow('Bank Name', 'State Bank of India'),
              _buildInfoRow('Account Number', '****7890'),
              _buildInfoRow('IFSC Code', 'SBIN0001234'),
              _buildInfoRow('Account Holder', 'Kumar Construction Pvt. Ltd.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Earnings Summary
          _buildSectionCard(
            title: 'Earnings Summary',
            icon: Icons.trending_up,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Lifetime Earnings',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '₹${(_totalEarnings / 100000).toStringAsFixed(1)}L',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildEarningsStat('This Month', '₹2.4L', Colors.blue),
                  const SizedBox(width: 12),
                  _buildEarningsStat('This Year', '₹18.5L', Colors.green),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Performance Metrics
          _buildSectionCard(
            title: 'Performance Metrics',
            icon: Icons.analytics,
            children: [
              _buildMetricRow('Bid Win Rate', '68%', 0.68, Colors.green),
              _buildMetricRow('On-Time Completion', '92%', 0.92, Colors.blue),
              _buildMetricRow('Client Satisfaction', '96%', 0.96, Colors.purple),
              _buildMetricRow('Quality Rating', '4.8/5', 0.96, Colors.orange),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent Achievements
          _buildSectionCard(
            title: 'Recent Achievements',
            icon: Icons.emoji_events,
            children: [
              _buildAchievementItem(
                'Top Performer',
                'Ranked #3 in Chandigarh region for Q3 2025',
                Icons.emoji_events,
                Colors.amber,
              ),
              _buildAchievementItem(
                'Quality Excellence',
                'Maintained 5-star rating for 6 consecutive months',
                Icons.star,
                Colors.blue,
              ),
              _buildAchievementItem(
                'Timely Delivery',
                'Completed 15 projects ahead of schedule this year',
                Icons.schedule,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Owned Equipment
          _buildSectionCard(
            title: 'Owned Equipment',
            icon: Icons.build,
            children: [
              _buildEquipmentItem('JCB 3DX Excavator', 'Available', Colors.green, 'JCB-001'),
              _buildEquipmentItem('Concrete Mixer (500L)', 'In Use - Job #CR-123', Colors.orange, 'CM-002'),
              _buildEquipmentItem('Crane (25 Ton)', 'Available', Colors.green, 'CR-003'),
              _buildEquipmentItem('Dumper Truck', 'Maintenance', Colors.red, 'DT-004'),
              _buildEquipmentItem('Compactor Roller', 'Available', Colors.green, 'CR-005'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Skills & Certifications
          _buildSectionCard(
            title: 'Skills & Certifications',
            icon: Icons.verified,
            children: [
              _buildSkillCategory('Construction Skills', [
                'Civil Engineering',
                'Project Management',
                'Safety Management',
                'Quality Control',
              ]),
              const SizedBox(height: 16),
              _buildSkillCategory('Certifications', [
                'ISO 9001:2015 Certified',
                'OSHA Safety Certified',
                'Green Building Certified',
                'PMP Certified',
              ]),
              const SizedBox(height: 16),
              _buildSkillCategory('Software Proficiency', [
                'AutoCAD',
                'MS Project',
                'Tally ERP',
                'CivicResolve Pro',
              ]),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Equipment Maintenance
          _buildSectionCard(
            title: 'Maintenance Schedule',
            icon: Icons.build_circle,
            children: [
              _buildMaintenanceItem('JCB 3DX Excavator', 'Next Service: Oct 15, 2025', false),
              _buildMaintenanceItem('Crane (25 Ton)', 'Overdue: Sep 10, 2025', true),
              _buildMaintenanceItem('Concrete Mixer', 'Next Service: Nov 5, 2025', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Document Status
          _buildSectionCard(
            title: 'Document Status',
            icon: Icons.description,
            children: [
              _buildComplianceItem('Contractor License', 'Valid until: Dec 31, 2025', true),
              _buildComplianceItem('GST Registration', 'Active', true),
              _buildComplianceItem('Insurance Policy', 'Valid until: Mar 15, 2026', true),
              _buildComplianceItem('Safety Certificate', 'Expires: Jan 20, 2026', false),
              _buildComplianceItem('Environmental Clearance', 'Renewal Due: Oct 30, 2025', false),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Upcoming Renewals
          _buildSectionCard(
            title: 'Upcoming Renewals',
            icon: Icons.notification_important,
            children: [
              _buildRenewalItem('Safety Certificate', 'Jan 20, 2026', 122),
              _buildRenewalItem('Environmental Clearance', 'Oct 30, 2025', 39),
              _buildRenewalItem('Equipment Insurance', 'Dec 15, 2025', 85),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tax & Financial Compliance
          _buildSectionCard(
            title: 'Tax & Financial Compliance',
            icon: Icons.receipt_long,
            children: [
              _buildInfoRow('Last GST Filing', 'August 2025 - Filed'),
              _buildInfoRow('Income Tax Status', '2024-25 - Filed'),
              _buildInfoRow('TDS Compliance', 'Up to date'),
              _buildInfoRow('PF Compliance', 'Up to date'),
              
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: () => _downloadComplianceReport(),
                icon: const Icon(Icons.download),
                label: const Text('Download Compliance Report'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Account Settings
          _buildSectionCard(
            title: 'Account Settings',
            icon: Icons.settings,
            children: [
              _buildSettingItem(
                'Notification Preferences',
                'Manage alerts and notifications',
                Icons.notifications,
                () => _openNotificationSettings(),
              ),
              _buildSettingItem(
                'Privacy Settings',
                'Control your data and visibility',
                Icons.privacy_tip,
                () => _openPrivacySettings(),
              ),
              _buildSettingItem(
                'Two-Factor Authentication',
                'Secure your account',
                Icons.security,
                () => _setup2FA(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Business Settings
          _buildSectionCard(
            title: 'Business Settings',
            icon: Icons.business_center,
            children: [
              _buildSettingItem(
                'Team Management',
                'Add and manage team members',
                Icons.group,
                () => _openTeamManagement(),
              ),
              _buildSettingItem(
                'Payment Settings',
                'Banking and payment preferences',
                Icons.payment,
                () => _openPaymentSettings(),
              ),
              _buildSettingItem(
                'Tax Configuration',
                'GST and tax settings',
                Icons.receipt,
                () => _openTaxSettings(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Support & Help
          _buildSectionCard(
            title: 'Support & Help',
            icon: Icons.help,
            children: [
              _buildSettingItem(
                'Help Center',
                'FAQs and tutorials',
                Icons.help_center,
                () => _openHelpCenter(),
              ),
              _buildSettingItem(
                'Contact Support',
                '24/7 customer support',
                Icons.support_agent,
                () => _contactSupport(),
              ),
              _buildSettingItem(
                'App Feedback',
                'Help us improve',
                Icons.feedback,
                () => _giveFeedback(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Danger Zone
          _buildSectionCard(
            title: 'Account Actions',
            icon: Icons.warning,
            children: [
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _logout(),
                icon: const Icon(Icons.logout, color: Colors.orange),
                label: const Text('Logout', style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _deleteAccount(),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationChips(List<String> specializations) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: specializations.map((spec) {
        return Chip(
          label: Text(spec),
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEarningsStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(String name, String status, Color statusColor, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.build, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: $id',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem(String equipment, String schedule, bool isOverdue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.schedule,
            color: isOverdue ? Colors.red : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  schedule,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(String document, String status, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.warning,
            color: isValid ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: isValid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalItem(String item, String date, int daysLeft) {
    final isUrgent = daysLeft <= 30;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? Colors.red.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            color: isUrgent ? Colors.red : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Due: $date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$daysLeft days',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Action Methods
  Future<void> _editProfile() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(
          initialProfile: {
            'name': 'Aarav Patel',
            'occupation': 'Registered Public Works Contractor',
            'phone': '+91 98765 43210',
            'address': 'Plot 45, Industrial Area, Sector 18, Gurgaon',
          },
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {});
    }
  }

  void _downloadComplianceReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading compliance report...')),
    );
  }

  void _openNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening notification settings...')),
    );
  }

  void _openPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy settings...')),
    );
  }

  void _setup2FA() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Setting up 2FA...')),
    );
  }

  void _openTeamManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening team management...')),
    );
  }

  void _openPaymentSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening payment settings...')),
    );
  }

  void _openTaxSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening tax settings...')),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening help center...')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacting support...')),
    );
  }

  void _giveFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening feedback form...')),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}