import 'package:flutter/material.dart';

class Nofound extends StatelessWidget {
  const Nofound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('m Page'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/profile'); // الانتقال إلى صفحة البروفايل
          },
          child: Text('Go to Profile'),
        ),
      ),
    );
  }
}
