import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neverest/features/home/home_screen.dart';
import 'package:neverest/l10n/app_localizations.dart';
import 'package:neverest/resources/extensions/app_selectors.dart';
import 'package:neverest/resources/styles/bottom_box_decoration_style.dart';

import '../../resources/styles_managers/assets_manager.dart';

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
    pages = getPagesByRole();
  }

  List<Widget> getPagesByRole(){
    return [
      const HomeScreen(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sp = context.spacing;
    final c = context.colors;

    pages = [
      const HomeScreen(),
      Center(child: Text(l10n!.rewards)),
      Center(child: Text(l10n.challenges)),
      Center(child: Text(l10n.social)),
      Center(child: Text(l10n.wallet)),
    ];

    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageAssets.home),
          activeIcon: SvgPicture.asset(ImageAssets.home, colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn)),
          label: l10n.home),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageAssets.rewards),
          activeIcon: ImageIcon(const AssetImage(ImageAssets.gift), color: context.colors.primary),
          // activeIcon: SvgPicture.asset(ImageAssets.home, colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn)),
          label: l10n.rewards),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageAssets.challenges),
          activeIcon: ImageIcon(const AssetImage(ImageAssets.gift), color: context.colors.primary),
          // activeIcon: SvgPicture.asset(ImageAssets.home, colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn)),
          label: l10n.challenges),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageAssets.social),
          activeIcon: ImageIcon(const AssetImage(ImageAssets.gift), color: context.colors.primary),
          // activeIcon: SvgPicture.asset(ImageAssets.home, colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn)),
          label: l10n.social),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(ImageAssets.wallet),
          activeIcon: ImageIcon(const AssetImage(ImageAssets.gift), color: context.colors.primary),
          // activeIcon: SvgPicture.asset(ImageAssets.home, colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn)),
          label: l10n.wallet),
    ];

    return Scaffold(
      backgroundColor: c.bgDefault,
      body:
      Padding(
        padding: sp.screenPadding,
        child: pages[positionIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BottomBoxDecoration.bottomBoxDecoration(context),
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