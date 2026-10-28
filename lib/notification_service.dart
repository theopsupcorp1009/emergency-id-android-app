import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> openDialer(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> init(Function(String?) onSelect) async {
    const androidInit =
    AndroidInitializationSettings('ic_notification');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId != null &&
            response.actionId!.startsWith("call_")) {
          final phone =
          response.actionId!.replaceFirst("call_", "").trim();

          if (phone.isNotEmpty) {
            await openDialer(phone);
            return;
          }
        }

        onSelect(response.payload);
      },
    );
  }

  static Future<void> showEmergencyNotification({
    required String name,
    required String age,
    required String blood,

    // backward compatibility
    required String phone,

    required String diabetes,
    required String asthma,
    required String inhaler,
    required String bp,
    required String allergy,
    required List<Map<String, dynamic>> contacts,
  }) async {

    // =========================
    // READ SETTINGS
    // =========================
    final prefs = await SharedPreferences.getInstance();

    final showCallButtons =
        prefs.getBool("showNotificationCallButtons") ?? false;

    final showAge =
        prefs.getBool("showNotificationAge") ?? true;

    final showBlood =
        prefs.getBool("showNotificationBlood") ?? true;

    final showDiabetes =
        prefs.getBool("showNotificationDiabetes") ?? true;

    final showAsthma =
        prefs.getBool("showNotificationAsthma") ?? true;

    final showBp =
        prefs.getBool("showNotificationBp") ?? true;

    final showAllergy =
        prefs.getBool("showNotificationAllergy") ?? true;

    // =========================
    // ACTION BUTTONS (CALL)
    // =========================
    final List<AndroidNotificationAction> actions = [];

    if (showCallButtons) {
      for (int i = 0; i < contacts.length && i < 3; i++) {
        final cName = (contacts[i]["name"] ?? "Contact").toString();
        final cPhone = (contacts[i]["phone"] ?? "").toString();

        if (cPhone.trim().isNotEmpty) {
          actions.add(
            AndroidNotificationAction(
              'call_$cPhone',
              'Call $cName',
              icon: DrawableResourceAndroidBitmap('ic_notification'),
              showsUserInterface: true,
            ),
          );
        }
      }
    }

// =========================
    // COMPACT MULTI-LINE FORMAT
    // =========================

    // Line 1: Name | Age | Blood
    String line1 = name;
    if (showAge) line1 += " | $age yr";
    if (showBlood) line1 += " | $blood";

    // Line 2: BP | Diabetes
    final List<String> line2Parts = [];
    if (showBp) line2Parts.add("BP: $bp");
    if (showDiabetes) line2Parts.add("Diabetes: $diabetes");
    final String line2 = line2Parts.join(" | ");

    // Line 3: Asthma
// Line 3: Asthma + Inhaler
    String line3 = "";
    if (showAsthma) {
      line3 = "Asthma: $asthma";
      if (asthma == "Yes" && inhaler != "N/A") {
        line3 += " | Inhaler: $inhaler";
      }
    }

    // Line 4: Allergy
    String line4 = "";
    if (showAllergy) {
      line4 = "Allergy: $allergy";
    }

    // Line 5: Contacts
    final List<String> contactParts = [];
    for (final c in contacts) {
      final cName = (c["name"] ?? "").toString();
      final cPhone = (c["phone"] ?? "").toString();
      if (cName.isNotEmpty && cPhone.isNotEmpty) {
        contactParts.add("$cName: $cPhone");
      }
    }
    final String line5 = contactParts.join(" | ");

    // Build full big text
    final StringBuffer bigTextBuffer = StringBuffer();
    bigTextBuffer.write(line1);
    if (line2.isNotEmpty) bigTextBuffer.write("\n$line2");
    if (line3.isNotEmpty) bigTextBuffer.write("\n$line3");
    if (line4.isNotEmpty) bigTextBuffer.write("\n$line4");
    if (line5.isNotEmpty) bigTextBuffer.write("\n$line5");

    final bigTextStyle = BigTextStyleInformation(
      bigTextBuffer.toString(),
      contentTitle: "🚨 EMERGENCY MEDICAL ID",
      summaryText: "Tap to Open",
    );

    // =========================
    // COLLAPSED NOTIFICATION
    // =========================
    String notificationText = name;
    if (showAge) notificationText += " | $age yr";
    if (showBlood) notificationText += " | $blood";

    // =========================
    // ANDROID DETAILS
    // =========================
    final androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Medical Info',
      channelDescription: 'Lock-screen emergency medical card',
      icon: 'ic_notification',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.service,
      fullScreenIntent: true,
      styleInformation: bigTextStyle,
      actions: actions,
    );

    final details = NotificationDetails(
      android: androidDetails,
    );

    // =========================
    // SHOW NOTIFICATION
    // =========================
    await _plugin.show(
      1,
      "🚨 EMERGENCY MEDICAL ID",
      notificationText,
      details,
      payload: "contacts",
    );
  }
  static Future<void> showReminderNotification() async {
    final prefs = await SharedPreferences.getInstance();

    final contactsJson = prefs.getString("contacts");

    List<Map<String, dynamic>> contacts = [];

    if (contactsJson != null && contactsJson.isNotEmpty) {
      contacts = List<Map<String, dynamic>>.from(
        jsonDecode(contactsJson),
      );
    }

    // Build allergy formatted string same way as EmergencyScreen
    final allergyStatus = prefs.getString("allergyStatus") ?? "Unknown";
    final allergyTypesJson = prefs.getString("allergyTypes");
    final allergyOther = prefs.getString("allergyOther") ?? "";

    List<String> allergyTypes = [];
    if (allergyTypesJson != null && allergyTypesJson.isNotEmpty) {
      allergyTypes = List<String>.from(jsonDecode(allergyTypesJson));
    }

    String allergyFormatted;
    if (allergyStatus == "Yes" && allergyTypes.isNotEmpty) {
      final displayList = allergyTypes.map((e) {
        return e == "Other" ? allergyOther : e;
      }).where((e) => e.isNotEmpty).toList();
      allergyFormatted = displayList.join(" | ");
    } else {
      allergyFormatted = allergyStatus; // "No" or "Unknown"
    }

    await showEmergencyNotification(
      name: prefs.getString("name") ?? "Not set",
      age: prefs.getString("age") ?? "Not set",
      blood: prefs.getString("blood") ?? "Not set",
      phone: contacts.isNotEmpty
          ? contacts.first["phone"] ?? ""
          : "",
      diabetes: prefs.getString("diabetes") ?? "No",
      asthma: prefs.getString("asthma") ?? "No",
      inhaler: prefs.getString("inhaler") ?? "N/A",
      bp: prefs.getString("bp") ?? "Not set",
      allergy: allergyFormatted,
      contacts: contacts,
    );
  }
}

