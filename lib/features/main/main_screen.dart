import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neverest/l10n/app_localizations.dart';
import 'package:neverest/resources/extensions/app_selectors.dart';

class MainScreen extends ConsumerStatefulWidget{
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainContentState();
}

class _MainContentState extends ConsumerState<MainScreen> {
  int positionIndex = 0;
  late List<Widget> pages;


  @override
  void initState() {
    super.initState();
    initPages();
  }

  void initPages(){
    // pages = getPagesByRole();
  }

  //TODO: Interface by role
  // List<Widget> getPagesByRole(){
  //   final l10n = AppLocalizations.of(context);
  //
  //   return [
  //     Center(child: Text(l10n!.home)),
  //     Center(child: Text(l10n.rewards)),
  //     Center(child: Text(l10n.challenges)),
  //     Center(child: Text(l10n.social)),
  //     Center(child: Text(l10n.wallet)),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sp = context.spacing;
    final c = context.colors;

    pages = [
      Center(child: Text(l10n!.home)),
      Center(child: Text(l10n.rewards)),
      Center(child: Text(l10n.challenges)),
      Center(child: Text(l10n.social)),
      Center(child: Text(l10n.wallet)),
    ];

    //TODO: only for mock. change them all
    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
      BottomNavigationBarItem(icon: const Icon(Icons.card_giftcard_rounded), label: l10n.rewards),
      BottomNavigationBarItem(icon: const Icon(Icons.leaderboard), label: l10n.challenges),
      BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.social),
      BottomNavigationBarItem(icon: const Icon(Icons.wallet), label: l10n.wallet),
    ];

    return Scaffold(
      backgroundColor: c.bgDefault,
      // appBar: _buildAppBar(ref), //TODO: AppBar custom style
      body:
      Padding(
        padding: sp.screenPadding,
        child: pages[positionIndex],
      ),
      bottomNavigationBar: Container(
        // decoration: , //TODO: decoration in styles for bottom nav bar
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: BottomNavigationBar(
            currentIndex: positionIndex,
            onTap: (index) => setState(() => positionIndex = index),
            items: navItems,
        )
      ),
    );
  }

}