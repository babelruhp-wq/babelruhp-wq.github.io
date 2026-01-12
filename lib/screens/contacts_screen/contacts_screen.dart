import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/constants.dart';
import '../../features/contacts/contacts_cubit.dart';
import '../../services/contacts_service.dart';
import 'contacts_screen_widgets/contacts_screen_appbar.dart';
import 'contacts_screen_widgets/contacts_table.dart';


class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactsCubit(
        service: WhatsappService(baseUrl: mainUrl), // ✅ API الافتراضي
      )..load(),
      child: Scaffold(
        backgroundColor: const Color(0xfff2f4f7),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: const [
              ContactsScreenAppbar(),
              SizedBox(height: 16),
              Expanded(child: ContactsTable()),
            ],
          ),
        ),
      ),
    );
  }
}
