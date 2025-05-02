import 'package:flutter/material.dart';

import 'doctor_list_screen.dart'; // Import the doctor list screen

class SpecializationScreen extends StatelessWidget {
  final List<MedicalSpecialty> specialties = [
    MedicalSpecialty('Anesthesiology', Icons.medication),
    MedicalSpecialty('Cardiology', Icons.favorite),
    MedicalSpecialty('Cardiothoracic Surgery', Icons.monitor_heart),
    MedicalSpecialty('Dermatology', Icons.spa),
    MedicalSpecialty('Endocrinology', Icons.water_drop),
    MedicalSpecialty('ENT', Icons.hearing),
    MedicalSpecialty('Gastroenterology', Icons.emoji_food_beverage),
    MedicalSpecialty('General Medicine', Icons.medical_services),
    MedicalSpecialty('General Surgery', Icons.cut),
    MedicalSpecialty('Gynecology', Icons.female),
    MedicalSpecialty('Hematology', Icons.bloodtype),
    MedicalSpecialty('Infectious Disease', Icons.coronavirus_outlined),
    MedicalSpecialty('Medical Oncology', Icons.medical_information),
    MedicalSpecialty('Nephrology', Icons.filter_alt),
    MedicalSpecialty('Neurology', Icons.psychology_alt),
    MedicalSpecialty('Neurosurgery', Icons.psychology_sharp),
    MedicalSpecialty('Ophthalmology', Icons.remove_red_eye),
    MedicalSpecialty('Oral and Maxillofacial Surgery', Icons.face),
    MedicalSpecialty('Orthopedics', Icons.join_right_sharp),
    MedicalSpecialty('Pediatric Surgery', Icons.child_friendly),
    MedicalSpecialty('Pediatrics', Icons.child_care),
    MedicalSpecialty('Physician', Icons.person),
    MedicalSpecialty('Physiotherapist', Icons.directions_walk),
    MedicalSpecialty('Plastic Surgery', Icons.face_retouching_natural),
    MedicalSpecialty('Psychiatry', Icons.psychology),
    MedicalSpecialty('Pulmonology', Icons.air),
    MedicalSpecialty('Rheumatology', Icons.accessibility),
    MedicalSpecialty('Surgical Gastroenterology', Icons.content_cut),
    MedicalSpecialty('Surgical Oncology', Icons.science),
    MedicalSpecialty('Urology', Icons.invert_colors),
    MedicalSpecialty('Vascular Surgery', Icons.bloodtype),
  ];

  SpecializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort the specialties alphabetically by name
    specialties.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Medical Specialties',
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: IconThemeData(color: Colors.black87), // Back button color
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          return _buildSpecialtyCard(context, specialties[index]);
        },
      ),
    );
  }

  Widget _buildSpecialtyCard(BuildContext context, MedicalSpecialty specialty) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DoctorListScreen(
                        specialty: specialty.name,
                      ), // Pass specialty name to DoctorListScreen
                ),
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                specialty.icon,
                size: 40,
                color: Colors.white,
              ), // Specialty icon
              const SizedBox(height: 8),
              Text(
                specialty.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ), // Specialty name
            ],
          ),
        ),
      ),
    );
  }
}

class MedicalSpecialty {
  final String name;
  final IconData icon;

  MedicalSpecialty(this.name, this.icon);
}
