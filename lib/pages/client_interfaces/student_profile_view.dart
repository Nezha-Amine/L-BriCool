// student_profile_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lbricool/pages/client_interfaces/review_card_widget.dart';
import '../../models/user_model.dart';


class StudentProfileView extends StatefulWidget {
  final String studentId;

  const StudentProfileView({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  late Future<UserModel?> _studentFuture;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  void _loadStudentData() {
    _studentFuture = _firestore
        .collection('users')
        .doc(widget.studentId)
        .get()
        .then((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: FutureBuilder<UserModel?>(
        future: _studentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF40189D)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final student = snapshot.data;
          if (student == null) {
            return const Center(
              child: Text('Student not found'),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF40189D),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: const Color(0xFF40189D),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: student.profilePicture != null
                                ? NetworkImage(student.profilePicture!)
                                : null,
                            child: student.profilePicture == null
                                ? const Icon(Icons.person, size: 50, color: Color(0xFF40189D))
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            student.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Details Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Student Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),

                              // University info
                              _buildInfoRow(
                                'University:',
                                student.universityName ?? 'Not specified',
                              ),
                              _buildInfoRow(
                                'Field of Study:',
                                student.fieldOfStudy ?? 'Not specified',
                              ),
                              _buildInfoRow(
                                'Year:',
                                student.yearOfStudy != null
                                    ? 'Year ${student.yearOfStudy}'
                                    : 'Not specified',
                              ),

                              // Bio section
                              if (student.bio != null && student.bio!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(student.bio!),
                              ],

                              // Skills section
                              if (student.skills != null && student.skills!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Skills',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: student.skills!.map((skill) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        skill,
                                        style: const TextStyle(
                                          color: Color(0xFF40189D),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Reviews Section
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dummy reviews
                      const ReviewCard(
                        name: 'Sarah Johnson',
                        date: 'Feb 15, 2025',
                        rating: 5,
                        comment: 'Michael was excellent with my kids. Very patient and engaged them with creative activities. Highly recommend!',
                      ),
                      const SizedBox(height: 12),
                      const ReviewCard(
                        name: 'David Wilson',
                        date: 'Jan 28, 2025',
                        rating: 4,
                        comment: 'Professional and punctual. Good communication skills and my daughter enjoyed the tutoring session.',
                      ),
                      const SizedBox(height: 12),
                      const ReviewCard(
                        name: 'Emma Taylor',
                        date: 'Dec 10, 2024',
                        rating: 5,
                        comment: 'Fantastic pet sitter! My dog was well taken care of and she sent regular updates with photos.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF40189D),
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}