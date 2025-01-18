import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget{
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    WidgetsBinding.instance.addPostFrameCallback((_) {

      Future.delayed(const Duration(milliseconds: 500), () {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 1),
              content: Text('profile doesn\'t exist'),
            ),
          );
        }
      });
    });

    return Scaffold(
      body: Placeholder(
      child: Center(
        child: Text('Profile Page'),
      ),
      ),
    );
  }
}