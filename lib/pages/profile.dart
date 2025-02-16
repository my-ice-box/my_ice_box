import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_ice_box/main.dart'; // MyAppState를 사용하기 위한 import


class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MyAppState를 통해 Supabase 클라이언트를 접근
    final appState = Provider.of<MyAppState>(context, listen: false);
    final supabase = appState.supabase;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프로필 사진 (Asset 이미지가 없으면 기본 아이콘으로 대체)
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
              const SizedBox(height: 16),
              // 사용자 이름 (추후 실제 데이터를 불러오도록 수정 가능)
              const Text(
                "User Name",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 사용자 이메일 (추후 실제 데이터를 불러오도록 수정 가능)
              const Text(
                "user@example.com",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              // 로그아웃 버튼: try-catch를 통한 Supabase 로그아웃 처리
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await supabase.auth.signOut();
                    // 로그아웃 성공 시 이전 화면으로 돌아갑니다.
                    Navigator.of(context).pop();
                  } catch (error) {
                    // 오류 발생 시 SnackBar로 오류 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error signing out: $error"),
                        duration: const Duration(milliseconds: 320),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

