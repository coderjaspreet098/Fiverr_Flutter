import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_work/Services/global_method.dart';
import 'package:flutter_work/Services/global_var.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _nameTextcontroller = TextEditingController(text: '');
  final TextEditingController _emailTextcontroller = TextEditingController(text: '');
  final TextEditingController _passwordTextcontroller = TextEditingController(text: '');
  final TextEditingController _phonecontroller = TextEditingController(text: '');
  final TextEditingController _locationcontroller = TextEditingController(text: '');

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phonenumberFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();

  bool _obscureText = true;
  bool _isLoading = false;

  String ? imageUrl;

  final _signupformkey = GlobalKey<FormState>();
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _animationController.dispose();
    _nameTextcontroller.dispose();
    _emailTextcontroller.dispose();
    _passwordTextcontroller.dispose();
    _phonecontroller.dispose();
    _locationcontroller.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _positionFocusNode.dispose();
    _phonenumberFocusNode.dispose();
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

  void _showImageDialog(){
    showDialog(
        context:context,
        builder:(context){
          return AlertDialog(
            title: const Text('Please Choose an Option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    _getfromcamera();
                  },
                  child: const Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.camera,
                        color: Colors.purple,),
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.purple,
                        ),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: (){
                   _getfromgallery();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.image,
                          color: Colors.purple,),
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: Colors.purple,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void _getfromcamera()async{
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getfromgallery()async{
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filepath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath:filepath , maxHeight: 1080, maxWidth: 1080);
    if(croppedImage!=null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _submitFormOnSignUp()async{
    final isValid = _signupformkey.currentState!.validate();
    if(isValid){
      if(imageFile== null){
        GlobalMethod.showErrorDialog(
            error:'Please Pick an Image' ,
            ctx:context );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try{
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextcontroller.text.trim().toLowerCase(),
            password:_passwordTextcontroller.text.trim(), );
        final User?user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance.ref().child('userImages').child(_uid + '.jpg');
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id' :_uid,
          'name' : _nameTextcontroller.text,
          'email' : _emailTextcontroller.text,
          'userImage': imageUrl,
          'phoneNumber': _phonecontroller.text,
          'location': _locationcontroller.text,
          'createdAt':Timestamp.now(),
        });
        Navigator.canPop(context)?Navigator.pop(context):null;
      }catch(error){
        setState(() {
          _isLoading= false;
        });
        GlobalMethod.showErrorDialog(
            error: error.toString(),
            ctx: context);
      }
    }
    setState(() {
      _isLoading= false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
     body: Stack(
       children: [
         CachedNetworkImage(
           imageUrl: signupurlimage,
             placeholder: (context ,url)=>Image.asset('images/signin.jpg',
             fit: BoxFit.fill),
         errorWidget: (context,url, error)=>const Icon(Icons.error),
           width: double.infinity,
           height: double.infinity,
           fit: BoxFit.cover,
           alignment: FractionalOffset(_animation.value,0),
         ),
         Container(
           color:Colors.black54,
           child: Padding(
             padding:const EdgeInsets.symmetric(
               horizontal: 16,
               vertical: 80,
             ),
             child: ListView(
               children: [
                 Form(
                   key:_signupformkey,
                   child: Column(
                     children: [
                       GestureDetector(
                         onTap: (){
                           _showImageDialog();
                         },
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: Container(
                             width: size.width * 0.24,
                             height: size.width * 0.24,
                             decoration: BoxDecoration(
                               border: Border.all(width: 1,color: Colors.cyanAccent),
                               borderRadius: BorderRadius.circular(100),
                             ),
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(70),
                               child: imageFile == null
                               ? const Icon(Icons.camera_enhance_sharp,color: Colors.cyan,size: 30,)
                                   : Image.file(imageFile!, fit: BoxFit.fill),
                             ),
                           ),
                         ),
                       ),
                       const SizedBox(height: 20),
                       TextFormField(
                         textInputAction: TextInputAction.next,
                         onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocusNode),
                         keyboardType: TextInputType.name,
                         controller: _nameTextcontroller,
                         validator: (value) {
                           if (value!.isEmpty) {
                             return 'This Field is Missing';
                           } else {
                             return null;
                           }
                         },
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(
                           hintText: 'Full Name',
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
                       const SizedBox(height: 20),
                       TextFormField(
                         textInputAction: TextInputAction.next,
                         onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                         keyboardType: TextInputType.emailAddress,
                         controller: _emailTextcontroller,
                         validator: (value) {
                           if (value!.isEmpty || !value.contains('@')) {
                             return 'Please Enter a Valid Email Address';
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
                       const SizedBox(height: 20),
                       TextFormField(
                         textInputAction: TextInputAction.next,
                         onEditingComplete: () => FocusScope.of(context).requestFocus(_phonenumberFocusNode),
                         keyboardType: TextInputType.visiblePassword,
                         controller: _passwordTextcontroller,
                         obscureText: !_obscureText,
                         validator: (value) {
                           if (value!.isEmpty || value.length<7) {
                             return 'Please Enter a Valid Password';
                           } else {
                             return null;
                           }
                         },
                         style: const TextStyle(color: Colors.white),
                         decoration:  InputDecoration(
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
                           hintStyle:  const TextStyle(color: Colors.white),
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
                       const SizedBox(height: 20),
                       TextFormField(
                         textInputAction: TextInputAction.next,
                         onEditingComplete: () => FocusScope.of(context).requestFocus(_positionFocusNode),
                         keyboardType: TextInputType.phone,
                         controller: _phonecontroller,
                         validator: (value) {
                           if (value!.isEmpty ) {
                             return 'This Field is Missing';
                           } else {
                             return null;
                           }
                         },
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(
                           hintText: 'Phone Number',
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
                       const SizedBox(height: 20),
                       TextFormField(
                         textInputAction: TextInputAction.next,
                         onEditingComplete: () => FocusScope.of(context).requestFocus(_positionFocusNode),
                         keyboardType: TextInputType.name,
                         controller: _locationcontroller,
                         validator: (value) {
                           if (value!.isEmpty ) {
                             return 'This Field is Missing';
                           } else {
                             return null;
                           }
                         },
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(
                           hintText: 'Address',
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
                       const SizedBox(height: 25),
                       _isLoading ?
                           Center(
                             child: Container(
                               width: 70,
                               height: 70,
                               child: const CircularProgressIndicator(),
                             ),
                           ):
                           MaterialButton(
                               onPressed: (){
                                 _submitFormOnSignUp();
                               },
                             color: Colors.cyan,
                             elevation: 8,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(13),
                             ),
                             child: const Padding(
                               padding: EdgeInsets.symmetric(
                                 vertical: 14 ,
                               ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text('SignUp',
                                   style: TextStyle(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                     fontSize: 20,
                                   ),)
                                 ],
                               ),
                             ),
                           ),
                       const SizedBox(height: 40),
                       Center(
                         child: RichText(
                           text: TextSpan(
                             children: [
                               const TextSpan(
                                 text: 'Already have an Account?',
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 )
                               ),
                               const TextSpan(
                                 text: '  '
                               ),
                               TextSpan(
                                 recognizer: TapGestureRecognizer()
                                     ..onTap =()=> Navigator.canPop(context)
                                     ?Navigator.pop(context)
                                      :null,
                                 text: 'Login',
                                   style: const TextStyle(
                                     color: Colors.cyan,
                                     fontWeight: FontWeight.bold,
                                     fontSize: 16,
                                   )
                               ),
                             ]
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),
         ),
       ],
     ),
    );
  }
}
