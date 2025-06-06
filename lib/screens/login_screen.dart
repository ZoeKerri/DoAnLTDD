import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doanltdd/screens/home_screen.dart';
import 'package:doanltdd/models/users.dart';
import 'package:doanltdd/database/firebase_db_service.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool isLogin = true;
  bool obscureLoginPassword = true;
  bool obscureSignUpPassword = true;
  bool obscureConfirmPassword = true;
  bool obscureOldPassword = true;
  bool obscureNewPassword = true;

  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _changePasswordFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();
  final changeEmailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  /// Hàm tiện ích để lưu currentUserId vào SharedPreferences
  Future<void> _saveCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', userId);
  }

  /// Hàm tiện ích để lưu currentUsername vào SharedPreferences
  Future<void> _saveCurrentUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUsername', username);
  }

  Future<void> _saveCurrentUserGmail(String userGmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentEmail', userGmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_screen.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _switchTab("Login", isLogin, () => setState(() => isLogin = true)),
                    SizedBox(width: 10),
                    Container(width: 1.5, height: 20, color: Colors.white),
                    SizedBox(width: 10),
                    _switchTab("Sign Up", !isLogin, () => setState(() => isLogin = false)),
                  ],
                ),
                SizedBox(height: 40),
                AnimatedCrossFade(
                  firstChild: buildLoginForm(),
                  secondChild: buildSignUpForm(),
                  crossFadeState:
                      isLogin ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTab(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          buildTextField("Email", controller: emailController, validator: _validateEmail),
          SizedBox(height: 10),
          buildTextField(
            "Password",
            isPassword: true,
            controller: passwordController,
            validator: _validateLoginPassword,
            obscure: obscureLoginPassword,
            toggleObscure: () => setState(() => obscureLoginPassword = !obscureLoginPassword),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showChangePasswordDialog(),
              child: Text("Đổi mật khẩu", style: TextStyle(color: Colors.white70)),
            ),
          ),

          ElevatedButton(
            onPressed: _handleLogin,
            style: _buttonStyle(),
            child: _buttonText("Login"),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

Widget buildSignUpForm() {
  return Form(
    key: _signUpFormKey,
    child: Column(
      children: [
        buildTextField("Name", controller: nameController, validator: _validateNotEmpty),
        SizedBox(height: 10),
        buildTextField("Email", controller: emailController, validator: _validateEmail),
        SizedBox(height: 10),
        buildTextField(
          "Password",
          isPassword: true,
          controller: signUpPasswordController,
          validator: _validateStrongPassword,
          obscure: obscureSignUpPassword,
          toggleObscure: () =>
              setState(() => obscureSignUpPassword = !obscureSignUpPassword),
        ),
        SizedBox(height: 10),
        buildTextField(
          "Confirm Password", 
          isPassword: true,
          controller: signUpConfirmPasswordController, 
          validator: (value) => _validateConfirmPassword(value, signUpPasswordController.text), 
          obscure: obscureConfirmPassword, 
          toggleObscure: () =>
              setState(() => obscureConfirmPassword = !obscureConfirmPassword),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _handleSignUp,
          style: _buttonStyle(),
          child: _buttonText("Sign Up"),
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

  Widget buildTextField(
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscure,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.blue.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: toggleObscure,
              )
            : null,
      ),
      validator: validator,
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Đổi mật khẩu"),
              content: Form(
                key: _changePasswordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextField(
                      "Email",
                      controller: changeEmailController,
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 10),
                    buildTextField(
                      "Mật khẩu cũ",
                      isPassword: true,
                      controller: oldPasswordController,
                      validator: _validateLoginPassword,
                      obscure: obscureOldPassword,
                      toggleObscure: () => setState(() =>
                          obscureOldPassword = !obscureOldPassword),
                    ),
                    SizedBox(height: 10),
                    buildTextField(
                      "Mật khẩu mới",
                      isPassword: true,
                      controller: newPasswordController,
                      validator: _validateStrongPassword,
                      obscure: obscureNewPassword,
                      toggleObscure: () => setState(() =>
                          obscureNewPassword = !obscureNewPassword)
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    changeEmailController.clear();
                    oldPasswordController.clear();
                    newPasswordController.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: _handleChangePassword,
                  child: Text("Xác nhận"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _handleLogin() async {
  if (_loginFormKey.currentState!.validate()) {
    final passwordError = _validateStrongPassword(passwordController.text.trim());
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(passwordError)));
      return;
    }

    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = authResult.user!.uid;

      await _saveCurrentUserId(uid);

      final dbRef = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await dbRef.get();
      String fetchedName = '';
      String fetchedGmail = '';
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        fetchedName = (data['name'] ?? '') as String;
        fetchedGmail = (data['email'] ?? '') as String;
      }
      if (fetchedName.isNotEmpty) {
        await _saveCurrentUsername(fetchedName);
      }
      if (fetchedGmail.isNotEmpty){
        await _saveCurrentUserGmail(fetchedGmail);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thành công")),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Lỗi đăng nhập";
      if (e.code == 'wrong-password') {
        message = "Sai mật khẩu. Vui lòng thử lại.";
      } else if (e.code == 'user-not-found') {
        message = "Không tìm thấy tài khoản với email này.";
      } else if (e.code == 'invalid-email') {
        message = "Email không hợp lệ.";
      } else if (e.code == 'too-many-requests') {
        message = "Bạn đã đăng nhập sai quá nhiều lần. Vui lòng thử lại sau.";
      } else {
        message = e.message ?? message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
String? _validateConfirmPassword(String? value, String originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập lại mật khẩu!';
  }
  if (value != originalPassword) {
    return 'Hai mật khẩu không khớp!';
  }
  return null;
}

  Future<void> _handleSignUp() async {
    if (_signUpFormKey.currentState!.validate()) {
      try {
        // 1. Tạo user mới bằng FirebaseAuth
        final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: signUpPasswordController.text.trim(),
        );
        final newUserId = authResult.user!.uid;
        final newUserName = nameController.text.trim();

        // 2. Tạo object Users và lưu vào Realtime Database tại path "users/{uid}"
        final newUser = Users(
          id: newUserId,
          name: newUserName,
          email: emailController.text.trim(),
          password: signUpPasswordController.text.trim(),
        );
        await FirebaseDBService().create(
          path: "users/${newUser.id}",
          data: newUser.toMap(),
        );

        // 3. Lưu currentUserId và currentUsername vào SharedPreferences
        await _saveCurrentUserId(newUserId);
        await _saveCurrentUsername(newUserName);
        await _saveCurrentUserGmail(newUser.email);

        // 4. Hiển thị thông báo, chuyển sang tab Login để người dùng có thể đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thành công. Vui lòng đăng nhập lại.")),
        );
        setState(() => isLogin = true);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? "Lỗi đăng ký")));
      }
    }
  }

  Future<void> _handleChangePassword() async {
    if (_changePasswordFormKey.currentState!.validate()) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        final email = changeEmailController.text.trim();
        final oldPassword = oldPasswordController.text.trim();
        final newPassword = newPasswordController.text.trim();

      // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );

        await currentUser!.reauthenticateWithCredential(credential);

      // Update password in FirebaseAuth
        await currentUser.updatePassword(newPassword);

      // Update password in Realtime Database
        final uid = currentUser.uid;
        await FirebaseDatabase.instance.ref("users/$uid").update({
          'password': newPassword,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đổi mật khẩu thành công")),
        );

      // Xóa dữ liệu sau khi xong
        changeEmailController.clear();
        oldPasswordController.clear();
        newPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        String message = "Lỗi đổi mật khẩu";
        if (e.code == 'wrong-password') message = "Mật khẩu cũ không đúng";
        else if (e.code == 'user-not-found') message = "Không tìm thấy tài khoản";
        else message = e.message ?? message;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }
  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );

  Widget _buttonText(String text) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12), child: Text(text));

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) return "Email không hợp lệ";
    return null;
  }

  String? _validateLoginPassword(String? value) {
    if (value == null || value.length < 10) return "Mật khẩu tối thiểu 10 ký tự";
    return null;
  }

  String? _validateStrongPassword(String? value) {
    if (value == null ||
        value.length < 10 ||
        !RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      return "Mật khẩu ≥10 ký tự, chứa chữ hoa & thường";
    }
    return null;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) return "Trường này không được để trống";
    return null;
  }
}
