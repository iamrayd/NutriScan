import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AllergenWidget extends StatefulWidget {
  final Function(List<String>) onAllergensSelected;

  const AllergenWidget({super.key, required this.onAllergensSelected});

  @override
  State<AllergenWidget> createState() => _AllergenWidgetState();
}

class _AllergenWidgetState extends State<AllergenWidget> {
  final List<String> commonAllergens = [
    'peanuts',
    'milk',
    'eggs',
    'soy',
    'wheat',
    'fish',
    'shellfish',
    'tree nuts',
  ];
  final List<String> selectedAllergens = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Your Allergens"),
      content: SingleChildScrollView(
        child: Column(
          children: commonAllergens.map((allergen) {
            return CheckboxListTile(
              title: Text(allergen),
              value: selectedAllergens.contains(allergen),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedAllergens.add(allergen);
                  } else {
                    selectedAllergens.remove(allergen);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onAllergensSelected(selectedAllergens);
            Navigator.pop(context);
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}