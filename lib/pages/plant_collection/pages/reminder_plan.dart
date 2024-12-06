import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:sprout/main.dart';
import 'package:sprout/pages/plant_collection/components/reminder_dialogue.dart';

import '../components/edit_reminder.dart';

class ReminderPlanWidget extends StatefulWidget {
  final String plantId; // Plant document ID
  final String collectionId; // Collection document ID
  final String plantName; // Plant name to display

  const ReminderPlanWidget({
    required this.plantId,
    required this.collectionId,
    required this.plantName,
    Key? key,
  }) : super(key: key);

  @override
  _ReminderPlanWidgetState createState() => _ReminderPlanWidgetState();
}

class _ReminderPlanWidgetState extends State<ReminderPlanWidget> {
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<List<Map<String, dynamic>>> _fetchReminders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('plant_collections')
          .doc(userEmail)
          .collection('plants')
          .doc(widget.plantId)
          .collection('reminders')
          .get();

      final reminders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      final now = DateTime.now();
      final matchingReminders = reminders.where((reminder) {
        final reminderDate = (reminder['reminder_date'] as Timestamp).toDate();
        return reminderDate.isAtSameMomentAs(now) ||
            (reminderDate.isAfter(now) && reminderDate.difference(now).inMinutes < 1);
      }).toList();

      for (var reminder in matchingReminders) {
        final activity = reminder['activity'] ?? 'Unknown Activity';
        _sendNotification(reminder['id'], activity);
      }

      return reminders;
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  Future<void> _sendNotification(String reminderId, String activity) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'plant_reminders_channel',
      'Plant Reminders',
      channelDescription: 'Notifications for plant care activities.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      reminderId.hashCode, // unique id for the notification
      'Reminder', // notification title
      activity, // notification body
      platformChannelSpecifics,
    );
  }

  Future<void> _deleteReminder(String reminderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('plant_collections')
          .doc(userEmail)
          .collection('plants')
          .doc(widget.plantId)
          .collection('reminders')
          .doc(reminderId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Reminder deleted successfully!'),
            backgroundColor: Colors.green),
      );
      setState(() {});
    } catch (e) {
      print('Error deleting reminder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete the reminder.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AddReminderDialog(
                plantName: widget.plantName,
                plantId: widget.plantId,
                userEmail: userEmail!,
              ),
            ),
            icon: const Icon(Icons.add_alarm, color: Colors.white),
            label: const Text('Add Reminder Plan',
                style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 69, 75, 69),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchReminders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('🌵 No reminders set.',
                          style: TextStyle(fontWeight: FontWeight.w600)));
                }

                final reminders = snapshot.data!;
                reminders.sort((b, a) {
                  final dateA =
                      (a['reminder_date'] as Timestamp).toDate();
                  final dateB =
                      (b['reminder_date'] as Timestamp).toDate();
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final reminderId = reminder['id'];
                    final activity =
                        reminder['activity'] ?? 'Unknown Activity';
                    final reminderDate =
                        (reminder['reminder_date'] as Timestamp).toDate();
                    final formattedDate = DateFormat(
                            'MMMM dd, yyyy - hh:mm a')
                        .format(reminderDate);

                    return Dismissible(
                      key: Key(reminderId),
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Reminder'),
                              content: const Text(
                                  'Are you sure you want to delete this reminder?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _deleteReminder(reminderId);
                          }
                        } else if (direction ==
                            DismissDirection.startToEnd) {
                          showDialog(
                            context: context,
                            builder: (context) => EditReminderDialog(
                              reminderId: reminderId,
                              plantId: widget.plantId,
                              currentActivity: activity,
                              currentReminderDate: reminderDate,
                              userEmail: userEmail!,
                            ),
                          );
                        }
                        setState(() {});
                      },
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.lightBlueAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete,
                                color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(formattedDate,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600])),
                                  const SizedBox(height: 4),
                                  Text(activity,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.arrow_left, size: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
