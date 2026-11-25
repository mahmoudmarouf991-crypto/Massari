import 'package:flutter/material.dart';
import 'screens/home_shell.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = NotificationService();
  await notifications.init();
  runApp(MasariApp(notifications: notifications));
}

class MasariApp extends StatelessWidget {
  final NotificationService notifications;
  const MasariApp({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مساري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: _Bootstrap(notifications: notifications),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  final NotificationService notifications;
  const _Bootstrap({required this.notifications});

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<StorageService> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<StorageService> _load() async {
    final storage = await StorageService.create();
    // إعادة جدولة كل التذكيرات عند كل فتح للتطبيق
    await widget.notifications.rescheduleAll(storage.getReminders());
    return storage;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.navy,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return HomeShell(storage: snapshot.data!, notifications: widget.notifications);
      },
    );
  }
}
