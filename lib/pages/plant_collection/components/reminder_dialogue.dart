import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AddReminderDialog extends StatefulWidget {
  final String plantName;
  final String plantId;
  final String userEmail;

  const AddReminderDialog({
    required this.plantName,
    required this.plantId,
    required this.userEmail,
    Key? key,
  }) : super(key: key);

  @override
  _AddReminderDialogState createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  String? selectedActivity;
  String? selectedLastActivity;
  TimeOfDay? _selectedTime;
  final TextEditingController _frequencyController = TextEditingController();
  bool _isSaving = false; // Add a flag to track saving state

  Future<List<Map<String, String>>> generateYearlyPlans({
    required String activity,
    required DateTime lastActivityDate,
    required int intervalDays,
    required TimeOfDay time,
  }) async {
    List<Map<String, String>> plans = [];
    DateTime nextActivityDate = lastActivityDate.add(Duration(days: intervalDays));
    final DateTime endDate = DateTime.now().add(const Duration(days: 90));

    while (nextActivityDate.isBefore(endDate)) {
      final DateTime fullDateTime = DateTime(
        nextActivityDate.year,
        nextActivityDate.month,
        nextActivityDate.day,
        time.hour,
        time.minute,
      );

      String readableDate = DateFormat('MMMM dd, yyyy').format(fullDateTime);
      String readableTime = DateFormat('hh:mm a').format(fullDateTime);

      plans.add({
        'date': readableDate,
        'time': readableTime,
        'activity': activity,
      });

      nextActivityDate = nextActivityDate.add(Duration(days: intervalDays));
    }

    return plans;
  }

  Future<void> savePlansToFirestore(List<Map<String, String>> plans) async {
    final userEmail = widget.userEmail;
    final plantId = widget.plantId;

    for (var plan in plans) {
      await FirebaseFirestore.instance
          .collection('plant_collections')
          .doc(userEmail)
          .collection('plants')
          .doc(plantId)
          .collection('reminders')
          .add({
        'activity': plan['activity'],
        'reminder_date': Timestamp.fromDate(
          DateFormat('MMMM dd, yyyy hh:mm a').parse('${plan['date']} ${plan['time']}'),
        ),
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Reminder Plan for ${widget.plantName}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
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
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'No time selected',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Remind me every (days)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              ? null // Disable the button if already saving
              : () async {
                  if (selectedActivity != null &&
                      _selectedTime != null &&
                      _frequencyController.text.isNotEmpty) {
                    try {
                      setState(() {
                        _isSaving = true; // Set saving state
                      });

                      int intervalDays = int.parse(_frequencyController.text);
                      DateTime lastActivityDate = DateTime.now().subtract(Duration(days: 1));
                      List<Map<String, String>> plans = await generateYearlyPlans(
                        activity: selectedActivity!,
                        lastActivityDate: lastActivityDate,
                        intervalDays: intervalDays,
                        time: _selectedTime!,
                      );

                      // Save plans to Firestore
                      await savePlansToFirestore(plans);

                      // Show success notification
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reminder plan for ${widget.plantName} has been successfully added!',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      Navigator.pop(context); // Close the dialog
                    } catch (e) {
                      // Handle errors and notify the user
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to save reminder plan. Please try again.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          _isSaving = false; // Reset saving state
                        });
                      }
                    }
                  } else {
                    // Show a warning if any input is missing
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all fields before saving.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
          child: Text(
            _isSaving ? 'Saving...' : 'Save', // Update button text
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}