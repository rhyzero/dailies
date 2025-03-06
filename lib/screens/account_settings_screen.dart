import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill email field with current user's email
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _emailController.text = authProvider.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Update email
  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateEmail(
        _emailController.text.trim(),
        _currentPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Email updated successfully')));
        _currentPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update email.';

        if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Please log in again before changing your email.';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'The email address is not valid.';
        } else if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Update password
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).updatePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to update password.';

        if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Please log in again before changing your password.';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'The password is too weak.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect current password.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Delete account
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                ),
                SizedBox(height: 16),
                Text(
                  'All your data will be permanently deleted.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Enter your password to confirm',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _currentPasswordController.clear();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteAccount();
                },
                child: Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).deleteAccount(_currentPasswordController.text);

      if (mounted) {
        // Account deleted, navigate to login screen and clear navigation history
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false, // This removes all previous routes
        );

        // Show confirmation message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Account deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to delete account.';

        if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Please log in again before deleting your account.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _currentPasswordController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAnonymous = authProvider.currentUser?.isAnonymous ?? false;

    if (isAnonymous) {
      return Scaffold(
        appBar: AppBar(title: Text('Account Settings')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 80, color: Colors.grey),
                SizedBox(height: 24),
                Text(
                  'Guest Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'You\'re currently using a guest account. Create a permanent account to access all features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/convert_account');
                  },
                  child: Text('Create Account'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Account info card
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.currentUser?.displayName ??
                                          'User',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.currentUser?.email ?? '',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Update email section
                      Text(
                        'Update Email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'New Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureCurrentPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateEmail,
                        child: Text('Update Email'),
                      ),

                      SizedBox(height: 32),

                      // Update password section
                      Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureCurrentPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureNewPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updatePassword,
                        child: Text('Update Password'),
                      ),

                      SizedBox(height: 40),

                      // Delete account section
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showDeleteAccountDialog,
                        icon: Icon(Icons.delete_forever),
                        label: Text('Delete Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
