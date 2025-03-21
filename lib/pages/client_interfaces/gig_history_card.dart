// gig_history_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/gig_model.dart';

class GigHistoryCard extends StatelessWidget {
  final GigModel gig;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const GigHistoryCard({
    Key? key,
    required this.gig,
    required this.onTap,
    this.onCancel,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    final startDate = dateFormat.format(gig.startDate);

    // Format time
    final startTime = TimeOfDay(
      hour: gig.startTime['hour'] ?? 0,
      minute: gig.startTime['minute'] ?? 0,
    );

    final endTime = TimeOfDay(
      hour: gig.endTime['hour'] ?? 0,
      minute: gig.endTime['minute'] ?? 0,
    );

    // Get status color
    Color statusColor;
    IconData statusIcon;

    switch (gig.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = const Color(0xFF40189D);
        statusIcon = Icons.task_alt;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and date row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      gig.category,
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Status indicator
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gig.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                gig.description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Date and time row
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    startDate,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${startTime.format(context)} - ${endTime.format(context)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      gig.address,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${gig.hourlyRate.toStringAsFixed(2)}/hr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF40189D),
                        ),
                      ),
                    ],
                  ),

                  // Action buttons for pending gigs
                  if (onCancel != null || onDelete != null)
                    Row(
                      children: [
                        if (onCancel != null)
                          TextButton.icon(
                            onPressed: onCancel,
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        if (onDelete != null)
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}