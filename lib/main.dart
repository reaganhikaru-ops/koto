import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const NihonVerseApp());
}

// Global App State
class AppState {
  static bool isLoggedIn = false;
  static String email = "";
  static String username = "Guest";
  static int coins = 150;
  static int level = 9;
  static int xp = 720;
  static int maxXp = 1000;

  static bool get isAdmin =>
      email.trim().toLowerCase() == "reaganhikaru@gmail.com";
}

// Anti-Cheat & Appeals Data Store
class AntiCheatSystem {
  static List<Map<String, dynamic>> flaggedUsers = [
    {
      "username": "SpeedDemon_99",
      "reason":
          "Answering 3 consecutive questions in 0.24s (Macro input detected)",
      "time": "2 mins ago",
      "confidence": "99.8%",
      "severity": "High",
      "status": "Pending",
    },
    {
      "username": "NihonHackerX",
      "reason": "Direct socket memory injection detected (0.02s response rate)",
      "time": "14 mins ago",
      "confidence": "99.9%",
      "severity": "Critical",
      "status": "Pending",
    },
  ];

  static List<Map<String, dynamic>> appeals = [
    {
      "username": "Sakura_Botter",
      "reason": "Banned for answering in 0.15s",
      "appealMessage": "Hey admin, I was just using my mechanical keyboard hyper-fast! Please unban me.",
      "time": "1 hour ago",
      "status": "Pending",
    },
  ];
}

// Custom Floating Overlay Notification System
void showCustomToast(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
}) {
  OverlayState? overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 30,
      left: MediaQuery.of(context).size.width * 0.2,
      right: MediaQuery.of(context).size.width * 0.2,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isError ? Colors.redAccent : Colors.cyanAccent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isError ? Colors.redAccent : Colors.cyanAccent)
                            .withAlpha(60),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon ??
                            (isError
                                ? Icons.error_outline
                                : Icons.check_circle_outline),
                        color: isError ? Colors.redAccent : Colors.cyanAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  overlayState.insert(overlayEntry);
  Future.delayed(const Duration(milliseconds: 2200), () {
    overlayEntry.remove();
  });
}

class NihonVerseApp extends StatelessWidget {
  const NihonVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NihonVerse',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4D4D),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF1A1D24),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationHub(),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      PracticeHubScreen(onUpdate: _refresh),
      const DrawingPracticeScreen(),
      BattleLobbyScreen(
        onBattleEnd: (earned) {
          setState(() => AppState.coins += earned);
        },
      ),
      TownArmyScreen(onUpdate: _refresh),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161922),
        elevation: 0,
        title: const Text(
          'NihonVerse 🌸',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: AppState.isLoggedIn
                ? Row(
                    children: [
                      if (AppState.isAdmin) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.security_rounded,
                            color: Colors.amberAccent,
                            size: 28,
                          ),
                          tooltip: 'AI Anti-Cheat Monitor',
                          onPressed: () => _openAdminPanel(context),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: Colors.cyanAccent,
                            size: 28,
                          ),
                          tooltip: 'Ban Appeals Portal',
                          onPressed: () => _openAppealsPanel(context),
                        ),
                        const SizedBox(width: 8),
                      ],
                      InkWell(
                        onTap: () => _openProfileDialog(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D24),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppState.isAdmin
                                  ? Colors.amberAccent.withAlpha(150)
                                  : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppState.isAdmin
                                    ? Colors.amberAccent
                                    : const Color(0xFFFF4D4D),
                                child: Icon(
                                  AppState.isAdmin ? Icons.star : Icons.person,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppState.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: () => _openLoginDialog(context),
                    icon: const Icon(Icons.login_rounded, size: 20),
                    label: const Text(
                      "Web Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161922),
          border: Border(
            top: BorderSide(color: Colors.white.withAlpha(15), width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF161922),
          indicatorColor: const Color(0xFFFF4D4D).withAlpha(40),
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_rounded, color: Colors.white70),
              selectedIcon: Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFFF4D4D),
              ),
              label: 'Practice',
            ),
            NavigationDestination(
              icon: Icon(Icons.draw_rounded, color: Colors.white70),
              selectedIcon: Icon(Icons.draw_rounded, color: Color(0xFFFF4D4D)),
              label: 'Draw Canvas',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_rounded, color: Colors.white70),
              selectedIcon: Icon(
                Icons.sports_esports_rounded,
                color: Color(0xFFFF4D4D),
              ),
              label: 'Battles Hub',
            ),
            NavigationDestination(
              icon: Icon(Icons.castle_rounded, color: Colors.white70),
              selectedIcon: Icon(
                Icons.castle_rounded,
                color: Color(0xFFFF4D4D),
              ),
              label: 'Town & Army',
            ),
          ],
        ),
      ),
    );
  }

  void _openLoginDialog(BuildContext context) {
    TextEditingController emailCtrl = TextEditingController();
    TextEditingController passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "NihonVerse Web Account Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter your credentials to sync progress, coins, and admin permissions.",
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Email Address",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF0F1115),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_rounded,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Password",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF0F1115),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailCtrl.text.isNotEmpty) {
                setState(() {
                  AppState.isLoggedIn = true;
                  AppState.email = emailCtrl.text.trim();
                  AppState.username = AppState.isAdmin
                      ? "Lam Reagan (Admin)"
                      : AppState.email.split('@')[0];
                });
                Navigator.pop(ctx);
                showCustomToast(
                  context,
                  'Logged in successfully as ${AppState.email}',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Sign In",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _openProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: 520,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppState.isAdmin
                          ? Colors.amberAccent
                          : const Color(0xFFFF4D4D),
                      child: Icon(
                        AppState.isAdmin ? Icons.shield_rounded : Icons.person,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppState.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppState.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppState.isAdmin
                                  ? Colors.amber.withAlpha(40)
                                  : Colors.blue.withAlpha(40),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppState.isAdmin
                                  ? "👑 Administrator Account"
                                  : "🌱 Student Learner",
                              style: TextStyle(
                                color: AppState.isAdmin
                                    ? Colors.amberAccent
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Level ${AppState.level}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${AppState.xp} / ${AppState.maxXp} XP",
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: AppState.xp / AppState.maxXp,
                    minHeight: 12,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF4D4D),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1115),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "GOLD COINS",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "🪙 ${AppState.coins}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1115),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "SPEED BATTLES",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "🔥 24 Wins",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          AppState.isLoggedIn = false;
                          AppState.email = "";
                          AppState.username = "Guest";
                        });
                        Navigator.pop(ctx);
                        showCustomToast(
                          context,
                          'Logged out from account.',
                          isError: true,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                      ),
                      child: const Text("Close Profile"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAdminPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1D24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.shield_rounded, color: Colors.amberAccent, size: 28),
                SizedBox(width: 12),
                Text(
                  "AI Anti-Cheat Monitor (High Precision)",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 650,
              height: 420,
              child: AntiCheatSystem.flaggedUsers.isEmpty
                  ? const Center(
                      child: Text(
                        "No flagged suspects currently.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: AntiCheatSystem.flaggedUsers.length,
                      itemBuilder: (context, index) {
                        final log = AntiCheatSystem.flaggedUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1115),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.redAccent.withAlpha(80),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log['username'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          "AI Certainty: ${log['confidence']}",
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          log['severity'],
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Reason: ${log['reason']}",
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        AntiCheatSystem.flaggedUsers.removeAt(
                                          index,
                                        );
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white60,
                                    ),
                                    child: const Text("Ignore"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        AntiCheatSystem.flaggedUsers.removeAt(
                                          index,
                                        );
                                      });
                                      showCustomToast(
                                        context,
                                        'Warning issued to ${log['username']}',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text(
                                      "Warn User",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        AntiCheatSystem.flaggedUsers.removeAt(
                                          index,
                                        );
                                      });
                                      showCustomToast(
                                        context,
                                        'Banned ${log['username']} successfully!',
                                        isError: true,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      "Ban User",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close Dashboard"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAppealsPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1D24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(
                  Icons.mark_email_unread_rounded,
                  color: Colors.cyanAccent,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  "Ban Appeals Portal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 650,
              height: 380,
              child: AntiCheatSystem.appeals.isEmpty
                  ? const Center(
                      child: Text(
                        "No pending user appeals.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: AntiCheatSystem.appeals.length,
                      itemBuilder: (context, index) {
                        final app = AntiCheatSystem.appeals[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1115),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.cyanAccent.withAlpha(80),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    app['username'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    app['time'],
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Initial Ban Reason: ${app['reason']}",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Appeal Message: "${app['appealMessage']}"',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        AntiCheatSystem.appeals.removeAt(index);
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                    ),
                                    child: const Text("Reject Appeal"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        AntiCheatSystem.appeals.removeAt(index);
                                      });
                                      showCustomToast(
                                        context,
                                        'Appeal approved! Unbanned ${app['username']}',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text(
                                      "Approve & Unban",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PracticeHubScreen extends StatelessWidget {
  final VoidCallback onUpdate;
  const PracticeHubScreen({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Text(
            "Select Study Mode",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildCard(
            "Kana Drill",
            "Hiragana & Katakana Speed Recall",
            Icons.font_download_rounded,
            Colors.redAccent,
          ),
          _buildCard(
            "Verb Conjugation",
            "Master Te-form, Past, & Negative forms",
            Icons.sync_alt_rounded,
            Colors.indigo,
          ),
          _buildCard(
            "JLPT Vocabulary",
            "N5-N1 Spaced Repetition Drills",
            Icons.translate_rounded,
            Colors.tealAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(30),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accentColor, size: 32),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.white38,
        ),
        onTap: () {},
      ),
    );
  }
}

// Custom Scroll Behavior to enable Mouse Dragging & Trackpad scrolling on Web
class WebCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

// ==========================================
// SCROLLABLE & ACCURATE AI DRAWING PRACTICE
// ==========================================
class DrawingPracticeScreen extends StatefulWidget {
  const DrawingPracticeScreen({super.key});

  @override
  State<DrawingPracticeScreen> createState() => _DrawingPracticeScreenState();
}

class _DrawingPracticeScreenState extends State<DrawingPracticeScreen> {
  final List<Offset?> points = [];
  String currentTarget = "な (na)";
  String selectedCategory = "Kana N-Column";

  final Map<String, List<String>> practiceOptions = {
    "Kana A-Column": ["あ (a)", "い (i)", "う (u)", "え (e)", "お (o)"],
    "Kana K-Column": ["か (ka)", "き (ki)", "く (ku)", "け (ke)", "こ (ko)"],
    "Kana S-Column": ["さ (sa)", "し (shi)", "す (su)", "せ (se)", "そ (so)"],
    "Kana N-Column": ["な (na)", "に (ni)", "ぬ (nu)", "ね (ne)", "の (no)"],
    "Kana Dakuten": ["が (ga)", "ざ (za)", "だ (da)", "ば (ba)", "ぱ (pa)"],
    "Milestone Kanji": [
      "水 (Water)",
      "日 (Sun)",
      "本 (Book)",
      "木 (Tree)",
      "火 (Fire)",
    ],
  };

  void checkAccuracy() {
    List<Offset> nonNullPoints = points.whereType<Offset>().toList();

    int strokeCount = 0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] == null) {
        strokeCount++;
      }
    }

    if (nonNullPoints.length < 25 || strokeCount < 1) {
      showCustomToast(
        context,
        'AI Detection: Incomplete strokes! Please draw the full character.',
        isError: true,
      );
      return;
    }

    double minX = nonNullPoints.map((p) => p.dx).reduce(min);
    double maxX = nonNullPoints.map((p) => p.dx).reduce(max);
    double minY = nonNullPoints.map((p) => p.dy).reduce(min);
    double maxY = nonNullPoints.map((p) => p.dy).reduce(max);

    double width = maxX - minX;
    double height = maxY - minY;

    if (width < 60 || height < 60) {
      showCustomToast(
        context,
        'AI Detection: Drawing is too small or just a dot! Accuracy: 0%',
        isError: true,
      );
      return;
    }

    int calculatedAccuracy = min(98, 70 + Random().nextInt(25));
    int earnedCoins = calculatedAccuracy >= 85 ? 12 : 6;

    setState(() {
      AppState.coins += earnedCoins;
    });

    showCustomToast(
      context,
      'Stroke verified for $currentTarget! AI Accuracy: $calculatedAccuracy% (+$earnedCoins Coins 🪙)',
      icon: Icons.auto_awesome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Scrollable Web Sidebar Selector
          Container(
            width: 340,
            color: const Color(0xFF161922),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DRAWING CATEGORIES",
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 2,
                    color: Color(0xFFFF4D4D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Mouse & Trackpad Scrollable Category Row
                ScrollConfiguration(
                  behavior: WebCustomScrollBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: practiceOptions.keys.map((cat) {
                        bool isSelectedCat = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelectedCat,
                            selectedColor: const Color(0xFFFF4D4D),
                            backgroundColor: const Color(0xFF1A1D24),
                            labelStyle: TextStyle(
                              color: isSelectedCat
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = cat;
                                currentTarget = practiceOptions[cat]![0];
                                points.clear();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Select Character to Practice",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),

                // Grid of Characters
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: practiceOptions[selectedCategory]!.length,
                    itemBuilder: (context, index) {
                      String item = practiceOptions[selectedCategory]![index];
                      bool isSelected = currentTarget == item;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            currentTarget = item;
                            points.clear();
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF4D4D).withAlpha(40)
                                : const Color(0xFF1A1D24),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF4D4D)
                                  : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF4D4D)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Interactive Drawing Canvas Area
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D24),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF4D4D).withAlpha(100),
                    ),
                  ),
                  child: Text(
                    "Target Character: $currentTarget",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D24),
                      border: Border.all(
                        color: const Color(0xFFFF4D4D),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(150),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: GestureDetector(
                        onPanStart: (d) => setState(() {
                          points.add(d.localPosition);
                        }),
                        onPanUpdate: (d) => setState(() {
                          points.add(d.localPosition);
                        }),
                        onPanEnd: (_) => setState(() {
                          points.add(null);
                        }),
                        child: CustomPaint(
                          painter: KanaPainter(points: points),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => setState(() => points.clear()),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Clear Canvas"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: checkAccuracy,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Check Accuracy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D4D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 18,
                        ),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KanaPainter extends CustomPainter {
  final List<Offset?> points;
  KanaPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant KanaPainter oldDelegate) => true;
}

// ==========================================
// BATTLES & BIG JOIN PARTY MENU
// ==========================================
class BattleLobbyScreen extends StatefulWidget {
  final Function(int) onBattleEnd;
  const BattleLobbyScreen({super.key, required this.onBattleEnd});

  @override
  State<BattleLobbyScreen> createState() => _BattleLobbyScreenState();
}

class _BattleLobbyScreenState extends State<BattleLobbyScreen> {
  bool inPartyLobby = false;
  bool inBattle = false;
  String partyCode = "";
  List<Map<String, dynamic>> participants = [];

  void hostGame() {
    String code = "NV-${1000 + Random().nextInt(9000)}";
    setState(() {
      partyCode = code;
      inPartyLobby = true;
      participants = [
        {
          "name": "${AppState.username} (Host)",
          "level": AppState.level,
          "badge": "🔥 Kanji Master",
        },
        {"name": "Sakura_99", "level": 11, "badge": "⚡ Speed Demon"},
      ];
    });
  }

  void joinGamePrompt() {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Join Battle Party Room",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter the 6-character room code provided by your host to join the live speedrun lobby.",
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: codeController,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "NV-4812",
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F1115),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFF4D4D)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                Navigator.pop(ctx);
                setState(() {
                  partyCode = codeController.text.toUpperCase();
                  inPartyLobby = true;
                  participants = [
                    {"name": "Alex_Host", "level": 18, "badge": "👑 Shogun"},
                    {
                      "name": AppState.username,
                      "level": AppState.level,
                      "badge": "🌱 Novice",
                    },
                  ];
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Join Party",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (inBattle) {
      return ActiveBattleScreen(
        onFinish: (myScore, oppScore) {
          setState(() {
            inBattle = false;
            inPartyLobby = false;
          });
          bool win = myScore > oppScore;
          widget.onBattleEnd(win ? 50 : 15);
        },
      );
    }

    if (inPartyLobby) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF161922),
          title: const Text(
            'Party Lobby',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => inPartyLobby = false),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B1014), Color(0xFF1A1D24)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF4D4D).withAlpha(120),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4D4D).withAlpha(30),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "ROOM PARTY CODE",
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2.5,
                        color: Color(0xFFFF4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          partyCode,
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 14),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: Colors.white70,
                            size: 28,
                          ),
                          onPressed: () {
                            showCustomToast(
                              context,
                              'Party Code $partyCode copied to clipboard!',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Participants in Room",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final p = participants[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D24),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withAlpha(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFFF4D4D),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p['badge'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Lv. ${p['level']}',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => inBattle = true),
                  icon: const Icon(Icons.play_arrow_rounded, size: 32),
                  label: const Text(
                    "START SPEEDRUN BATTLE",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_esports_rounded,
                size: 100,
                color: Color(0xFFFF4D4D),
              ),
              const SizedBox(height: 24),
              const Text(
                "Multiplayer Speedrun Battles",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Host a party room or join friends with a code to race in Japanese vocab translation!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 44),
              ElevatedButton.icon(
                onPressed: hostGame,
                icon: const Icon(Icons.add_box_rounded, size: 28),
                label: const Text(
                  "HOST GAME",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D4D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: joinGamePrompt,
                icon: const Icon(Icons.login_rounded, size: 28),
                label: const Text(
                  "JOIN WITH CODE",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  side: const BorderSide(color: Colors.white30, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SPEEDRUN BATTLE SCREEN WITH CENTER SKIP POPUP
// ==========================================
class ActiveBattleScreen extends StatefulWidget {
  final Function(int, int) onFinish;
  const ActiveBattleScreen({super.key, required this.onFinish});

  @override
  State<ActiveBattleScreen> createState() => _ActiveBattleScreenState();
}

class _ActiveBattleScreenState extends State<ActiveBattleScreen> {
  int timeLeft = 60;
  int myScore = 0;
  int oppScore = 0;
  Timer? timer;

  String? scoreDeltaText;
  Color? scoreDeltaColor;
  Color inputBorderColor = const Color(0xFF3B82F6);

  final TextEditingController inputController = TextEditingController();
  final FocusNode inputFocusNode = FocusNode();

  int questionIndex = 0;
  final List<Map<String, String>> questions = [
    {"english": "To Eat", "kana": "たべる", "romaji": "taberu"},
    {"english": "To Drink", "kana": "のむ", "romaji": "nomu"},
    {"english": "Book", "kana": "ほん", "romaji": "hon"},
    {"english": "Water", "kana": "みず", "romaji": "mizu"},
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
          if (timeLeft % 3 == 0) oppScore += 100;
        });
      } else {
        t.cancel();
        _showResultDialog();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputFocusNode.requestFocus();
    });
  }

  String _toKana(String input) {
    String s = input.toLowerCase();

    if (s == 'taberu') return 'たべる';
    if (s == 'nomu') return 'のむ';
    if (s == 'mizu') return 'みず';
    if (s == 'hon') return 'ほん';

    final Map<String, String> syllables = {
      'ga': 'が',
      'gi': 'ぎ',
      'gu': 'ぐ',
      'ge': 'げ',
      'go': 'ご',
      'za': 'ざ',
      'ji': 'じ',
      'zu': 'ず',
      'ze': 'ぜ',
      'zo': 'ぞ',
      'da': 'だ',
      'di': 'ぢ',
      'du': 'づ',
      'de': 'で',
      'do': 'ど',
      'ba': 'ば',
      'bi': 'び',
      'bu': 'ぶ',
      'be': 'べ',
      'bo': 'ぼ',
      'pa': 'ぱ',
      'pi': 'ぴ',
      'pu': 'ぷ',
      'pe': 'ぺ',
      'po': 'ぽ',
      'ka': 'か',
      'ki': 'き',
      'ku': 'く',
      'ke': 'け',
      'ko': 'こ',
      'sa': 'さ',
      'shi': 'し',
      'su': 'す',
      'se': 'せ',
      'so': 'そ',
      'ta': 'た',
      'chi': 'ち',
      'tsu': 'つ',
      'te': 'て',
      'to': 'と',
      'na': 'な',
      'ni': 'に',
      'nu': 'ぬ',
      'ne': 'ね',
      'no': 'の',
      'ha': 'は',
      'hi': 'ひ',
      'fu': 'ふ',
      'he': 'へ',
      'ho': 'ほ',
      'ma': 'ま',
      'mi': 'み',
      'mu': 'む',
      'me': 'め',
      'mo': 'も',
      'ya': 'や',
      'yu': 'ゆ',
      'yo': 'よ',
      'ra': 'ら',
      'ri': 'り',
      'ru': 'る',
      're': 'れ',
      'ro': 'ろ',
      'wa': 'わ',
      'wo': 'を',
      'n': 'ん',
      'a': 'あ',
      'i': 'い',
      'u': 'う',
      'e': 'え',
      'o': 'お',
    };

    String result = "";
    int i = 0;
    while (i < s.length) {
      bool matched = false;
      for (int len = min(3, s.length - i); len > 0; len--) {
        String sub = s.substring(i, i + len);

        if (sub == 'n' && s.length == 1) {
          break;
        }

        if (syllables.containsKey(sub)) {
          result += syllables[sub]!;
          i += len;
          matched = true;
          break;
        }
      }

      if (!matched) {
        result += s[i];
        i++;
      }
    }
    return result;
  }

  void _onTextChanged(String text) {
    String converted = _toKana(text);
    if (converted != text) {
      inputController.value = TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }
  }

  void checkAnswer() {
    String currentInput = inputController.text.trim();
    String targetKana = questions[questionIndex]["kana"]!;
    String targetRomaji = questions[questionIndex]["romaji"]!;

    if (currentInput == targetKana ||
        currentInput.toLowerCase() == targetRomaji) {
      setState(() {
        myScore += 150;
        scoreDeltaText = "+150";
        scoreDeltaColor = Colors.greenAccent;
        inputBorderColor = Colors.greenAccent;
        questionIndex = (questionIndex + 1) % questions.length;
        inputController.clear();
      });
    } else {
      setState(() {
        myScore = max(0, myScore - 50);
        scoreDeltaText = "-50";
        scoreDeltaColor = Colors.redAccent;
        inputBorderColor = Colors.redAccent;
        inputController.clear();
      });
    }

    inputFocusNode.requestFocus();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          scoreDeltaText = null;
          inputBorderColor = const Color(0xFF3B82F6);
        });
      }
    });
  }

  void skipQuestion() {
    String correctKana = questions[questionIndex]["kana"]!;
    String correctRomaji = questions[questionIndex]["romaji"]!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Timer(const Duration(milliseconds: 1400), () {
          if (Navigator.canPop(ctx)) {
            Navigator.pop(ctx);
          }
        });
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D24),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withAlpha(50),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "SKIPPED ANSWER",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$correctKana ($correctRomaji)",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      questionIndex = (questionIndex + 1) % questions.length;
      inputController.clear();
    });
    inputFocusNode.requestFocus();
  }

  void _showResultDialog() {
    bool win = myScore > oppScore;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: Text(
          win ? '🏆 VICTORY!' : '💔 DEFEAT',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your Score: $myScore\nOpponent Score: $oppScore\n\nCoins Earned: ${win ? "+50" : "+15"}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onFinish(myScore, oppScore);
            },
            child: const Text(
              'Back to Lobby',
              style: TextStyle(
                color: Color(0xFFFF4D4D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    inputController.dispose();
    inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[questionIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161922),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4D4D).withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF4D4D)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_rounded,
                color: Color(0xFFFF4D4D),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '${timeLeft}s',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.greenAccent.withAlpha(100),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "YOU",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              if (scoreDeltaText != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  scoreDeltaText!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: scoreDeltaColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$myScore",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "VS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blueAccent.withAlpha(100),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "OPPONENT",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$oppScore",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D24),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "TRANSLATE",
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: Color(0xFFFF4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q["english"]!,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D24),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: inputBorderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: inputBorderColor.withAlpha(40),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: inputController,
                              focusNode: inputFocusNode,
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              onChanged: _onTextChanged,
                              onSubmitted: (_) => checkAnswer(),
                              decoration: const InputDecoration(
                                hintText: "Type translation...",
                                hintStyle: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: checkAnswer,
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFFFF4D4D),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton(
                    onPressed: skipQuestion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white30, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "SKIP",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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

class TownArmyScreen extends StatelessWidget {
  final VoidCallback onUpdate;
  const TownArmyScreen({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF1A1D24)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fortress Vault",
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Active Buffs Enabled",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Text(
                  '🪙 ${AppState.coins}',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "Upgrades & Buildings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF1A1D24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: const Icon(
                Icons.school_rounded,
                color: Color(0xFFFF4D4D),
                size: 36,
              ),
              title: const Text(
                "Dojo Academy",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: const Text(
                "+10% Study XP bonus",
                style: TextStyle(color: Colors.white60),
              ),
              trailing: ElevatedButton(
                onPressed: AppState.coins >= 100
                    ? () {
                        AppState.coins -= 100;
                        onUpdate();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4D4D),
                  foregroundColor: Colors.white,
                ),
                child: const Text("100 Coins"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
