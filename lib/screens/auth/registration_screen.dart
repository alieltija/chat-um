import 'dart:io';

import 'package:chatum/services/media_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/navigation_services.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegistrationScreenState();
  }
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late double _deviceHeight;
  late double _deviceWidth;

  String? name;
  String? email;
  String? password;
  File? image;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: registrationScreenUI(),
      ),
    );
  }

  Widget registrationScreenUI() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        height: _deviceHeight * 0.75,
        width: _deviceWidth,
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _headingWidget(),
            _inputForm(),
            _registerButton(),
            _loginRedirect(),
          ],
        ),
      ),
    );
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.12,
      width: _deviceWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's get going!",
            style: TextStyle(
              fontSize: _deviceHeight * 0.037,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Please enter Your details",
            style: TextStyle(
              fontSize: _deviceHeight * 0.023,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.35,
      width: _deviceWidth,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState!.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSelector(),
            _nameInputForm(),
            _emailInputForm(),
            _passwordInputForm(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelector() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          XFile? xFile = await MediaServices.instance.pickImageFromGallery();
          if (xFile != null) {
            File imageFile = File(xFile.path);

            print("Image selected: ${imageFile.path}");
            setState(() {
              image = imageFile; // Now this is safe
            });
          } else {
            print("No image was selected.");
          }
        },
        child: Container(
          height: _deviceHeight * 0.10,
          width: _deviceHeight * 0.10,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(_deviceHeight * 0.10),
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(
                    _deviceHeight * 0.10,
                  ),
                  child: Image.file(image!, fit: BoxFit.cover),
                )
              : Icon(
                  Icons.add_a_photo,
                  size: _deviceHeight * 0.0350,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  Widget _nameInputForm() {
    return TextFormField(
      autocorrect: false,
      keyboardType: TextInputType.name,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your name";
        }
        return null;
      },
      onSaved: (value) {
        name = value.toString().trim();
      },
      decoration: InputDecoration(
        hintText: "Name",
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
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
      },
      onSaved: (value) {
        email = value.toString().trim();
      },
      decoration: InputDecoration(
        hintText: "Email",
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
      onSaved: (value) {
        password = value.toString().trim();
      },
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
        password = value.toString().trim();
      },
      decoration: InputDecoration(
        hintText: "Password",
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (_formKey.currentState!.validate()) {
            print("ok");
          }
        },
        color: Colors.blue,
        child: Text(
          "Register",
          style: TextStyle(
            fontSize: _deviceHeight * 0.020,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _loginRedirect() {
    return Row(
      spacing: _deviceHeight * 0.004,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            color: Colors.white,
            fontSize: _deviceHeight * 0.017,
            fontWeight: FontWeight.w200,
          ),
        ),

        GestureDetector(
          onTap: () {
            NavigationServices.instance.navigateToReplacement("login");
          },
          child: Text(
            "Login",
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
