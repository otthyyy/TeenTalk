import 'package:flutter/material.dart';
import '../../../../core/constants/brescia_schools.dart';

class PersonalInfoStep extends StatefulWidget {

  const PersonalInfoStep({
    super.key,
    required this.initialGender,
    required this.initialSchool,
    required this.onGenderChanged,
    required this.onSchoolChanged,
    required this.onNext,
    required this.onBack,
  });
  final String? initialGender;
  final String? initialSchool;
  final Function(String?) onGenderChanged;
  final Function(String?) onSchoolChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  String? _selectedGender;
  String? _selectedSchool;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
    _selectedSchool = widget.initialSchool;
  }

  void _handleNext() {
    widget.onGenderChanged(_selectedGender);
    widget.onSchoolChanged(_selectedSchool);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Tell Us About Yourself',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Optional information to personalize your experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'non_binary', child: Text('Non-binary')),
              DropdownMenuItem(
                  value: 'prefer_not_to_say',
                  child: Text('Prefer not to say')),
            ],
            onChanged: (value) {
              setState(() => _selectedGender = value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedSchool,
            decoration: const InputDecoration(
              labelText: 'School (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school),
            ),
            items: BresciaSchools.schools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(school),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedSchool = value);
            },
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This information is optional and helps us provide better content',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
