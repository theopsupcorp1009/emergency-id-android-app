import 'package:workmanager/workmanager.dart';

class ReminderService {
  static const _taskName = "emergency_reminder";
  static const _taskTag = "emergency_reminder_tag";

  static Future<void> registerReminder(String interval) async {
    await cancelReminder();

    if (interval == "Off") return;

    int minutes;

    switch (interval) {
      case "20 min":
        minutes = 20;
        break;
      case "30 min":
        minutes = 30;
        break;
      case "40 min":
        minutes = 40;
        break;
      case "50 min":
        minutes = 50;
        break;
      case "60 min":
        minutes = 60;
        break;
      default:
        minutes = 15;
    }

    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      tag: _taskTag,
      frequency: Duration(minutes: minutes),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  }

  static Future<void> cancelReminder() async {
    await Workmanager().cancelByTag(_taskTag);
  }
}