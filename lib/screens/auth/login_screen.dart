import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatum/providers/auth_provider.dart' as myauth;
import '../../services/navigation_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? email;
  String? password;

  myauth.AuthProvider? authProvider;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Align(
        alignment: AlignmentGeometry.center,
        child: ChangeNotifierProvider<myauth.AuthProvider>.value(
          value: myauth.AuthProvider.instance,
          child: _loginScreenUI(),
        ),
      ),
    );
  }

  Widget _loginScreenUI() {
    return Builder(
      builder: (BuildContext context) {
        authProvider = Provider.of<myauth.AuthProvider>(context);
        print(authProvider?.user);
        return Container(
          height: _deviceHeight * 0.60,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headingWidget(),
              _inputForm(),
              _loginButton(),
              _registerGestureText(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return SizedBox(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "WELCOME BACK!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please login to your account.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return SizedBox(
      height: _deviceHeight * 0.16,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState?.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_emailInputForm(), _passwordInputForm()],
        ),
      ),
    );
  }

  Widget _emailInputForm() {
    return TextFormField(
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email address.";
        } else if (!RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        ).hasMatch(value)) {
          return "Please enter a valid email address.";
        }
        return null;
        // return value!.isNotEmpty &&
        //         value.contains("@") &&
        //         value.contains(".com")

        //     : "please enter valid email";
      },
      onSaved: (value) {
        setState(() {
          email = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Email Address",
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordInputForm() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Password is required";
        }
        if (value.length < 8) {
          return "Please enter a password with at least 8 characters";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          password = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Password",
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: Consumer<myauth.AuthProvider>(
        builder: (context, auth, child) {
          return MaterialButton(
            onPressed: auth.status == myauth.AuthStatus.authenticating
                ? null // Disable button while loading
                : () async {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();
                      await auth.logInWithEmailAndPassword(
                        context,
                        email!,
                        password!,
                      );
                    }
                  },
            color: Colors.blue,
            child: auth.status == myauth.AuthStatus.authenticating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _registerGestureText() {
    return Row(
      spacing: _deviceHeight * 0.004,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: Colors.white,
            fontSize: _deviceHeight * 0.017,
            fontWeight: FontWeight.w200,
          ),
        ),

        GestureDetector(
          onTap: () {
            NavigationServices.instance.navigateToReplacement("register");
          },
          child: Text(
            "Register",
            style: TextStyle(
              color: Colors.white,
              fontSize: _deviceHeight * 0.018,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
