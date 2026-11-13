import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/secure_storage.dart';

class BusinessSummary {
  const BusinessSummary({
    required this.id,
    required this.name,
    this.category,
    this.phone,
    this.email,
    this.currency = 'NGN',
    this.country = 'NG',
    this.logoUrl,
    this.status,
    this.roleId,
    this.roleName,
    this.branchId,
    this.branchName,
  });
  final String id;
  final String name;
  final String? category;
  final String? phone;
  final String? email;
  final String currency;
  final String country;
  final String? logoUrl;
  final String? status;
  final String? roleId;
  final String? roleName;
  final String? branchId;
  final String? branchName;

  factory BusinessSummary.fromJson(Map<String, dynamic> json) {
    final business = (json['business'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final role = (json['role'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final branch = (json['branch'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return BusinessSummary(
      id: business['id'] as String? ?? json['businessId'] as String? ?? '',
      name: business['name'] as String? ?? '',
      category: business['category'] as String?,
      phone: business['phone'] as String?,
      email: business['email'] as String?,
      currency: business['currency'] as String? ?? 'NGN',
      country: business['country'] as String? ?? 'NG',
      logoUrl: business['logoUrl'] as String?,
      status: business['status'] as String?,
      roleId: role['id'] as String? ?? json['roleId'] as String?,
      roleName: role['name'] as String?,
      branchId: branch['id'] as String? ?? json['branchId'] as String?,
      branchName: branch['name'] as String?,
    );
  }
}

class BusinessState {
  const BusinessState({
    this.memberships = const <BusinessSummary>[],
    this.activeBusinessId,
    this.activeBranchId,
    this.isLoading = false,
    this.error,
  });
  final List<BusinessSummary> memberships;
  final String? activeBusinessId;
  final String? activeBranchId;
  final bool isLoading;
  final String? error;

  BusinessSummary? get activeBusiness =>
      memberships.where((m) => m.id == activeBusinessId).firstOrNull;

  bool get hasBusiness => memberships.isNotEmpty;
  bool get hasActiveBusiness => activeBusinessId != null;

  BusinessState copyWith({
    List<BusinessSummary>? memberships,
    String? activeBusinessId,
    String? activeBranchId,
    bool? isLoading,
    String? error,
  }) {
    return BusinessState(
      memberships: memberships ?? this.memberships,
      activeBusinessId: activeBusinessId ?? this.activeBusinessId,
      activeBranchId: activeBranchId ?? this.activeBranchId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BusinessNotifier extends StateNotifier<BusinessState> {
  BusinessNotifier(this._api) : super(BusinessState());

  final ApiClient _api;

  Future<void> bootstrap() async {
    final activeBiz = await SecureStorage.getActiveBusinessId();
    final activeBranch = await SecureStorage.getActiveBranchId();
    state = BusinessState(
      activeBusinessId: activeBiz,
      activeBranchId: activeBranch,
    );
    await fetchMemberships();
  }

  Future<void> fetchMemberships() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _api;
      final response = await api.listBusinesses({});
      final List<BusinessSummary> items =
          response.items.map(BusinessSummary.fromJson).toList();
      BusinessSummary? active;
      if (state.activeBusinessId != null) {
        try {
          active = items.firstWhere((b) => b.id == state.activeBusinessId);
        } catch (_) {
          active = null;
        }
      }
      active ??= items.isNotEmpty ? items.first : null;
      state = state.copyWith(
        memberships: items,
        activeBusinessId: active?.id,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setActiveBusiness(String businessId) async {
    await SecureStorage.setActiveBusinessId(businessId);
    // Find the matching membership and use its branchId if available
    final membership = state.memberships.where((m) => m.id == businessId).firstOrNull;
    final branchId = membership?.branchId;
    if (branchId != null) {
      await SecureStorage.setActiveBranchId(branchId);
    }
    state = state.copyWith(activeBusinessId: businessId, activeBranchId: branchId);
  }

  Future<void> setActiveBranch(String branchId) async {
    await SecureStorage.setActiveBranchId(branchId);
    state = state.copyWith(activeBranchId: branchId);
  }

  /// Alias for [fetchMemberships] (used by the dashboard).
  Future<void> refreshBusinesses() => fetchMemberships();

  void clear() {
    state = BusinessState();
  }
}

final businessProvider =
    StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  final api = ref.watch(apiClientProvider);
  return BusinessNotifier(api);
});
