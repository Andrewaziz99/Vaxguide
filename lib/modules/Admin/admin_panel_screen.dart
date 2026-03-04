import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';
import 'package:vaxguide/modules/Admin/manage_alerts_tab.dart';
import 'package:vaxguide/modules/Admin/manage_articles_tab.dart';
import 'package:vaxguide/modules/Admin/manage_users_tab.dart';
import 'package:vaxguide/modules/Admin/manage_vaccines_tab.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminCubit(),
      child: BlocListener<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is AdminSuccessState && state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: fischerBlue700,
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          } else if (state is AdminErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: red700,
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          }
        },
        child: DefaultTabController(
          length: 4,
          child: ThemedScaffold(
            backgroundImagePath: 'assets/images/bg2.png',
            appBar: AppBar(
              title: const Text(
                'لوحة التحكم',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: fischerBlue100,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 13,
                ),
                tabAlignment: TabAlignment.center,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.vaccines_rounded, size: 20),
                    text: 'التطعيمات',
                  ),
                  Tab(
                    icon: Icon(Icons.article_rounded, size: 20),
                    text: 'المقالات',
                  ),
                  Tab(
                    icon: Icon(Icons.campaign_rounded, size: 20),
                    text: 'التنبيهات',
                  ),
                  Tab(
                    icon: Icon(Icons.people_rounded, size: 20),
                    text: 'المستخدمين',
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                ManageVaccinesTab(),
                ManageArticlesTab(),
                ManageAlertsTab(),
                ManageUsersTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
