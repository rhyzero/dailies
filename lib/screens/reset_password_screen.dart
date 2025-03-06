import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to send reset email.';

        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No user found with this email.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'The email address is not valid.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _emailSent ? _buildSuccessMessage() : _buildResetForm(),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            child:
                _isLoading
                    ? CircularProgressIndicator()
                    : Text('Send Reset Link'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read, size: 80, color: Colors.green),
        SizedBox(height: 24),
        Text(
          'Password Reset Email Sent',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          'We\'ve sent an email to ${_emailController.text}. Click the link in the email to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Return to Login'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ],
    );
  }
}
