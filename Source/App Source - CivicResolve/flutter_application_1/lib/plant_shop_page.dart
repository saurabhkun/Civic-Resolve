import 'package:flutter/material.dart';
import 'credit_service.dart';

class PlantShopPage extends StatefulWidget {
  const PlantShopPage({super.key});

  @override
  State<PlantShopPage> createState() => _PlantShopPageState();
}

class _PlantShopPageState extends State<PlantShopPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _userCredits = 0;
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _plants = [
    {
      'name': 'Neem Tree',
      'price': 50,
      'description': 'Natural air purifier with medicinal properties',
      'icon': '🌿',
      'benefits': ['Air purification', 'Medicinal use', 'Insect repellent'],
      'color': const Color(0xFF22C55E),
    },
    {
      'name': 'Banyan Tree',
      'price': 75,
      'description': 'Majestic tree providing excellent shade',
      'icon': '🌳',
      'benefits': ['Massive shade', 'Oxygen production', 'Wildlife habitat'],
      'color': const Color(0xFF16A34A),
    },
    {
      'name': 'Mango Tree',
      'price': 60,
      'description': 'Fruit-bearing tree with delicious mangoes',
      'icon': '🥭',
      'benefits': ['Delicious fruits', 'Shade provider', 'Economic value'],
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'Tulsi Plant',
      'price': 25,
      'description': 'Sacred plant with healing properties',
      'icon': '🌱',
      'benefits': ['Medicinal properties', 'Spiritual significance', 'Easy care'],
      'color': const Color(0xFF059669),
    },
    {
      'name': 'Aloe Vera',
      'price': 30,
      'description': 'Succulent with healing and cosmetic uses',
      'icon': '🌵',
      'benefits': ['Skin healing', 'Low maintenance', 'Medicinal gel'],
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'Rose Plant',
      'price': 35,
      'description': 'Beautiful flowering plant with fragrant blooms',
      'icon': '🌹',
      'benefits': ['Beautiful flowers', 'Natural fragrance', 'Aesthetic appeal'],
      'color': const Color(0xFFE11D48),
    },
  ];

  @override
  void initState() {
    super.initState();
    
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
    
    _loadUserCredits();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCredits() async {
    try {
      const userId = 'user_12345'; // In real app, get from auth
      final credits = await CreditService.getUserTotalCredits(userId);
      setState(() {
        _userCredits = credits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userCredits = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePlant(Map<String, dynamic> plant) async {
    final price = plant['price'] as int;
    
    if (_userCredits < price) {
      _showInsufficientCreditsDialog(plant);
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showPurchaseConfirmationDialog(plant);
    if (!confirmed) return;

    try {
      const userId = 'user_12345';
      final success = await CreditService.spendCredits(
        userId,
        price,
        'Purchased ${plant['name']}',
      );

      if (success) {
        setState(() {
          _userCredits -= price;
        });
        _showSuccessDialog(plant);
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      _showErrorDialog();
    }
  }

  Future<bool> _showPurchaseConfirmationDialog(Map<String, dynamic> plant) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(plant['icon'], style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Purchase ${plant['name']}?',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: plant['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: plant['color'].withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cost:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${plant['price']} 🌱',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: plant['color'],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: plant['color'],
              foregroundColor: Colors.white,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showInsufficientCreditsDialog(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💸', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('Insufficient Credits'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You need ${plant['price']} 🌱 to purchase ${plant['name']}, but you only have $_userCredits 🌱.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Submit more reports to earn credits!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Text('${plant['name']} Purchased!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(plant['icon'], style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Congratulations! Your contribution to the environment will be planted and maintained by our partner organizations.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Amazing!'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('❌', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text('Purchase Failed'),
          ],
        ),
        content: const Text('Something went wrong. Please try again.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plant Shop',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  _isLoading ? '...' : '$_userCredits',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🌱',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Green Credits Store',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Exchange your civic contribution credits for plants that help the environment!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Available Plants',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPlantCard(_plants[index]),
                        childCount: _plants.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    final canAfford = _userCredits >= plant['price'];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: canAfford 
              ? plant['color'].withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: (canAfford ? plant['color'] : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canAfford ? () => _purchasePlant(plant) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plant['icon'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (canAfford ? plant['color'] : Colors.grey).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${plant['price']} 🌱',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: canAfford ? plant['color'] : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plant['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canAfford ? const Color(0xFF1E293B) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: canAfford ? Colors.grey[600] : Colors.grey[400],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (!canAfford)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Need ${plant['price'] - _userCredits} more 🌱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: plant['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tap to Purchase',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: plant['color'],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}