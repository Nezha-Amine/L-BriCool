import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lbricool/models/gig_model.dart';
import 'package:lbricool/controllers/gig_controller.dart';
import 'package:lbricool/pages/client_interfaces/client_home_screen.dart';
import 'package:lbricool/pages/offers_form/widgets/address_selector.dart';
import 'package:lbricool/pages/offers_form/widgets/category_selector.dart';
import 'package:lbricool/pages/offers_form/widgets/children_details.dart';
import 'package:lbricool/pages/offers_form/widgets/date_time_selector.dart';
import 'package:lbricool/pages/offers_form/widgets/language_selector.dart';
import 'package:lbricool/pages/offers_form/widgets/price_selector.dart';
import 'package:lbricool/pages/offers_form/widgets/task_selector.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login.dart';
import '../student_form/success_dialogue.dart';
import '../student_interfaces/home_top_screen/top_screen_content.dart';
import '../student_interfaces/home_top_screen/notification_overlay.dart';

class BabysittingJobForm extends StatefulWidget {
  const BabysittingJobForm({Key? key}) : super(key: key);

  @override
  _BabysittingJobFormState createState() => _BabysittingJobFormState();
}

class _BabysittingJobFormState extends State<BabysittingJobForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  final GigController _gigController = GigController();
  final NotificationOverlay _notificationOverlay = NotificationOverlay();
  bool _isLoading = false;

  // Animation controller for fade effect
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Form values
  String _selectedCategory = 'Babysitting';
  String _description = '';
  String _address = '';
  double _hourlyRate = 100;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isDateRange = false;
  TimeOfDay _startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 0);
  List<Map<String, String>> _childrenDetails = [{'type': 'Toddler', 'age': '2 years old'}];
  List<String> _selectedLanguages = ['English'];
  List<String> _selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current user
        final currentUser = await _gigController.getCurrentUser();

        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not authenticated')),
          );
          return;
        }

        // Create a new gig object
        final newGig = GigModel(
          category: _selectedCategory,
          description: _description,
          address: _address,
          hourlyRate: _hourlyRate,
          startDate: _startDate,
          endDate: _isDateRange ? _endDate : null,
          isDateRange: _isDateRange,
          startTime: _gigController.timeOfDayToMap(_startTime),
          endTime: _gigController.timeOfDayToMap(_endTime),
          childrenDetails: _childrenDetails,
          languages: _selectedLanguages,
          tasks: _selectedTasks,
          clientId: currentUser.id,
          clientName: currentUser.fullName,
          createdAt: Timestamp.now(),
        );

        // Save the gig to Firestore
        final result = await _gigController.createGig(newGig);

        if (result) {
          // Show success dialog instead of SnackBar
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error posting job. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// Add this new method to show the success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: 'Job Posted Successfully',
          message: 'Your babysitting job has been posted successfully. Applicants will be able to see it now.',
          onOkPressed: () {
            // Close the dialog and navigate in one operation
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
            );
          },
        );
      },
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Profile':
      // Navigate to profile page
        break;
      case 'My Gigs':
      // Navigate to my gigs page
        break;
      case 'Add a Gig':
      // Already on this page
        break;
      case 'Log Out':
        _logout();
        break;
    }
  }

  void _logout() async {
    try {
      await _authController.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogInPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Home top screen with fade effect
          HomeTopScreenContent(
            fadeAnimation: _fadeAnimation,
            notificationOverlay: _notificationOverlay,
            name: "Post a Babysitting Gig",
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),

          ),

          // Form content
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategorySelector(
                            selectedCategory: _selectedCategory,
                            onCategoryChanged: _onCategoryChanged,
                          ),

                          const SizedBox(height: 20),

                          AddressSelector(
                            onAddressSelected: (address) {
                              setState(() {
                                _address = address;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Describe your $_selectedCategory needs...',
                              labelText: 'Description',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                            onSaved: (value) => _description = value!,
                          ),

                          const SizedBox(height: 20),

                          DateTimeSelector(
                            startDate: _startDate,
                            endDate: _endDate,
                            isDateRange: _isDateRange,
                            startTime: _startTime,
                            endTime: _endTime,
                            onStartDateChanged: (date) {
                              setState(() {
                                _startDate = date;
                                if (_endDate != null && _endDate!.isBefore(_startDate)) {
                                  _endDate = null;
                                }
                              });
                            },
                            onEndDateChanged: (date) => setState(() => _endDate = date),
                            onIsDateRangeChanged: (value) => setState(() {
                              _isDateRange = value;
                              if (!value) _endDate = null;
                            }),
                            onStartTimeChanged: (time) => setState(() => _startTime = time),
                            onEndTimeChanged: (time) => setState(() => _endTime = time),
                          ),

                          const SizedBox(height: 20),

                          if (_selectedCategory == 'Babysitting') ...[
                            ChildrenDetailsWidget(
                              childrenDetails: _childrenDetails,
                              onChildrenDetailsChanged: (details) => setState(() => _childrenDetails = details),
                            ),

                            const SizedBox(height: 20),

                            LanguageSelector(
                              selectedLanguages: _selectedLanguages,
                              onLanguagesChanged: (languages) => setState(() => _selectedLanguages = languages),
                            ),

                            const SizedBox(height: 20),

                            TaskSelector(
                              selectedTasks: _selectedTasks,
                              onTasksChanged: (tasks) => setState(() => _selectedTasks = tasks),
                            ),
                          ],

                          const SizedBox(height: 20),

                          PriceSelector(
                            initialPrice: _hourlyRate,
                            onPriceChanged: (price) => setState(() => _hourlyRate = price),
                          ),

                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4527A0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'POST JOB',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),

                // Overlay loading indicator
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}