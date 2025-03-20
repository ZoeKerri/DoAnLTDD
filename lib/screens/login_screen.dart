import 'package:doanltdd/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LogInScreen(),
    );
  }
}

class LogInScreen extends StatefulWidget {
  const LogInScreen ({super.key});
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/todo_background.jpg"), // Ảnh nền
            fit: BoxFit.cover, // Phủ toàn bộ màn hình
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tabs Login & Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => isLogin = true),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLogin ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 1.5,
                      height: 20,
                      color: Colors.white, // Divider giữa 2 tab
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () => setState(() => isLogin = false),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: !isLogin ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Animated Form chuyển đổi
                AnimatedCrossFade(
                  firstChild: buildLoginForm(),
                  secondChild: buildSignUpForm(),
                  crossFadeState: isLogin
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Form Login
  Widget buildLoginForm() {
    return Column(
      children: [
        buildTextField("Username"),
        SizedBox(height: 10),
        buildTextField("Password", isPassword: true),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            child: Text("Login", style: TextStyle(fontSize: 18)),
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }

  // Form Sign Up
  Widget buildSignUpForm() {
    return Column(
      children: [
        buildTextField("Name"),
        SizedBox(height: 10),
        buildTextField("Email"),
        SizedBox(height: 10),
        buildTextField("Password", isPassword: true),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isLogin = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            child: Text("Sign Up", style: TextStyle(fontSize: 18)),
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }

  // Widget ô nhập liệu
  Widget buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.blue.withOpacity(0.6), // Làm nền mờ để dễ nhìn hơn
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

