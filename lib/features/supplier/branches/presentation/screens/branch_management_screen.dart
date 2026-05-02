import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/branch_mock_store.dart';
import '../../domain/entities/branch_entity.dart';
import '../widgets/branch_card.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  List<BranchEntity> get _filteredBranches {
    return BranchMockStore.searchBranches(_searchText);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToAddBranch() async {
    await context.push<BranchEntity>('/supplier-branches/add');
    setState(() {});
  }

  Future<void> _goToEditBranch(BranchEntity branch) async {
    await context.push<BranchEntity>(
      '/supplier-branches/edit',
      extra: branch,
    );

    setState(() {});
  }

  Future<void> _goToInventory(BranchEntity branch) async {
  await context.push('/supplier-branches/inventory', extra: branch);

  setState(() {});
}

  void _deleteBranch(BranchEntity branch) {
    setState(() {
      BranchMockStore.deleteBranch(branch.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${branch.name} deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppThemeTokens.background,
      drawer: const SupplierAppDrawer(),
      appBar: AppBar(
        backgroundColor: AppThemeTokens.background,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            );
          },
        ),
        title: const Text(
          'Branch\nManagement',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppThemeTokens.textPrimary,
            height: 1.15,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _goToAddBranch,
            icon: Icon(
              Icons.add_circle,
              color: primaryColor,
              size: 31,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search branches...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppThemeTokens.textSecondary,
                ),
                filled: true,
                fillColor: AppThemeTokens.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppThemeTokens.radiusSmall,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppThemeTokens.border),
          Expanded(
            child: _filteredBranches.isEmpty
                ? const _EmptyBranchesView()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBranches.length,
                    itemBuilder: (context, index) {
                      final branch = _filteredBranches[index];

                      return BranchCard(
                        branch: branch,
                        totalProducts:
                            BranchMockStore.getTotalProductsByBranchId(
                          branch.id,
                        ),
                        totalStock: BranchMockStore.getTotalStockByBranchId(
                          branch.id,
                        ),
                        onEdit: () => _goToEditBranch(branch),
                        onDelete: () => _deleteBranch(branch),
                        onViewInventory: () => _goToInventory(branch),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBranchesView extends StatelessWidget {
  const _EmptyBranchesView();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 58,
              color: primaryColor,
            ),
            const SizedBox(height: 14),
            const Text(
              'No branches found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add branches to manage stock and inventory by location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}