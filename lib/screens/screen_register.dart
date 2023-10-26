import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personalcloset/models/model_auth.dart';
import 'package:personalcloset/models/model_register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 회원가입 화면
class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterModel(),
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            EmailInput(),
            PasswordInput(),
            PasswordConfirmInput(),
            NicknameInput(),
            RegistButton()
          ],
        ),
      ),
    );
  }
}

// 이메일 입력
class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (email) {
          register.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'email',
          helperText: '',
        ),
      ),
    );
  }
}

// 비밀번호 입력
class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (password) {
          register.setPassword(password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'password',
          helperText: '',
          errorText: register.password != register.passwordConfirm
              ? 'Password incorrect'
              : null,
        ),
      ),
    );
  }
}

// 비밀번호 확인
class PasswordConfirmInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (password) {
          register.setPasswordConfirm(password);
        },
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'password confirm',
          helperText: '',
        ),
      ),
    );
  }
}

// 닉네임 입력
class NicknameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      child: TextField(
        onChanged: (nickname) {
          register.setNickname(nickname); // 닉네임 설정
        },
        decoration: InputDecoration(
          labelText: 'Nickname',
          helperText: '',
        ),
      ),
    );
  }
}

// 회원가입 버튼
class RegistButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final register = Provider.of<RegisterModel>(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        // 버튼 클릭시 Firebase로 데이터 전송
        onPressed: (register.password != register.passwordConfirm)
            ? null
            : () async {
                await authClient
                    .registerWithEmail(register.email, register.password)
                    .then((registerStatus) async {
                  if (registerStatus == AuthStatus.registerSuccess) {
                    final user = authClient.user;
                    if (user != null) {
                      // Firestore에 데이터 저장
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                          'nickname': register.nickname,
                        });
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('Regist Success')),
                          );
                        Navigator.pop(context);
                      } catch (e) {
                        print('Firestore 데이터 저장 오류: $e'); // 오류 메시지를 출력
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('Regist Fail')),
                          );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text('Regist Fail')),
                      );
                  }
                });
              },
        child: Text('Regist'),
      ),
    );
  }
}
