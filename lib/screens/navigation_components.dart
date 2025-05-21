import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talktext/screens/settings_screen.dart';

import 'edit_profile_screen.dart';

class NavigationComponents {
  static Widget buildModernBottomNavBar({
    required BuildContext context,
    required int currentIndex,
    required Function(int) onTap,
    required String Function(String) translate,
    required bool isMagnified,
    required Color primaryColor,
    required Color textColor,
    required PageController pageController,
    required Function(String) speak,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            onTap(index);
            pageController.jumpToPage(index);
            speak(_getNavItemName(index, translate));
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedFontSize: isMagnified ? 14 : 12,
          unselectedFontSize: isMagnified ? 12 : 10,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(),
          items: [
            _buildNavItem(
                Icons.home_rounded, Icons.home_filled, translate('home'), 0,
                currentIndex),
            _buildNavItem(
                Icons.forum_rounded, Icons.forum, translate('chats'), 1,
                currentIndex),
            _buildNavItem(Icons.add_comment_rounded, Icons.add_comment,
                translate('newChat'), 2, currentIndex),
            _buildNavItem(
                Icons.person_rounded, Icons.person, translate('profile'), 3,
                currentIndex),
          ],
        ),
      ),
    );
  }


  static BottomNavigationBarItem _buildNavItem(
      IconData icon,
      IconData activeIcon,
      String label,
      int index,
      int currentIndex
      ) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          currentIndex == index ? activeIcon : icon,
          key: ValueKey<int>(currentIndex == index ? index : index + 10),
        ),
      ),
      label: label,
    );
  }

  static String _getNavItemName(int index, String Function(String) translate) {
    switch (index) {
      case 0: return translate('home');
      case 1: return translate('chats');
      case 2: return translate('newChat');
      case 3: return translate('profile');
      default: return "";
    }
  }

  static Widget buildAccessibleDrawer({
    required BuildContext context,
    required String username,
    required String phone,
    required bool isMagnified,
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
    required Color textColor,
    required String Function(String) translate,
    required String Function(String) translateWithUsername,
    required Function(BuildContext, String, [GestureTapCallback?]) handleDoubleTap,
    required Function(int) onNavItemSelected,
    required Function(BuildContext) logout,
  }) {
    return Drawer(
      child: Container(
        color: primaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: accentColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => handleDoubleTap(context, translate('profile')),
                    child: CircleAvatar(
                      radius: isMagnified ? 40 : 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.account_circle_rounded,
                        size: isMagnified ? 50 : 40,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => handleDoubleTap(context, translate('welcome')),
                    child: Text(
                      translate('welcome'),
                      style: GoogleFonts.poppins(
                        fontSize: isMagnified ? 24 : 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: secondaryColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => handleDoubleTap(context, "${translate('profile')} $username"),
                    child: Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: isMagnified ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => handleDoubleTap(context, "${translate('phone')}: $phone"),
                    child: Text(
                      phone,
                      style: GoogleFonts.poppins(
                        fontSize: isMagnified ? 18 : 14,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.home_rounded,
              text: translate('home'),
              isMagnified: isMagnified,
              textColor: textColor,
              onTap: () {
                onNavItemSelected(0);
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.forum_rounded,
              text: translate('chats'),
              isMagnified: isMagnified,
              textColor: textColor,
              onTap: () {
                onNavItemSelected(1);
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.add_comment_rounded,
              text: translate('newChat'),
              isMagnified: isMagnified,
              textColor: textColor,
              onTap: () {
                onNavItemSelected(2);
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.edit_rounded,
              text: translate('editProfile'),
              isMagnified: isMagnified,
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.settings_rounded,
              text: translate('settings'),
              isMagnified: isMagnified,
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onSettingsChanged: () {},
                      isMagnified: isMagnified,
                    ),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.logout_rounded,
              text: translate('logout'),
              isMagnified: isMagnified,
              textColor: textColor,
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isMagnified,
    required Color textColor,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(text,
        style: GoogleFonts.poppins(
          fontSize: isMagnified ? 18 : 14,
          color: textColor,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.white.withOpacity(0.8),
    );
  }
}