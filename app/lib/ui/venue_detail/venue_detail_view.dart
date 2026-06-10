import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import 'venue_detail_viewmodel.dart';
import '../login/login_viewmodel.dart';
import '../widgets/state_widgets.dart';
import '../widgets/slot_tile.dart';
import '../../data/models/venue.dart';

class VenueDetailView extends StatefulWidget {
  final Venue venue;

  const VenueDetailView({super.key, required this.venue});

  @override
  State<VenueDetailView> createState() => _VenueDetailViewState();
}

class _VenueDetailViewState extends State<VenueDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenueDetailViewModel>().fetchSlots(widget.venue.id);
    });
  }

  Future<void> _pickDate(VenueDetailViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      vm.setDate(picked);
      vm.fetchSlots(widget.venue.id);
    }
  }

  void _confirmBooking(int slotId, String displayTime) {
    final userId = context.read<LoginViewModel>().userId!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Booking',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Book $displayTime at ${widget.venue.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<VenueDetailViewModel>()
                  .bookSlot(slotId, userId, widget.venue.id);
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VenueDetailViewModel>();
    final userVm = context.watch<LoginViewModel>();

    // Snackbar feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.bookingSuccess != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.bookingSuccess!),
            backgroundColor: AppColors.success,
          ),
        );
        vm.clearBookingFeedback();
      }
      if (vm.bookingError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.bookingError!),
            backgroundColor: AppColors.error,
          ),
        );
        vm.clearBookingFeedback();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header with venue info
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // App bar row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.venue.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // balance
                    ],
                  ),
                ),

                // Venue details
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              widget.venue.location,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.venue.sport,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date picker
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _pickDate(vm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          vm.formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: IconButton(
                    onPressed: () => vm.fetchSlots(widget.venue.id),
                    icon: Icon(Icons.refresh_rounded,
                        color: AppColors.primary, size: 20),
                    constraints: const BoxConstraints(
                        minWidth: 38, minHeight: 38),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _legendDot(AppColors.success, 'Available'),
                const SizedBox(width: 16),
                _legendDot(AppColors.error, 'Booked'),
                const SizedBox(width: 16),
                _legendDot(AppColors.primary, 'Your Booking'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Slot grid
          Expanded(child: _buildSlotGrid(vm, userVm)),

          // Booking progress
          if (vm.isBooking)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Booking your slot...',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSlotGrid(VenueDetailViewModel vm, LoginViewModel userVm) {
    if (vm.isLoading) return const LoadingView();
    if (vm.error != null) {
      return ErrorView(
        message: vm.error!,
        onRetry: () => vm.fetchSlots(widget.venue.id),
      );
    }
    if (vm.slots.isEmpty) {
      return const EmptyView(
        message: 'No slots for this date',
        icon: Icons.event_busy,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: vm.slots.length,
      itemBuilder: (context, index) {
        final slot = vm.slots[index];
        return SlotTile(
          slot: slot,
          currentUserId: userVm.userId,
          onTap: () => _confirmBooking(slot.id, slot.displayTime),
        );
      },
    );
  }
}
