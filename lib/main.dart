import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'reminder_service.dart';
import 'package:workmanager/workmanager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔧 Adjust these to resize/restyle the splash screen content
const double kSplashLogoSize = 120;
const double kSplashTextSize = 30;
const double kSplashTaglineSize = 18;
const double kSplashSpacing = 12; // Adjusted slightly for breathing room
const String kSplashTagline = "Speak For Yourself, Even When You Can’t!";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Foreground animations
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _shimmerProgress;

  // Background animations (Heartbeat double-pulse curves)
  late final Animation<double> _pulseOne;
  late final Animation<double> _pulseTwo;

  @override
  void initState() {
    super.initState();

    // Duration extended slightly to allow the double-pulse and shimmer to fully breathe
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Standard foreground curves
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Shimmer effect sweeping timeline (starts right as scale finishes)
    _shimmerProgress = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Heartbeat Pulse 1 (The "Lub")
    _pulseOne = Tween<double>(begin: 0.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    // Heartbeat Pulse 2 (The "Dub" - starts slightly delayed and expands larger)
    _pulseTwo = Tween<double>(begin: 0.0, end: 2.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. Full-Screen Ambient Gradient Background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: _controller.value * 2.5,
                    colors: [
                      Colors.red.shade50.withValues(alpha: 0.6),
                      Colors.white,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),

              // 2. Heartbeat Background Pulse 1 ("Lub")
              Center(
                child: Opacity(
                  opacity: (1.0 - (_pulseOne.value / 1.8)).clamp(0.0, 0.12),
                  child: Container(
                    width: 300 * _pulseOne.value,
                    height: 300 * _pulseOne.value,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // 3. Heartbeat Background Pulse 2 ("Dub")
              Center(
                child: Opacity(
                  opacity: (1.0 - (_pulseTwo.value / 2.4)).clamp(0.0, 0.08),
                  child: Container(
                    width: 300 * _pulseTwo.value,
                    height: 300 * _pulseTwo.value,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // 4. Existing Foreground Assets + Premium Shimmer
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon.png',
                          width: kSplashLogoSize,
                          height: kSplashLogoSize,
                        ),
                        SizedBox(height: kSplashSpacing),

                        // Metallic Shimmering App Title
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: const [
                                Colors.red,
                                Colors.white, // The shining metallic band
                                Colors.red,
                              ],
                              stops: [
                                (_shimmerProgress.value - 0.3).clamp(-1.0, 1.0),
                                _shimmerProgress.value.clamp(-1.0, 1.0),
                                (_shimmerProgress.value + 0.3).clamp(-1.0, 1.0),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            "QMedID",
                            style: TextStyle(
                              fontSize: kSplashTextSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Must be white for ShaderMask to overlay correctly
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          kSplashTagline,
                          style: TextStyle(
                            fontSize: kSplashTaglineSize,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.showReminderNotification();
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  await NotificationService.init((payload) {
    if (payload == "contacts") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const EmergencyScreen(openContacts: true),
        ),
      );
    }
  });

  runApp(const EmergencyIDApp());
}

/* ===================== APP ===================== */

class EmergencyIDApp extends StatefulWidget {
  const EmergencyIDApp({super.key});

  static _EmergencyIDAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_EmergencyIDAppState>()!;

  @override
  State<EmergencyIDApp> createState() => _EmergencyIDAppState();
}

class _EmergencyIDAppState extends State<EmergencyIDApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool("darkMode") ?? false;

    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);

    setState(() {
      _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      themeMode: _themeMode,

      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}

class PermissionGateScreen extends StatefulWidget {
  final Widget nextScreen;

  const PermissionGateScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<PermissionGateScreen> createState() =>
      _PermissionGateScreenState();
}

class _PermissionGateScreenState
    extends State<PermissionGateScreen> {

  bool notificationGranted = false;
  bool showCallButtons = false;
  bool showAge = true;
  bool showBlood = true;
  bool showDiabetes = true;
  bool showAsthma = true;
  bool showAllergy = true;
  bool showBp = true;
  bool darkMode = false;
  bool hasProfile = false;
  String reminderInterval = "15 min";

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final status = await Permission.notification.status;
    final prefs = await SharedPreferences.getInstance();

    final savedName = (prefs.getString("name") ?? "").trim();

    final savedReminder = savedName.isNotEmpty
        ? (prefs.getString("reminderInterval") ?? "15 min")
        : "Off";

    if (savedReminder != "Off") {
      await ReminderService.registerReminder(savedReminder);
    }

    setState(() {
      notificationGranted = status.isGranted;

      hasProfile = savedName.isNotEmpty;

      showCallButtons =
          prefs.getBool("showNotificationCallButtons") ?? false;

      showAge =
          prefs.getBool("showNotificationAge") ?? true;

      showBlood =
          prefs.getBool("showNotificationBlood") ?? true;

      showDiabetes =
          prefs.getBool("showNotificationDiabetes") ?? true;

      showAsthma =
          prefs.getBool("showNotificationAsthma") ?? true;

      showAllergy =
          prefs.getBool("showNotificationAllergy") ?? true;

      showBp =
          prefs.getBool("showNotificationBp") ?? true;

      darkMode =
          prefs.getBool("darkMode") ?? false;

      reminderInterval = savedReminder;
    });
  }

  Future<void> saveSetting(
      String key,
      bool value,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> requestNotification() async {
    final result = await Permission.notification.request();

    setState(() {
      notificationGranted = result.isGranted;
    });
  }

  Future<void> saveReminderInterval(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("reminderInterval", value);

    setState(() {
      reminderInterval = value;
    });

    if (value == "Off") {
      await ReminderService.cancelReminder();
    } else {
      await ReminderService.registerReminder(value);
    }
  }

  void continueApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.nextScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "QMedID Settings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                title: const Text("Notifications"),
                subtitle: Text(
                  notificationGranted
                      ? "Enabled"
                      : "Not enabled",
                ),
                trailing: ElevatedButton(
                  onPressed: notificationGranted ? null : requestNotification,
                  child: const Text("Enable"),
                ),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Reminder"),
                trailing: DropdownButton<String>(
                  value: reminderInterval,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: "Off",
                      enabled: !hasProfile,
                      child: Text(
                        "Off",
                        style: TextStyle(color: hasProfile ? Colors.grey : null),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "15 min",
                      enabled: hasProfile,
                      child: Text("15 min", style: TextStyle(color: !hasProfile ? Colors.grey : null)),
                    ),
                    DropdownMenuItem(
                      value: "20 min",
                      enabled: hasProfile,
                      child: Text("20 min", style: TextStyle(color: !hasProfile ? Colors.grey : null)),
                    ),
                    DropdownMenuItem(
                      value: "30 min",
                      enabled: hasProfile,
                      child: Text("30 min", style: TextStyle(color: !hasProfile ? Colors.grey : null)),
                    ),
                    DropdownMenuItem(
                      value: "40 min",
                      enabled: hasProfile,
                      child: Text("40 min", style: TextStyle(color: !hasProfile ? Colors.grey : null)),
                    ),
                    DropdownMenuItem(
                      value: "50 min",
                      enabled: hasProfile,
                      child: Text("50 min", style: TextStyle(color: !hasProfile ? Colors.grey : null)),
                    ),
                    DropdownMenuItem(
                      value: "60 min",
                      enabled: hasProfile,
                      child: Text("60 min", style: TextStyle(color: !hasProfile ? Colors.grey : null)),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      await saveReminderInterval(value);
                    }
                  },
                ),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: darkMode,
                  onChanged: (value) async {
                    await saveSetting("darkMode", value);

                    setState(() {
                      darkMode = value;
                    });

                    if (context.mounted) {
                      EmergencyIDApp.of(context).setDarkMode(value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Divider(),

            const SizedBox(height: 10),

            const Text(
              "Notification Visibility",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SwitchListTile(
              title: const Text(
                "Show Call Buttons",
              ),
              value: showCallButtons,
              onChanged: (value) async {
                await saveSetting(
                  "showNotificationCallButtons",
                  value,
                );

                setState(() {
                  showCallButtons = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text(
                "Show Age",
              ),
              value: showAge,
              onChanged: (value) async {
                await saveSetting(
                  "showNotificationAge",
                  value,
                );

                setState(() {
                  showAge = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text(
                "Show Blood Group",
              ),
              value: showBlood,
              onChanged: (value) async {
                await saveSetting(
                  "showNotificationBlood",
                  value,
                );

                setState(() {
                  showBlood = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text(
                "Show Diabetes",
              ),
              value: showDiabetes,
              onChanged: (value) async {
                await saveSetting(
                  "showNotificationDiabetes",
                  value,
                );

                setState(() {
                  showDiabetes = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text(
                "Show Asthma",
              ),
              value: showAsthma,
              onChanged: (value) async {
                await saveSetting(
                  "showNotificationAsthma",
                  value,
                );

                setState(() {
                  showAsthma = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text("Show Allergy"),
              value: showAllergy,
              onChanged: (value) async {
                await saveSetting("showNotificationAllergy", value);
                setState(() {
                  showAllergy = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text(
                "Show Blood Pressure",
              ),
              value: showBp,
              onChanged: (value) async {
                await saveSetting(
                  "showNotificationBp",
                  value,
                );

                setState(() {
                  showBp = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: continueApp,
              child: const Text(
                "Continue to App",
              ),
            ),
            const SizedBox(height: 20),
            buildFooter(),
          ],
        ),
      ),
    );
  }
}
/* ===================== EMERGENCY SCREEN ===================== */

class EmergencyScreen extends StatefulWidget {
  final bool openContacts;

  const EmergencyScreen({super.key, this.openContacts = false});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String name = "";
  String age = "";
  String blood = "";
  String gender = "";
  String diabetes = "";
  String asthma = "";
  String inhaler = "";
  String allergyStatus = "";
  String allergyFormatted = "";
  String bp = "";
  List<Map<String, dynamic>> contacts = [];
  String? imagePath;
  bool emergencyModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await loadData();
    await _askNotificationPermission();

    if (widget.openContacts && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _showEmergencyDialog();
      });
    }
  }

  Future<void> _askNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool("notificationAsked") ?? false;

    if (alreadyAsked) return;

    await prefs.setBool("notificationAsked", true);

    final status = await Permission.notification.status;

    if (status.isGranted) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enable Notifications"),
        content: const Text(
          "In an Emergency, Every Second Counts.\n"
              "Enable notifications, so first responder can see your medical profile instantly to help you.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Skip"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Permission.notification.request();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final loadedName = prefs.getString("name") ?? "Not set";
    final loadedAge = prefs.getString("age") ?? "Not set";
    final loadedBlood = prefs.getString("blood") ?? "Not set";
    final loadedGender = prefs.getString("gender") ?? "Not set";
    final loadedDiabetes = prefs.getString("diabetes") ?? "No";
    final loadedAsthma = prefs.getString("asthma") ?? "No";
    final loadedInhaler = prefs.getString("inhaler") ?? "N/A";
    final loadedAllergyStatus = prefs.getString("allergyStatus") ?? "Unknown";
    final loadedAllergyTypesJson = prefs.getString("allergyTypes");
    final loadedAllergyOther = prefs.getString("allergyOther") ?? "";

    List<String> loadedAllergyTypes = [];
    if (loadedAllergyTypesJson != null && loadedAllergyTypesJson.isNotEmpty) {
      loadedAllergyTypes = List<String>.from(jsonDecode(loadedAllergyTypesJson));
    }

    String loadedAllergyFormatted;
    if (loadedAllergyStatus == "Yes" && loadedAllergyTypes.isNotEmpty) {
      final displayList = loadedAllergyTypes.map((e) {
        return e == "Other" ? loadedAllergyOther : e;
      }).where((e) => e.isNotEmpty).toList();
      loadedAllergyFormatted = displayList.join(" | ");
    } else {
      loadedAllergyFormatted = loadedAllergyStatus;
    }
    final loadedBp = prefs.getString("bp") ?? "Not set";
    final loadedImage = prefs.getString("imagePath") ?? "";

    List<Map<String, dynamic>> loadedContacts = [];

    final contactsJson = prefs.getString("contacts");

    if (contactsJson != null) {
      loadedContacts =
      List<Map<String, dynamic>>.from(jsonDecode(contactsJson));
    }

    if (!mounted) return;

    setState(() {
      name = loadedName;
      age = loadedAge;
      blood = loadedBlood;
      gender = loadedGender;
      diabetes = loadedDiabetes;
      asthma = loadedAsthma;
      inhaler = loadedInhaler;
      bp = loadedBp;
      allergyStatus = loadedAllergyStatus;
      allergyFormatted = loadedAllergyFormatted;
      imagePath = loadedImage.isNotEmpty ? loadedImage : null;
      contacts = loadedContacts;
    });

    NotificationService.showEmergencyNotification(
      name: loadedName,
      age: loadedAge,
      blood: loadedBlood,
      diabetes: loadedDiabetes,
      asthma: loadedAsthma,
      inhaler: loadedInhaler,
      bp: loadedBp,
      allergy: loadedAllergyFormatted,
      contacts: contacts,
      phone: contacts.isNotEmpty
          ? (contacts.first["phone"] ?? "")
          : "",
    );
  }

  Future<void> callNumber(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return;

    final Uri uri = Uri.parse("tel:$trimmed");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else {
        await launchUrl(uri); // fallback
      }
    } catch (e) {
      debugPrint("Call failed: $e");
    }
  }

  void _showEmergencyDialog() {
    if (contacts.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Emergency Contacts"),
          content: const Text("No emergency contacts available."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              final name = contact["name"] ?? "Unknown";
              final phone = contact["phone"] ?? "";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: phone.trim().isEmpty
                          ? null
                          : () {
                        Navigator.pop(context);
                        callNumber(phone.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("CALL"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 16),
              _primaryCard(),
              const SizedBox(height: 16),
              _conditionCard(),
              const SizedBox(height: 16),
              _contactCard(),
              buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(0.5),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.warning, color: Colors.white),
                onPressed: _showEmergencyDialog,
              ),
            ],
          ),

          const Expanded(
            child: Text(
              "QMedID Profile",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PermissionGateScreen(
                        nextScreen: const EmergencyScreen(),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditScreen(),
                    ),
                  ).then((_) => loadData());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null && imagePath!.isNotEmpty)
              CircleAvatar(
                radius: 45,
                backgroundImage: FileImage(File(imagePath!)),
              )
            else
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person),
              ),

            const SizedBox(height: 10),

            Text(name, style: const TextStyle(fontSize: 22)),
            Text("Age: $age"),
            Text("Gender: $gender"),
            Text("Blood Group: $blood"),
          ],
        ),
      ),
    );
  }

  Widget _conditionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Medical Conditions"),
            Text("Diabetes: $diabetes"),
            Text("BP: $bp"),
            Text("Asthma: $asthma"),
            if (asthma == "Yes")
              Text("Inhaler: $inhaler"),
            Text("Allergies: $allergyFormatted"),
          ],
        ),
      ),
    );
  }

  Widget _contactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Emergency Contacts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (contacts.isEmpty)
              const Text("No Emergency Contact Added")
            else
              Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contacts.length % 2 == 0
                        ? contacts.length
                        : contacts.length - 1,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      return _contactTile(contacts[index]);
                    },
                  ),

                  if (contacts.length % 2 != 0) ...[
                    const SizedBox(height: 10),
                    _contactTile(contacts.last),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(Map<String, dynamic> contact) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              contact["name"] ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 5),

            Text(
              contact["relation"] ?? "",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 5),

            Text(
              contact["phone"] ?? "",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final phone = contact["phone"]?.trim() ?? "";
                  if (phone.isEmpty) return;
                  callNumber(phone);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text("CALL"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildFooter() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        "© All rights reserved • The Opsup Corp",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ),
  );
}



/* ===================== EDIT SCREEN ===================== */

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  String? gender;
  String? age;
  String? blood;
  String? diabetes;
  String? asthma;
  String? inhaler;
  String allergyStatus = "Unknown";
  bool _allergyExpanded = false;
  String? bp;
  String? imagePath;
  List<Map<String, String>> existingContacts = [];
  List<Map<String, dynamic>> contacts = [];

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> bloodGroups = ["A+","A-","B+","B-","AB+","AB-","O+","O-"];
  final List<String> yesNo = ["Yes", "No"];
  List<String> selectedAllergies = [];
  final allergyOtherController = TextEditingController();
  final List<String> allergyCheckboxOptions = [
    "Penicillin",
    "Sulfa drugs",
    "Aspirin",
    "NSAIDs",
    "Latex",
    "Peanuts",
    "Tree nuts",
    "Shellfish",
    "Eggs",
    "Milk",
    "Dust",
    "Other",
  ];

  final List<String> bpLevels = ["Low", "Normal", "High"];
  final List<String> relationships = [
    "Father",
    "Mother",
    "Wife",
    "Husband",
    "Brother",
    "Sister",
    "Son",
    "Daughter",
    "Friend",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    allergyOtherController.dispose();
    super.dispose();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString("name") ?? "";
      ageController.text = prefs.getString("age") ?? "";
      gender = prefs.getString("gender");
      blood = prefs.getString("blood");
      diabetes = prefs.getString("diabetes");
      asthma = prefs.getString("asthma");
      final savedInhaler = prefs.getString("inhaler");
      inhaler = (savedInhaler == null || savedInhaler == "N/A")
          ? null
          : savedInhaler;
      final savedStatus = prefs.getString("allergyStatus") ?? "Unknown";
      final savedTypesJson = prefs.getString("allergyTypes");
      final savedOther = prefs.getString("allergyOther") ?? "";

      allergyStatus = savedStatus;
      allergyOtherController.text = savedOther;

      if (savedTypesJson != null && savedTypesJson.isNotEmpty) {
        selectedAllergies = List<String>.from(jsonDecode(savedTypesJson));
      } else {
        selectedAllergies = [];
      }
      // Auto-expand if Yes but nothing selected yet, collapse if already has selections
      _allergyExpanded = (allergyStatus == "Yes" && selectedAllergies.isEmpty);

      bp = prefs.getString("bp");

      imagePath = prefs.getString("imagePath");

      final savedContacts = prefs.getString("contacts");

      if (savedContacts != null && savedContacts.isNotEmpty) {
        final decoded = jsonDecode(savedContacts);

        contacts = List<Map<String, dynamic>>.from(
          decoded.map((e) {
            return {
              "name": e["name"] ?? "",
              "phone": e["phone"] ?? "",
              "relation": e["relation"] ?? "",
              "nameController": TextEditingController(text: e["name"] ?? ""),
              "phoneController": TextEditingController(text: e["phone"] ?? ""),
            };
          }),
        );
      }
    });
  }

  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        imagePath = img.path;
      });
    }
  }

  void addContact() {
    setState(() {
      contacts.add({
        "name": "",
        "phone": "",
        "relation": "",
        "nameController": TextEditingController(),
        "phoneController": TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/icon.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 8),
              const Text("Edit QMedID Profile",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),),
            ],
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const SizedBox(height: 10),

                  Center(
                    child: GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage:
                        (imagePath != null && imagePath!.isNotEmpty)
                            ? FileImage(File(imagePath!))
                            : null,
                        child: (imagePath == null || imagePath!.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                        return "Only letters allowed";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Age",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Age is required";
                      }

                      final age = int.tryParse(value);

                      if (age == null || age < 1 || age > 120) {
                        return "Enter valid age";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  _dropdown("Gender", genders, gender,
                          (v) => setState(() => gender = v)),
                  const SizedBox(height: 12),

                  _dropdown("Blood Group", bloodGroups, blood,
                          (v) => setState(() => blood = v)),
                  const SizedBox(height: 12),

                  _dropdown("Diabetes", yesNo, diabetes,
                          (v) => setState(() => diabetes = v)),
                  const SizedBox(height: 12),

                  _dropdown("Asthma", yesNo, asthma,
                          (v) => setState(() {
                        asthma = v;
                        if (v == "No") inhaler = null;
                      })),

                  if (asthma == "Yes") ...[
                    const SizedBox(height: 12),
                    _dropdown("Keeping Inhaler", yesNo, inhaler,
                            (v) => setState(() => inhaler = v)),
                  ],

                  const SizedBox(height: 12),

                  _dropdown("Blood Pressure", bpLevels, bp,
                          (v) => setState(() => bp = v)),

                  const SizedBox(height: 12),

                  // ── ALLERGY SECTION ──────────────────────────────────────
                  Builder(builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Allergies",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 6),

                        // ── COLLAPSED VIEW: selected items container ──
                        if (allergyStatus == "Yes" &&
                            !_allergyExpanded &&
                            selectedAllergies.isNotEmpty) ...[

                          GestureDetector(
                            onTap: () => setState(() => _allergyExpanded = true),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedAllergies.map((e) {
                                        if (e == "Other") {
                                          final custom =
                                          allergyOtherController.text.trim();
                                          return custom.isNotEmpty ? custom : "Other";
                                        }
                                        return e;
                                      }).join(", "),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const Icon(Icons.edit_outlined,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],

                        // ── EXPANDED VIEW: checkboxes + OK ──
                        if (allergyStatus == "Yes" && _allergyExpanded) ...[

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              children: allergyCheckboxOptions.map((option) {
                                return CheckboxListTile(
                                  title: Text(option),
                                  value: selectedAllergies.contains(option),
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        selectedAllergies.add(option);
                                      } else {
                                        selectedAllergies.remove(option);
                                        if (option == "Other") {
                                          allergyOtherController.clear();
                                        }
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),

                          // Other text field — appears inside expanded area
                          if (selectedAllergies.contains("Other")) ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: allergyOtherController,
                              decoration: const InputDecoration(
                                labelText: "Please specify",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (selectedAllergies.contains("Other") &&
                                    (value == null || value.trim().isEmpty)) {
                                  return "Please specify the allergy";
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 10),

                          // OK button — logic:
                          // disabled if nothing selected, OR if Other selected but field empty
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final otherSelected =
                                selectedAllergies.contains("Other");
                                final otherFilled =
                                    allergyOtherController.text.trim().isNotEmpty;
                                final hasSelection = selectedAllergies.isNotEmpty;
                                final canConfirm =
                                    hasSelection && (!otherSelected || otherFilled);

                                if (!canConfirm) return;

                                setState(() => _allergyExpanded = false);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: () {
                                  final otherSelected =
                                  selectedAllergies.contains("Other");
                                  final otherFilled =
                                      allergyOtherController.text.trim().isNotEmpty;
                                  final hasSelection = selectedAllergies.isNotEmpty;
                                  final canConfirm =
                                      hasSelection && (!otherSelected || otherFilled);
                                  return canConfirm ? Colors.red : Colors.grey;
                                }(),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("OK"),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],

                        // ── RADIO BUTTONS: always visible ──
                        Row(
                          children: ["Yes", "No", "Unknown"].map((option) {
                            return Expanded(
                              child: RadioListTile<String>(
                                title: Text(option,
                                    style: const TextStyle(fontSize: 13)),
                                value: option,
                                groupValue: allergyStatus,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (v) {
                                  setState(() {
                                    allergyStatus = v!;
                                    if (v != "Yes") {
                                      selectedAllergies.clear();
                                      allergyOtherController.clear();
                                      _allergyExpanded = false;
                                    } else {
                                      // switching to Yes — expand if nothing selected yet
                                      _allergyExpanded = selectedAllergies.isEmpty;
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),

                      ],
                    );
                  }),
// ── END ALLERGY SECTION ──────────────────────────────────

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Emergency Contacts",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.red),
                        onPressed: addContact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [

                              TextFormField(
                                controller: contacts[index]["nameController"],
                                decoration: const InputDecoration(
                                  labelText: "Contact Name",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Required";
                                  }
                                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                                    return "Invalid name";
                                  }
                                  return null;
                                },
                                onChanged: (v) {
                                  contacts[index]["name"] = v;
                                },
                              ),

                              const SizedBox(height: 10),

                              TextFormField(
                                controller: contacts[index]["phoneController"],
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: "Phone Number",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Required";
                                  }
                                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value.trim())) {
                                    return "Invalid number";
                                  }
                                  return null;
                                },
                                onChanged: (v) {
                                  contacts[index]["phone"] = v;
                                },
                              ),

                              const SizedBox(height: 10),

                              DropdownButtonFormField<String>(
                                initialValue: contacts[index]["relation"]?.isNotEmpty == true
                                    ? contacts[index]["relation"]
                                    : null,
                                items: relationships
                                    .map(
                                      (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    contacts[index]["relation"] = v ?? "";
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: "Relation",
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      contacts.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: () async {
                      final formValid = _formKey.currentState!.validate();

                      if (!formValid) return;

                      if (gender == null ||
                          blood == null ||
                          diabetes == null ||
                          asthma == null ||
                          bp == null ||
                          (asthma == "Yes" && inhaler == null) ||
                          (allergyStatus == "Yes" && selectedAllergies.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all medical fields")),
                        );
                        return;
                      }

                      if (contacts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("At least 1 contact required")),
                        );
                        return;
                      }

                      for (final c in contacts) {
                        final name = (c["nameController"] as TextEditingController).text.trim();
                        final phone = (c["phoneController"] as TextEditingController).text.trim();

                        if (name.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Contact fields cannot be empty")),
                          );
                          return;
                        }
                      }

                      final prefs = await SharedPreferences.getInstance();

                      final cleanedContacts = contacts.map((c) {
                        return {
                          "name": (c["nameController"] as TextEditingController).text.trim(),
                          "phone": (c["phoneController"] as TextEditingController).text.trim(),
                          "relation": c["relation"] ?? "",
                        };
                      }).toList();

                      await prefs.setString("name", nameController.text);
                      await prefs.setString("age", ageController.text);
                      await prefs.setString("gender", gender!);
                      await prefs.setString("blood", blood!);
                      await prefs.setString("diabetes", diabetes!);
                      await prefs.setString("asthma", asthma!);
                      await prefs.setString("inhaler",
                          asthma == "Yes" ? inhaler! : "N/A");
                      await prefs.setString("allergyStatus", allergyStatus);

                      if (allergyStatus == "Yes") {
                        await prefs.setString("allergyTypes", jsonEncode(selectedAllergies));
                        await prefs.setString("allergyOther", allergyOtherController.text.trim());
                      } else {
                        await prefs.setString("allergyTypes", jsonEncode([]));
                        await prefs.setString("allergyOther", "");
                      }

                      await prefs.setString("bp", bp!);
                      await prefs.setString("imagePath", imagePath ?? "");

                      await prefs.setString("contacts", jsonEncode(cleanedContacts));

                      String interval = prefs.getString("reminderInterval") ?? "Off";

                      if (interval == "Off") {
                        interval = "15 min";
                        await prefs.setString("reminderInterval", interval);
                      }

                      await ReminderService.registerReminder(interval);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      contacts.isEmpty ? "Add at least 1 contact" : "Save",
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildFooter(),
                ],
              ),
            ),
          ),
        )
    );
  }


  Widget _field(TextEditingController c, String label) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdown(
      String label,
      List<String> items,
      String? value,
      Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}