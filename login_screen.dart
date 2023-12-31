import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_work/ForgetPassword/forget_password.dart';
import 'package:flutter_work/Services/global_method.dart';
import 'package:flutter_work/Services/global_var.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_work/Signup/signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _passwordController = TextEditingController(text: '');
  final TextEditingController _emailController = TextEditingController(text: '');

  final _loginFormKey = GlobalKey<FormState>();
  final FocusNode _passFocusNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    _animationController.forward();
  }
void _submitFormOnLogin() async {
  final isValid = _loginFormKey.currentState!.validate();
  if(isValid){
    setState(() {
      _isLoading = true;
    });
    try{
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim().toLowerCase(),
          password:_passwordController.text.trim(),
      );
      Navigator.canPop(context)? Navigator.pop(context):null;
    }catch(error){
      setState(() {
        _isLoading = false;
      });
      GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      print('Error Occured $error');
    }
  }
  setState(() {
    _isLoading=false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: loginurlimage,
            placeholder: (context, url) => Image.asset('images/signin.jpg', fit: BoxFit.fill),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 80, right: 80),
                    child: Image.asset('images/logopic.jpg'),
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please Enter a valid Email';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          focusNode: _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          obscureText: !_obscureText,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Please Enter a Valid Password';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText ? Icons.visibility: Icons.visibility_off,
                                color: Colors.white,
                              ),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment:Alignment.bottomRight ,
                          child: TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>const ForgetPassword()));
                            },
                            child: const Text('Forget Password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontStyle: FontStyle.italic,
                            ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        MaterialButton(onPressed: _submitFormOnLogin,
                        color:Colors.black54,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 14
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),)
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height:40),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Do not have an Account?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )
                                ),
                                const TextSpan(text: '  '),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                      ..onTap = ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp())),
                                  text: 'SignUp',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,

                                  )
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
