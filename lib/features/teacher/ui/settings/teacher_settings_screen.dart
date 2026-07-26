import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.settings),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            ListTile(
              leading: const Icon(Icons.person_outlined),
              title: const Text('الملف الشخصي'),
              trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة'),
              trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('الإشعارات'),
              trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[400]),
              title: Text(
                AppStrings.logout,
                style: TextStyle(color: Colors.red[400]),
              ),
              onTap: () {
                context.read<AuthCubit>().signOut();
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
