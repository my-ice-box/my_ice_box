import 'package:flutter/material.dart';
import 'package:my_ice_box/main.dart';   // MainPage 가 정의된 파일

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _saveId = false;                       // UI 상태만 유지

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text('로그인',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 64),
              const _InputBox(hint: '이메일 주소'),
              const SizedBox(height: 16),
              const _InputBox(hint: '비밀번호', obscure: true),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _saveId,
                    onChanged: (v) => setState(() => _saveId = v ?? false),
                  ),
                  const Text('아이디 저장'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},                    // 아직 미구현
                    child: const Text('아이디/비밀번호 찾기'),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: w,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () {},                      // 로그인 기능 미구현
                  child: const Text('로그인'),
                ),
              ),

              const SizedBox(height: 32),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('또는'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),

              /// 👉 로그인 없이 둘러보기
              SizedBox(
                width: w,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () {
                    // MainPage 로 교체(PushReplacement)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    );
                  },
                  child: const Text('로그인 없이 둘러보기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 텍스트 필드 공통 위젯
class _InputBox extends StatelessWidget {
  final String hint;
  final bool obscure;

  const _InputBox({required this.hint, this.obscure = false, super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscure,
    );
  }
}
