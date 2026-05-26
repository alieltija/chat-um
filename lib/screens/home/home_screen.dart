import 'dart:async';

import 'package:chatum/providers/auth_provider.dart';
import 'package:chatum/screens/home/pages/search_page.dart';
import 'package:chatum/services/db_services.dart';
import 'package:provider/provider.dart';
import './pages/profile_page.dart';
import './pages/recent_conversation_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late double _deviceHeight;
  late double _deviceWidth;

  Timer? _lastSeenTimer;

  @override
  void initState() {
    super.initState();
    synclastSeen();

    _lastSeenTimer = Timer.periodic(Duration(minutes: 3), (timer) {
      synclastSeen();
    });

    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  void synclastSeen() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      DbServices.instance.updateLastSeen(authProvider.user!.uid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lastSeenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: _deviceHeight * 0.02,
          fontWeight: FontWeight.w500,
        ),
        title: Text("Chat'um"),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.blue,
          indicatorColor: Colors.blue,
          tabs: [
            Icon(Icons.people_outline, size: _deviceHeight * 0.035),
            Icon(Icons.chat_bubble_outline, size: _deviceHeight * 0.035),
            Icon(Icons.person_outline, size: _deviceHeight * 0.035),
          ],
        ),
      ),
      body: tabBarPages(),
    );
  }

  Widget tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(height: _deviceHeight, width: _deviceWidth),
        RecentConversationPage(height: _deviceHeight, width: _deviceWidth),
        ProfilePage(height: _deviceHeight, width: _deviceWidth),
      ],
    );
  }
}
