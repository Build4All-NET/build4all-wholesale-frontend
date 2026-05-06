import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../injection_container.dart';
import '../../../shared/widgets/supplier_app_drawer.dart';
import '../../data/models/branch_model.dart';
import '../../domain/entities/branch_entity.dart';
import '../bloc/branch_list/branch_list_bloc.dart';
import '../bloc/branch_list/branch_list_event.dart';
import '../bloc/branch_list/branch_list_state.dart';
import '../widgets/branch_card.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BranchListBloc _branchListBloc = sl<BranchListBloc>();

  Timer? _searchDebounce;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _branchListBloc.add(const LoadBranches());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _branchListBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchText = value;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        _branchListBloc.add(SearchBranches(value));
      },
    );
  }

  Future<void> _goToAddBranch() async {
    final result = await context.push<BranchEntity>('/supplier-branches/add');

    if (result != null) {
      _branchListBloc.add(
        _searchText.trim().isEmpty
            ? const LoadBranches()
            : SearchBranches(_searchText),
      );
    }
  }

  Future<void> _goToEditBranch(BranchEntity branch) async {
    final result = await context.push<BranchEntity>(
      '/supplier-branches/edit',
      extra: branch,
    );

    if (result != null) {
      _branchListBloc.add(
        _searchText.trim().isEmpty
            ? const LoadBranches()
            : SearchBranches(_searchText),
      );
    }
  }

  Future<void> _goToInventory(BranchEntity branch) async {
    await context.push('/supplier-branches/inventory', extra: branch);

    _branchListBloc.add(
      _searchText.trim().isEmpty
          ? const LoadBranches()
          : SearchBranches(_searchText),
    );
  }

  Future<void> _deleteBranch(BranchEntity branch) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Branch',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Are you sure you want to delete ${branch.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    _branchListBloc.add(DeleteBranchRequested(branch.id));
  }

  Future<void> _refreshBranches() async {
    _branchListBloc.add(
      _searchText.trim().isEmpty
          ? const LoadBranches()
          : SearchBranches(_searchText),
    );
  }

  int _getTotalProducts(BranchEntity branch) {
    if (branch is BranchModel) {
      return branch.totalProducts;
    }

    return 0;
  }

  int _getTotalStock(BranchEntity branch) {
    if (branch is BranchModel) {
      return branch.totalStock;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BranchListBloc>.value(
      value: _branchListBloc,
      child: BlocListener<BranchListBloc, BranchListState>(
        listenWhen: (previous, current) {
          return previous.error != current.error ||
              previous.successMessage != current.successMessage;
        },
        listener: (context, state) {
          if (state.error != null && state.error!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }

          if (state.successMessage != null &&
              state.successMessage!.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        child: BlocBuilder<BranchListBloc, BranchListState>(
          builder: (context, state) {
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
                      onChanged: _onSearchChanged,
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
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state.branches.isEmpty
                            ? const _EmptyBranchesView()
                            : RefreshIndicator(
                                onRefresh: _refreshBranches,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: state.branches.length,
                                  itemBuilder: (context, index) {
                                    final branch = state.branches[index];

                                    return BranchCard(
                                      branch: branch,
                                      totalProducts:
                                          _getTotalProducts(branch),
                                      totalStock: _getTotalStock(branch),
                                      onEdit: () => _goToEditBranch(branch),
                                      onDelete: state.isDeleting
                                          ? () {}
                                          : () => _deleteBranch(branch),
                                      onViewInventory: () =>
                                          _goToInventory(branch),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            );
          },
        ),
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