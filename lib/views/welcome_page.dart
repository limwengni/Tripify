import 'package:flutter/material.dart';
import 'package:tripify/components/components.dart';
import 'package:tripify/views/login_page.dart';
import 'package:tripify/views/register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  static String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Center( // Center the entire Column
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the contents vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                // Styled ScreenTitle
                const Text(
                  'Welcome to Tripify!',
                  textAlign: TextAlign.center, // Center the text
                  style: TextStyle(
                    fontSize: 24, // Increased font size
                    fontWeight: FontWeight.bold, // Bold font weight
                    color: Colors.black, // Change color as needed
                  ),
                ),
                const SizedBox(height: 10), // Reduced height
                const Text(
                  'Your journey begins here. Plan your trips effortlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10), // Reduced height
                Hero(
                  tag: 'login_btn',
                  child: CustomButton(
                    buttonText: 'Login',
                    onPressed: () {
                      Navigator.pushNamed(context, LoginPage.id);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Hero(
                  tag: 'signup_btn',
                  child: CustomButton(
                    buttonText: 'Sign Up',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pushNamed(context, RegistrationPage.id);
                    },
                  ),
                ),
                const SizedBox(height: 15), // Adjusted spacing
                // Commenting out the sign up using section
                /*
                const Text(
                  'Sign up using',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: CircleAvatar(
                        radius: 25,
                        child: Image.asset('assets/images/icons/facebook.png'),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        child: Image.asset('assets/images/icons/google.png'),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: CircleAvatar(
                        radius: 25,
                        child: Image.asset('assets/images/icons/linkedin.png'),
                      ),
                    ),
                  ],
                )
                */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
