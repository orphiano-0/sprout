import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditReminderDialog extends StatefulWidget {
  final String reminderId;
  final String plantId;
  final String userEmail;
  final String currentActivity;
  final DateTime currentReminderDate;

  const EditReminderDialog({
    required this.reminderId,
    required this.plantId,
    required this.userEmail,
    required this.currentActivity,
    required this.currentReminderDate,
    Key? key,
  }) : super(key: key);

  @override
  _EditReminderDialogState createState() => _EditReminderDialogState();
}

class _EditReminderDialogState extends State<EditReminderDialog> {
  String? selectedActivity;
  TimeOfDay? selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.currentActivity;
    selectedTime = TimeOfDay.fromDateTime(widget.currentReminderDate);
  }

  Future<void> updateReminder() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // Combine date and time
      DateTime updatedReminderDate = DateTime(
        widget.currentReminderDate.year,
        widget.currentReminderDate.month,
        widget.currentReminderDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance
          .collection('plant_collections')
          .doc(widget.userEmail)
          .collection('plants')
          .doc(widget.plantId)
          .collection('reminders')
          .doc(widget.reminderId)
          .update({
        'activity': selectedActivity,
        'reminder_date': Timestamp.fromDate(updatedReminderDate),
      });

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update reminder. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedActivity,
              onChanged: (value) => setState(() => selectedActivity = value),
              items: const [
                DropdownMenuItem(value: '💦 Watering', child: Text('💦 Watering')),
                DropdownMenuItem(value: '🌱 Fertilizing', child: Text('🌱 Fertilizing')),
                DropdownMenuItem(value: '🪴 Potting', child: Text('🪴 Potting')),
              ],
              decoration: const InputDecoration(
                labelText: 'Activity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Select Time"),
              subtitle: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'No time selected',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: _isSaving
              ? null // Disable button when saving
              : () async {
                  if (selectedActivity != null && selectedTime != null) {
                    await updateReminder();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please complete all fields.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
          child: Text(
            _isSaving ? 'Saving...' : 'Save',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
