import 'package:flutter/material.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // State information

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(flex: 2),
              Text(
                'App Name',
                style: TextStyle(
                  fontSize: 50
                ),
              ),
              Spacer(),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage()
                    )
                  )
                },
              ),
              Spacer(flex: 2),
              Text('Acknowledgements',
                style: TextStyle(
                  fontWeight: FontWeight.w100
                ),
              )
            ],
          ),
      ),
    );
  }
}