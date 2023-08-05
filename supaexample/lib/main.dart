import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SharedPreferences? preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://wtnuplfvjyxmsxljpypk.supabase.co",
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind0bnVwbGZ2anl4bXN4bGpweXBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzkzMzgyMjIsImV4cCI6MTk5NDkxNDIyMn0.ln31OQ1Rlw_VN_Eau5JaAyxtdTb9bSG9xr9taUe14rg',
  );
  SharedPreferences.getInstance().then((instance) {
    preferences = instance;

    if (preferences!.getString('token') != null) {
      runApp(ProfilePage(
        user: null,
      ));
    } else {
      runApp(LoginApp());
    }
  });
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Random random = Random();

  generateToken() {
    String token = random.nextInt(1000000).toString();
    token += "mohamad";
  }

  bool loading = false;

  final _client = Supabase.instance.client;

  _login(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      loading = true;
    });

    String token = preferences.getString('token') ?? "0";

    var response = await _client
        .rpc('get_transfer_data_by_tokensn', params: {'input_token': token});

    if (response != null) {
      print(response[0]['email']);

      User user = User();

      // get_transfer_data_by_tokensn
      user.name = response[0]['name'];
      user.email = response[0]['email'];
      user.token = response[0]['token'];

      preferences.setBool('login', true);
      preferences.setString('token', user.token!);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => ProfilePage(user: user)));
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: loading
                  ? SizedBox(
                      height: 10,
                      width: 10,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.background,
                        strokeWidth: 1.5,
                      ),
                    )
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  User? user;
  ProfilePage({required this.user});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Profile Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                    'data:image/jpeg;base64,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'),
              ),
              SizedBox(height: 20),
              Text(
                user?.name ?? 'Ahmad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Software Engineer',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              _buildProfileInfoCard(
                  'Email', '${user?.email ?? 'kmsllsjflkdsjfl@gmail.com'}'),
              _buildProfileInfoCard('Phone', '+1 (123) 456-7890'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(String label, String value) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class User {
  String? name;
  String? email;
  String? token;
}

/*

CREATE OR REPLACE FUNCTION get_transfer_data_by_tokensn(input_token text)
RETURNS SETOF transfers AS
$$
BEGIN
    IF EXISTS (SELECT 1 FROM users WHERE token = input_token) THEN
        RETURN QUERY
        SELECT t.*
        FROM transfers t;
    ELSE
        RETURN QUERY
        SELECT NULL::transfers; -- Return an empty result if the token doesn't exist
    END IF;
END;
$$
LANGUAGE plpgsql;


 */
