import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'backgroundLogin.dart';
import 'Homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:cool_alert/cool_alert.dart';

class UserLogin extends StatefulWidget {
  static const String screenRoute = 'UserLogin';

  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLogin createState() => _UserLogin();
}

class _UserLogin extends State<UserLogin> {
  GlobalKey<FormState> _FormKey = GlobalKey<FormState>();
  bool showpass = true;
  final _auth = FirebaseAuth.instance;

  late String email;
  late String password;
  var names = [];
  var emails = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Background(
          child: Form(
            key: _FormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.2),
                Container(
                  width: size.width * 0.25,
                  margin: EdgeInsets.only(left: size.width * 0.75),
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "تسجيل الدخـول",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 45, 66, 142),
                        fontSize: 34),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  width: size.width * 0.25,
                  margin: EdgeInsets.only(left: size.width * 0.7),
                  child: Positioned(
                    child: new Image.asset(
                      'images/logo.png',
                      height: size.height * 0.2,
                      width: size.width * 0.2,
                    ),
                  ),
                ),
                Container(
                  width: size.width * 0.25,
                  margin: EdgeInsets.only(left: size.width * 0.7),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      email = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: "البريد الإلكتروني",
                        hintText: "example@email.com",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 202, 198, 198)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 19,
                          color: Color.fromARGB(255, 45, 66, 142),
                        )),
                    validator: MultiValidator(
                        [RequiredValidator(errorText: 'إلزامي')]),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  width: size.width * 0.25,
                  margin: EdgeInsets.only(left: size.width * 0.7),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "إلزامي";
                      }
                    },
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: showpass,
                    decoration: InputDecoration(
                      labelText: "كلمة المرور",
                      hintText: "********",
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 202, 198, 198)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 19,
                        color: Color.fromARGB(255, 45, 66, 142),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            showpass = !showpass;
                          });
                        },
                        child: showpass
                            ? const Icon(
                                Icons.visibility_off,
                              )
                            : Icon(
                                Icons.visibility,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  child: Container(
                    width: size.width * 0.2,
                    margin: EdgeInsets.only(left: size.width * 0.7),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_FormKey.currentState!.validate()) {
                          try {
                            final user = await _auth.signInWithEmailAndPassword(
                                email: email, password: password);
                            if (user != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));

                              print("تم تسجيل الدخول بنجاح");
                            }
                          } catch (e) {
                            print(e);
                            /*   validator:
                      MultiValidator([
                        RequiredValidator(
                            errorText: 'Incorrect username or password')
                      ]);*/
                            CoolAlert.show(
                              context: context,
                              title: "نعتذر",
                              width: size.width * 0.2,
                              confirmBtnColor: Color.fromARGB(255, 45, 66, 142),
                              //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                              type: CoolAlertType.error,
                              backgroundColor: Color.fromARGB(255, 45, 66, 142),
                              text: "البريد الالكتروني او كلمة المرور خاطئة",
                              confirmBtnText: 'حاول مره اخرى',
                              onConfirmBtnTap: () {
                                Navigator.of(context).pop();
                              },
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        width: size.width * 0.5,
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: new LinearGradient(colors: [
                              Color.fromARGB(255, 45, 66, 142),
                              Color.fromARGB(255, 45, 66, 142),
                            ])),
                        padding: const EdgeInsets.all(0),
                        child: Text(
                          "تسجيـل الـدخـول",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
