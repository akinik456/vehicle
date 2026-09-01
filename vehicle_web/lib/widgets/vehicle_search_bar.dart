import 'package:flutter/material.dart';

class VehicleSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const VehicleSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search vehicle...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        
      ),
    );
  }
}