import 'package:flutter/material.dart';
import 'app_text_field.dart';

class RegistrationSteps extends StatefulWidget {
  RegistrationSteps(this.userTextEditingController, this.passwordTextEditingController, this.userEmailEditingController, this.userIdEditingController);

  final TextEditingController userTextEditingController;
  final TextEditingController passwordTextEditingController;
  final TextEditingController userIdEditingController;
  final TextEditingController userEmailEditingController;

  @override
  _RegistrationStepsState createState() => _RegistrationStepsState();
}

class _RegistrationStepsState extends State<RegistrationSteps> {

  int currentStep = 0;

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
      onStepContinue: () {
        setState(() {
          currentStep < 1  ? currentStep++ : null;
          print(currentStep);
        });
      },
      onStepCancel: () {
        setState(() {
          currentStep > 0 ? currentStep-- : currentStep = 0;
          print(currentStep);
        });
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
              SizedBox(height: 10),
              AppTextField(
                controller: widget.userEmailEditingController,
                labelText: "Your Email",
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        Step(
          isActive: true,
          state: currentStep < 1 ? StepState.disabled : currentStep == 1 ? StepState.editing : StepState.complete,
          title: Text('User Details'),
          content: Column(
            children: [
              AppTextField(
                controller: widget.userTextEditingController,
                labelText: "Your Name",
              ),
              SizedBox(height: 10),
              AppTextField(
                controller: widget.passwordTextEditingController,
                labelText: "Password",
                isPassword: true,
              ),
            ],
          ),
        ),
      ],
    )
    ;
  }
}
