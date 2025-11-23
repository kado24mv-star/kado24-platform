import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/voucher_card.dart';
import '../search/search_results_screen.dart';
import '../notifications/notifications_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../orders/order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VoucherProvider>().loadCategories(context: context);
      context.read<VoucherProvider>().loadVouchers(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _VoucherSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: _getBodyForIndex(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF667EEA),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<VoucherProvider>(
      builder: (context, voucherProvider, child) {
        if (voucherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (voucherProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(voucherProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => voucherProvider.loadVouchers(context: context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => voucherProvider.loadVouchers(context: context),
          child: CustomScrollView(
            slivers: [
              // Categories
              SliverToBoxAdapter(
                child: _buildCategories(context, voucherProvider.categories),
              ),
              
              // Vouchers
              voucherProvider.vouchers.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No vouchers available',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return VoucherCard(voucher: voucherProvider.vouchers[index]);
                          },
                          childCount: voucherProvider.vouchers.length,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories(BuildContext context, List<dynamic> categories) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final voucherProvider = Provider.of<VoucherProvider>(context, listen: true);

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category['name']),
              avatar: Text(category['iconUrl'] ?? '🎁'),
              selected: voucherProvider.selectedCategoryId == category['id'],
              onSelected: (selected) {
                if (selected) {
                  voucherProvider.filterByCategory(category['id'], context: context);
                } else {
                  voucherProvider.clearCategoryFilter(context: context);
                }
              },
            ),
          );
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Kado24';
      case 1:
        return 'My Wallet';
      case 2:
        return 'Profile';
      default:
        return 'Kado24';
    }
  }

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const WalletScreen(showAppBar: false);
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildProfileTab() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Extract first name or use full name, remove "Shop" if present
    String displayName = user.fullName;
    if (displayName.toLowerCase().contains("'s shop") || 
        displayName.toLowerCase().endsWith(" shop")) {
      // Remove shop suffix for consumer display
      displayName = displayName
          .replaceAll(RegExp(r"'s\s*shop", caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+shop$', caseSensitive: false), '')
          .trim();
    }

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF667EEA),
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.avatarUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            displayName.isNotEmpty 
                                ? displayName[0].toUpperCase() 
                                : 'U',
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          );
                        },
                      ),
                    )
                  : Text(
                      displayName.isNotEmpty 
                          ? displayName[0].toUpperCase() 
                          : 'U',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 20),
            // User Name
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Phone Number
            Text(
              user.phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            if (user.email != null && user.email!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.email!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 40),
            // Profile Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileActionTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // Always allow navigation - EditProfileScreen will handle auth check on save
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileActionTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Order History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildProfileActionTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF667EEA)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _VoucherSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }
    return SearchResultsScreen(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as user types
    return Consumer<VoucherProvider>(
      builder: (context, provider, child) {
        if (query.isEmpty) {
          return const Center(child: Text('Start typing to search...'));
        }
        // Auto-search as user types
        Future.microtask(() {
          provider.searchVouchers(query, context: context);
        });
        return SearchResultsScreen(query: query);
      },
    );
  }
}

























