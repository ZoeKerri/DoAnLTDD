import 'package:doanltdd/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:doanltdd/database/database_helper.dart';
import 'package:doanltdd/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doanltdd/database/firebase_db_service.dart';
class LogInScreen extends StatefulWidget {
  const LogInScreen ({super.key});
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool isLogin = true;

  Future<void> _saveCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userId);
  }
  Future<void> _saveCurrentUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUsername', username);
  }

  // Key cho form validation
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Controllers để lấy dữ liệu nhập
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController signUpPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_screen.png"), // Ảnh nền
            fit: BoxFit.cover,
            alignment: Alignment.center
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
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          buildTextField("Username", controller: usernameController, validator: (value) {
            if (value == null || value.isEmpty) return "Username không được để trống";
            return null;
          }),
          SizedBox(height: 10),
          buildTextField("Password", isPassword: true, controller: passwordController, validator: (value) {
            if (value == null || value.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
            return null;
          }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_loginFormKey.currentState!.validate()) {
                final user = await DatabaseHelper.instance.getUserByNameAndPassword(
                  usernameController.text.trim(),
                  passwordController.text.trim(),
                );

                if (user != null) {
                  await _saveCurrentUserId(user.id.toString());
                  await _saveCurrentUsername(user.name);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đăng nhập thành công!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tên hoặc mật khẩu không đúng")),
                  );
                }
              }
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
      ),
    );
  }

  // Form Sign Up
  Widget buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          buildTextField("Name", controller: nameController, validator: (value) {
            if (value == null || value.isEmpty) return "Name không được để trống";
            return null;
          }),
          SizedBox(height: 10),
          buildTextField("Email", controller: emailController, validator: (value) {
            if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return "Email không hợp lệ";
            }
            return null;
          }),
          SizedBox(height: 10),
          buildTextField("Password", isPassword: true, controller: signUpPasswordController, validator: (value) {
            if (value == null || value.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
            return null;
          }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_signUpFormKey.currentState!.validate()) {
                final newUser = User(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: signUpPasswordController.text.trim(),
                );
                final int newId = await DatabaseHelper.instance.insertUser(newUser);
                await _saveCurrentUserId(newId.toString());
                await _saveCurrentUsername(newUser.name);
                await FirebaseDBService().create(path: "users/${newId}", data: newUser.toMap());
                setState(() {
                  isLogin = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đăng ký thành công! Hãy quay lại đăng nhập")),
                );
              }
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
      ),
    );
  }

  // Widget ô nhập liệu với kiểm tra
  Widget buildTextField(String hint, {bool isPassword = false, TextEditingController? controller, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
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
      validator: validator, // Thêm validator để kiểm tra dữ liệu
    );
  }
}