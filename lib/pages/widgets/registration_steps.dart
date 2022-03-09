import 'package:flutter/material.dart';
import 'app_text_field.dart';
import '../db/sqldb.dart';

class RegistrationSteps extends StatefulWidget {
  RegistrationSteps(
      this.userTextEditingController,
      this.passwordTextEditingController,
      this.userEmailEditingController,
      this.userIdEditingController);

  final TextEditingController userTextEditingController;
  final TextEditingController passwordTextEditingController;
  final TextEditingController userEmailEditingController;
  final TextEditingController userIdEditingController;

  @override
  _RegistrationStepsState createState() => _RegistrationStepsState();
}

class _RegistrationStepsState extends State<RegistrationSteps> {
  int currentStep = 0;
  var status;
  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();

  continueButton() async {
    if (currentStep == 0) {
      currentStep++;
      status = await _sqlDatabaseService
          .checkEmpID(widget.userIdEditingController.text);
      // print(status);
    }
    setState(() {});

    print(currentStep);
  }

  cancelButton() async {
    if (currentStep == 1) {
      currentStep--;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: ClampingScrollPhysics(),
      type: StepperType.vertical,
      currentStep: currentStep,
      onStepTapped: (step) {
        setState(() {
          currentStep = step;
          print(step);
        });
      },
      onStepContinue: continueButton,
      onStepCancel: cancelButton,
      controlsBuilder: (BuildContext context, ControlsDetails controls) {
        return Container(
          height: 70,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              currentStep == 0
                  ? Text("")
                  : ElevatedButton(
                      onPressed: controls.onStepCancel,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey.shade500,
                        onPrimary: Colors.white,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.chevron_left),
                          Text("PREV")
                        ],
                      ),
                    ),
              currentStep == 1
                  ? Text("")
                  : ElevatedButton(
                      onPressed: controls.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigoAccent,
                        onPrimary: Colors.white,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.chevron_right),
                          Text("NEXT")
                        ],
                      ),
                    )
            ],
          ),
        );
      },
      steps: <Step>[
        Step(
          isActive: currentStep >= 0,
          // isActive: true,
          state: currentStep == 0 ? StepState.editing : StepState.complete,
          title: Text('User ID'),
          content: Column(
            children: [
              AppTextField(
                controller: widget.userIdEditingController,
                labelText: "Employee ID",
              ),
            ],
          ),
        ),
        Step(
          isActive: true,
          state: currentStep < 1
              ? StepState.disabled
              : currentStep == 1
                  ? StepState.editing
                  : StepState.complete,
          title: Text('User Details'),
          content: Column(
            children: [
              status == null
                  // if doest exist in db, new user
                  // else, returning user.
                  ? Column(
                      children: [
                        AppTextField(
                          controller: widget.userTextEditingController,
                          labelText: "Your Name",
                        ),
                        SizedBox(height: 10),
                        AppTextField(
                          controller: widget.userEmailEditingController,
                          labelText: "Your Email",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 10),
                      ],
                    )
                  : Column(
                      children: [
                        Text('Welcome back ' + status + '!'),
                        SizedBox(height: 10),
                      ],
                    ),
              AppTextField(
                controller: widget.passwordTextEditingController,
                labelText: "Password",
                isPassword: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
