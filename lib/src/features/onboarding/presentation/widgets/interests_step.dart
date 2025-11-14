import 'package:flutter/material.dart';
import '../../../../core/constants/user_interests.dart';

class InterestsStep extends StatefulWidget {

  const InterestsStep({
    super.key,
    required this.initialSchoolYear,
    required this.initialInterests,
    required this.initialClubs,
    required this.onSchoolYearChanged,
    required this.onInterestsChanged,
    required this.onClubsChanged,
    required this.onNext,
    required this.onBack,
  });
  final String? initialSchoolYear;
  final List<String> initialInterests;
  final List<String> initialClubs;
  final Function(String?) onSchoolYearChanged;
  final Function(List<String>) onInterestsChanged;
  final Function(List<String>) onClubsChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<InterestsStep> {
  String? _selectedSchoolYear;
  final Set<String> _selectedInterests = {};
  final Set<String> _selectedClubs = {};
  final _customInterestController = TextEditingController();
  final _customClubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSchoolYear = widget.initialSchoolYear;
    _selectedInterests.addAll(widget.initialInterests);
    _selectedClubs.addAll(widget.initialClubs);
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    _customClubController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_selectedSchoolYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your school year'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSchoolYearChanged(_selectedSchoolYear);
    widget.onInterestsChanged(_selectedInterests.toList());
    widget.onClubsChanged(_selectedClubs.toList());
    widget.onNext();
  }

  void _addCustomInterest() {
    final custom = _customInterestController.text.trim();
    if (custom.isNotEmpty && !_selectedInterests.contains(custom)) {
      setState(() {
        _selectedInterests.add(custom);
        _customInterestController.clear();
      });
    }
  }

  void _addCustomClub() {
    final custom = _customClubController.text.trim();
    if (custom.isNotEmpty && !_selectedClubs.contains(custom)) {
      setState(() {
        _selectedClubs.add(custom);
        _customClubController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.interests_outlined,
            size: 64,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          Text(
            'Your Interests',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Help us connect you with similar people',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSchoolYear,
                    decoration: const InputDecoration(
                      labelText: 'School Year *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: UserInterests.schoolYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSchoolYear = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Your Interests *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UserInterests.interests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customInterestController,
                          decoration: const InputDecoration(
                            labelText: 'Add custom interest',
                            border: OutlineInputBorder(),
                            hintText: 'Type and press +',
                          ),
                          onSubmitted: (_) => _addCustomInterest(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addCustomInterest,
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Clubs (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UserInterests.clubs.map((club) {
                      final isSelected = _selectedClubs.contains(club);
                      return FilterChip(
                        label: Text(club),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedClubs.add(club);
                            } else {
                              _selectedClubs.remove(club);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customClubController,
                          decoration: const InputDecoration(
                            labelText: 'Add custom club',
                            border: OutlineInputBorder(),
                            hintText: 'Type and press +',
                          ),
                          onSubmitted: (_) => _addCustomClub(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addCustomClub,
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
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
