import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_work/Jobs/job_screen.dart';
import 'package:flutter_work/LoginPage/login_screen.dart';

class UserState extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:FirebaseAuth.instance.authStateChanges(),
      builder: (ctx , userSnapshot){
          if(userSnapshot.data== null){
            print('User is not Logged in Yet');
            return const LoginPage();
          }
          else if(userSnapshot.hasData){
            print('User is Alredy Logged in Yet');
            return const JobScreen();
          }

          else if(userSnapshot.hasError){
            return const Scaffold(
              body: Center(
                child: Text('An Error has been Occurred. Try Again Later'),
              ),
            );
          }
          else if(userSnapshot.connectionState==ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
         return const Scaffold(
           body: Center(
             child: Text('Something went Wrong'),
           ),
         );
      },
    );
  }
}
