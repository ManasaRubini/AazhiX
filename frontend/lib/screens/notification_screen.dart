import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_constants.dart';
import '../services/app_language_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  bool loading = true;
  List alerts = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      loading = true;
    });

    try {
      final lang = _langProvider.currentLanguage;
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/notifications/?lang=$lang"),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          alerts = data["alerts"] ?? [];
          loading = false;
        });
        return;
      }
    } catch (e) {
      print("Notification fetch error: $e");
    }

    if (!mounted) return;
    setState(() {
      alerts = _getFallbackAlerts(_langProvider.currentLanguage);
      loading = false;
    });
  }

  List _getFallbackAlerts(String lang) {
    if (lang == "ta") {
      return [
        {
          "id": "1",
          "title": "🌊 சாதாரண கடல் அலைகள்",
          "description": "அலை உயரம் 1.4m. மீன்பிடிக்க சாதகமான கடல் நிலை.",
          "severity": "INFO",
          "time": "சற்று முன்"
        },
        {
          "id": "2",
          "title": "📈 சூரை மீன் சந்தை விலை உயர்வு",
          "description": "சூரை மீன் கிலோ ரூ.240 ஆக உயர்ந்துள்ளது. இன்று விற்பனை செய்ய சிறந்த நேரம்.",
          "severity": "SUCCESS",
          "time": "15 நிமிடங்களுக்கு முன்"
        },
        {
          "id": "3",
          "title": "⛽ எரிபொருள் பாதுகாப்பு சரிபார்ப்பு",
          "description": "உங்கள் கப்பலின் எரிபொருள் இருப்பு 60% மேல் பாதுகாப்பாக உள்ளது.",
          "severity": "INFO",
          "time": "1 மணி நேரத்திற்கு முன்"
        }
      ];
    }
    return [
      {
        "id": "1",
        "title": "🌊 Favorable Marine Weather",
        "description": "Wave height is 1.4m with wind at 18 km/h. Favorable fishing conditions.",
        "severity": "INFO",
        "time": "Just now"
      },
      {
        "id": "2",
        "title": "📈 Tuna Fish Price Spike Alert",
        "description": "Tuna market rate surged to ₹240/kg with HIGH demand. Recommended: SELL TODAY.",
        "severity": "SUCCESS",
        "time": "15 mins ago"
      },
      {
        "id": "3",
        "title": "⛽ Voyage Fuel Buffer Check",
        "description": "Current fuel buffer is optimal (>60%). Voyage status is SAFE TO GO.",
        "severity": "INFO",
        "time": "1 hour ago"
      }
    ];
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "HIGH":
        return Colors.redAccent;
      case "SUCCESS":
        return Colors.greenAccent;
      default:
        return Colors.cyanAccent;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case "HIGH":
        return Icons.warning_amber_rounded;
      case "SUCCESS":
        return Icons.trending_up;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _langProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xff041B43),
          appBar: AppBar(
            backgroundColor: const Color(0xff0A1628),
            elevation: 0,
            title: Text(
              _langProvider.getText("notifications"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (alerts.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      alerts.clear();
                    });
                  },
                  child: Text(
                    _langProvider.getText("clear_all"),
                    style: const TextStyle(color: Colors.cyanAccent),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadNotifications,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff041B43),
                    Color(0xff0A2858),
                  ],
                ),
              ),
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.cyanAccent),
                    )
                  : alerts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_off_outlined,
                                size: 80,
                                color: Colors.white38,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _langProvider.getText("no_alerts"),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            final color = _getSeverityColor(alert["severity"] ?? "");
                            final icon = _getSeverityIcon(alert["severity"] ?? "");

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: color.withOpacity(0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.1),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: color.withOpacity(0.2),
                                    child: Icon(icon, color: color),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                alert["title"] ?? "",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              alert["time"] ?? "",
                                              style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          alert["description"] ?? "",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        );
      },
    );
  }
}
