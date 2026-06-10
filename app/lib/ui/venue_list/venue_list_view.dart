import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import 'venue_list_viewmodel.dart';
import '../login/login_viewmodel.dart';
import '../venue_detail/venue_detail_view.dart';
import '../widgets/state_widgets.dart';

class VenueListView extends StatefulWidget {
  const VenueListView({super.key});

  @override
  State<VenueListView> createState() => _VenueListViewState();
}

class _VenueListViewState extends State<VenueListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenueListViewModel>().fetchVenues();
    });
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'badminton':
        return Icons.sports_tennis;
      case 'football':
        return Icons.sports_soccer;
      case 'cricket':
        return Icons.sports_cricket;
      default:
        return Icons.sports;
    }
  }

  Color _getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'badminton':
        return const Color(0xFF6C5CE7);
      case 'football':
        return const Color(0xFF00B894);
      case 'cricket':
        return const Color(0xFFE17055);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VenueListViewModel>();
    final userVm = context.watch<LoginViewModel>();
    final user = userVm.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Modern gradient header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                bottom: 28,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
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
                              'Hey ${user?.name.split(' ').first ?? ''} 👋',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Find and book your next game',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // User avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            user?.avatar ?? '🏸',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                children: [
                  const Text(
                    'Available Venues',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${vm.venues.length} venues',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (vm.isLoading)
            const SliverFillRemaining(child: LoadingView())
          else if (vm.error != null)
            SliverFillRemaining(
              child: ErrorView(message: vm.error!, onRetry: vm.fetchVenues),
            )
          else if (vm.venues.isEmpty)
            const SliverFillRemaining(
              child: EmptyView(
                message: 'No venues available',
                icon: Icons.location_off,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final venue = vm.venues[index];
                    final sportColor = _getSportColor(venue.sport);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VenueDetailView(venue: venue),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.grey.shade100,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Sport icon
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: sportColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _getSportIcon(venue.sport),
                                    color: sportColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venue.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: sportColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              venue.sport,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: sportColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.location_on_outlined,
                                              size: 13,
                                              color: AppColors.textHint),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              venue.location,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: vm.venues.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
