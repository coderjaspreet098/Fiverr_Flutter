import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_work/Services/global_method.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../Persistent/persistent.dart';
import '../Services/global_var.dart';
import '../Widgets/bottom_nav_bar.dart';
class UploadJobNow extends StatefulWidget {


  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {

  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? picked;
  Timestamp?deadlineDateTimeStamp;

  final TextEditingController _jobcategorycontroller = TextEditingController(
      text: 'Select Job Category');
  final TextEditingController _jobTitlecontroller = TextEditingController();
  final TextEditingController _jobDescriptioncontroller = TextEditingController();
  final TextEditingController _jobDeadLineDatecontroller = TextEditingController(text: 'Job Deadline Date');

  @override
  void dispose(){
    super.dispose();
    _jobcategorycontroller.dispose();
    _jobTitlecontroller.dispose();
    _jobDescriptioncontroller.dispose();
    _jobDeadLineDatecontroller.dispose();
  }


  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),),
    );
  }

  Widget _textFormFields({
    required String valuekey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is Missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valuekey),
          style: const TextStyle(
            color: Colors.white,
          ),
          maxLines: valuekey == 'JobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.black54,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.black
                  )
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              )
          ),
        ),
      ),
    );
  }

  _showTaskCategoryDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text('Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Persistent.jobCategoryList.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _jobcategorycontroller.text = Persistent
                              .jobCategoryList[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_right_alt_outlined,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(Persistent.jobCategoryList[index],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: const Text('Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,

                  ),
                ),
              ),
            ],
          );
        });
  }
  void _pickDateDialog() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 0),
      ),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _jobDeadLineDatecontroller.text =
        '${picked!.year} - ${picked!.month} - ${picked!.day}';
        DateTime selectedDateTime = DateTime(picked!.year, picked!.month, picked!.day);
        deadlineDateTimeStamp = Timestamp.fromDate(selectedDateTime);
      });
    }
  }

  void _uploadTask() async {
    final jobId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formkey.currentState!.validate();
    if (isValid) {
      if (_jobDeadLineDatecontroller.text == 'Choose job Dead Line date' ||
          _jobcategorycontroller.text == 'Choose job Category') {
        GlobalMethod.showErrorDialog(
          error: 'Please Pick Everything',
          ctx: context,
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId': jobId,
          'uploadedBy': _uid,
          'email': user.email,
          'jobTitle': _jobTitlecontroller.text,
          'jobDescription': _jobDescriptioncontroller.text,
          'deadlineDate': _jobDeadLineDatecontroller.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'jobCategory': _jobcategorycontroller.text,
          'jobComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });
        await Fluttertoast.showToast(
          msg: 'The task has been uploaded',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );
        _jobTitlecontroller.clear();
        _jobDescriptioncontroller.clear();
        setState(() {
          _jobcategorycontroller.text = 'Choose job Category';
          _jobDeadLineDatecontroller.text = 'Choose job DeadLine Date';
        });
      } catch (error) {
         {
           setState(() {
             _isLoading=false;
           });
           GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
         }
      }
      finally{
        setState(() {
          _isLoading=false;
        });
      }
    }
    else{
      print('Its not Valid');
    }
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade300,Colors.green.shade300],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2,0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNaigationbarApp(indexNum:2),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Upload Job Now"),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.yellow.shade500,Colors.green.shade500],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.2,0.9],
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Please fill all fields',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      thickness: 1,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formkey,
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(
                                label:'Job Category:'),
                            _textFormFields(
                                valuekey: 'JobCategory',
                                controller:_jobcategorycontroller,
                                enabled: false,
                                fct:(){
                                  _showTaskCategoryDialog(size: size);
                                } ,
                                maxLength:100,
                            ),
                            _textTitles(label: 'Job Title:'),
                            _textFormFields(
                                valuekey: 'JobTitle',
                                controller:_jobTitlecontroller ,
                                enabled: true,
                                fct: (){},
                                maxLength:100,
                            ),
                            _textTitles(label: 'Job Description:'),
                            _textFormFields(
                              valuekey: 'JobDescription',
                              controller:_jobDescriptioncontroller ,
                              enabled: true,
                              fct: (){},
                              maxLength:100,
                            ),
                            _textTitles(label: 'Job Dead Line Date:'),
                            _textFormFields(
                              valuekey: 'deadlineDate',
                              controller:_jobDeadLineDatecontroller ,
                              enabled: false,
                              fct: (){
                                _pickDateDialog();
                              },
                              maxLength:100,
                            ),
                          ],
                        ) ),),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 30,
                        ),
                        child: _isLoading
                        ?const CircularProgressIndicator()
                        :MaterialButton(
                            onPressed: (){
                              _uploadTask();
                            },
                          color: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 14
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Post Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),),
                                SizedBox(width: 9,),
                                Icon(Icons.upload_file,
                                color: Colors.white,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
