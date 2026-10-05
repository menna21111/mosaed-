import 'package:flutter/material.dart';

import 'addresses_list_screen.dart';

/// Post-auth address setup: opens the addresses page and shows
/// the "حدد موقعك" sheet over it (not a solid black screen).
class AddressOnboardingScreen extends StatelessWidget {
  const AddressOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddressesListScreen(
      onboarding: true,
      showLocationPromptOnOpen: true,
    );
  }
}
