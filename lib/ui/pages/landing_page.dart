import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// Idea here is to have a page to show nothing important and ask for biometrics
// or logic on what to show first might reside

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[],
        ),
      ),
    );
  }
}
