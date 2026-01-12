import 'package:babel_final_project/localization/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/lang/app_language.dart';
import '../../features/users/users_cubit.dart';
import '../../features/users/users_state.dart';
import '../../models/app_users.dart';
import '../../services/users_service.dart';
import 'users_screen_widgets/add_user_dialog.dart';

class UsersScreen extends StatelessWidget {
  final String baseUrl;

  const UsersScreen({super.key, required this.baseUrl});

  List<_TabDef> _tabsForRole(String role) {
    final isAdmin = role == 'Admin';
    final isManager = role == 'Manager';

    if (!isAdmin && !isManager) return const [];

    return [
      if (isAdmin)
        const _TabDef(
          role: 'Manager',
          titleAr: 'المديرين',
          titleEn: 'Managers',
        ),
      const _TabDef(
        role: 'ReceptionEmployee',
        titleAr: 'موظفين التعاقد',
        titleEn: 'Reception Employees',
      ),
      const _TabDef(
        role: 'AccommodationEmployee',
        titleAr: 'موظفين الإيواء',
        titleEn: 'Accommodation Employees',
      ),
    ];
  }

  bool _canAddForRole({required String viewerRole, required String tableRole}) {
    if (viewerRole == 'Admin') return true;
    if (viewerRole == 'Manager') {
      return tableRole == 'ReceptionEmployee' ||
          tableRole == 'AccommodationEmployee';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<AppLanguage>();

    final viewerRole = (auth.session?.role ?? '').trim();
    final tabs = _tabsForRole(viewerRole);

    if (tabs.isEmpty) {
      return _ForbiddenUsersScreen(isArabic: lang.isArabic);
    }

    return BlocProvider(
      create: (ctx) => UsersCubit(
        service: UsersService(baseUrl: baseUrl),
        auth: ctx.read<AuthProvider>(),
      )..load(),
      child: BlocConsumer<UsersCubit, UsersState>(
        listener: (context, state) {
          final msg = state.error;
          if (msg != null && msg.trim().isNotEmpty) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          }
        },
        builder: (context, state) {
          final cubit = context.read<UsersCubit>();

          return DefaultTabController(
            length: tabs.length,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xfff5f6fa),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lang.isArabic ? 'المستخدمين' : 'Users',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xff2c334a),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: lang.isArabic ? 'تحديث' : 'Refresh',
                        onPressed: state.isLoading ? null : () => cubit.load(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tabs
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: TabBar(
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        labelStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.w900,
                        ),
                        unselectedLabelStyle: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: [
                          for (final t in tabs)
                            Tab(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  lang.isArabic ? t.titleAr : t.titleEn,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            children: [
                              for (final t in tabs)
                                _UsersRolePanel(
                                  title: lang.isArabic ? t.titleAr : t.titleEn,
                                  tableRole: t.role,
                                  viewerRole: viewerRole,
                                  isArabic: lang.isArabic,
                                  isBusy: state.isBusy,
                                  users: state.users
                                      .where(
                                        (u) =>
                                            u.role.trim().toLowerCase() ==
                                            t.role.trim().toLowerCase(),
                                      )
                                      .toList(),
                                  canAdd: _canAddForRole(
                                    viewerRole: viewerRole,
                                    tableRole: t.role,
                                  ),
                                  onAdd: () async {
                                    final data = await showDialog<RegisterData>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => AddUserDialog(
                                        title: lang.isArabic
                                            ? 'إضافة مستخدم - ${t.titleAr}'
                                            : 'Add User - ${t.titleEn}',
                                        isArabic: lang.isArabic,
                                      ),
                                    );

                                    if (data == null) return;

                                    await cubit.addUser(
                                      role: t.role,
                                      firstName: data.firstName,
                                      lastName: data.lastName,
                                      userName: data.userName,
                                      password: data.password,
                                      passwordConfirm: data.passwordConfirm,
                                    );

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(
                                      context,
                                    ).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          lang.isArabic
                                              ? 'تمت الإضافة بنجاح'
                                              : 'Added successfully',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabDef {
  final String role;
  final String titleAr;
  final String titleEn;

  const _TabDef({
    required this.role,
    required this.titleAr,
    required this.titleEn,
  });
}

class _UsersRolePanel extends StatelessWidget {
  final String title;
  final String tableRole;
  final String viewerRole;
  final bool isArabic;

  final bool isBusy;
  final bool canAdd;
  final VoidCallback onAdd;

  final List<AppUser> users;

  const _UsersRolePanel({
    required this.title,
    required this.tableRole,
    required this.viewerRole,
    required this.isArabic,
    required this.isBusy,
    required this.canAdd,
    required this.onAdd,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff2c334a),
                  ),
                ),
              ),
              if (canAdd)
                ElevatedButton.icon(
                  onPressed: isBusy ? null : onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(
                    isArabic ? 'إضافة' : 'Add',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff394263),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Table
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: users.isEmpty
                ? Center(
                    child: Text(
                      isArabic ? 'لا يوجد مستخدمين' : 'No users',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 44,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 56,
                            columnSpacing: 0,
                            // ✅ مهم عشان grid يبقى متصل
                            horizontalMargin: 0,
                            // ✅ مهم
                            dividerThickness: 0,
                            // ✅ هنرسم الـ grid بنفسنا
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xffF6F8FC),
                            ),
                            headingTextStyle: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xff2c334a),
                              fontSize: 13.5,
                            ),
                            dataTextStyle: GoogleFonts.cairo(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xff2c334a),
                              fontSize: 13,
                            ),

                            // ✅ إطار خارجي للجدول (زي الإكسيل)
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                                width: 0.9,
                              ),
                            ),

                            columns: [
                              DataColumn(
                                label: _headCell(
                                  text: isArabic ? '#' : '#',
                                  width: 50,
                                ),
                              ),
                              DataColumn(
                                label: _headCell(
                                  text: isArabic ? 'الاسم' : 'Name',
                                  width: 240,
                                ),
                              ),
                              DataColumn(
                                label: _headCell(
                                  text: isArabic ? 'اسم المستخدم' : 'Username',
                                  width: 260,
                                ),
                              ),
                              DataColumn(
                                label: _headCell(
                                  text: isArabic ? 'الدور' : 'Role',
                                  width: 220,
                                ),
                              ),
                              DataColumn(
                                label: _headCell(
                                  text: isArabic ? 'الحالة' : 'Status',
                                  width: 220,
                                ),
                              ),
                              DataColumn(
                                label: _headCell(
                                  text: isArabic ? 'الإجراءات' : 'Actions',
                                  width: 400,
                                ),
                              ),
                            ],

                            rows: List.generate(users.length, (i) {
                              final auth = context.watch<AuthProvider>();
                              final role = auth.role; // role أو fallback "Admin"
                              final isAdmin = role == 'Admin';
                              final u = users[i];
                              String status = '';
                              String activateText = '';
                              if (u.isActive) {
                                status = tr(context, "active");
                                activateText = tr(context, "Deactivation");
                              } else {
                                status = tr(context, "inactive");
                                activateText = tr(context, "activation");
                              }
                              // ✅ تظليل خفيف زي جداولك القديمة
                              final rowBg = (i % 2 == 0)
                                  ? Colors.white
                                  : const Color(0xffFAFBFE);

                              return DataRow(
                                color:
                                    MaterialStateProperty.resolveWith<Color?>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.hovered,
                                      )) {
                                        return Colors.black.withOpacity(0.03);
                                      }
                                      return rowBg;
                                    }),
                                cells: [
                                  DataCell(
                                    _gridCell(
                                      width: 240,
                                      child: Text(
                                        "${i + 1}",
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _gridCell(
                                      width: 240,
                                      child: Text(
                                        u.fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _gridCell(
                                      width: 260,
                                      child: Text(
                                        u.userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _gridCell(
                                      width: 220,
                                      child: _RoleChip(
                                        role: u.role,
                                        isArabic: isArabic,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _gridCell(
                                      width: 220,
                                      child: _RoleChip(
                                        role: status,
                                        isArabic: isArabic,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    _gridCell(
                                      width: 400,
                                      child: UserTableActions(
                                        changePasswordText: isArabic
                                            ? 'تغيير كلمة السر'
                                            : 'Change Password',
                                        activateText: activateText,
                                        onChangePassword: () async {
                                          final usersCubit = context.read<UsersCubit>(); // قبل أي await
                                          final data = await _askNewPassword(context, isArabic);
                                          if (data == null) return;
                                          if (!context.mounted) return;

                                          await usersCubit.resetPassword(
                                            userId: u.id,
                                            newPassword: data.password,
                                            newPasswordConfirm: data.confirm,
                                          );


                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isArabic ? 'تم تحديث كلمة المرور' : 'Password updated'),
                                            ),
                                          );
                                        },

                                        onActivateUser: () async {
                                          final usersCubit = context.read<UsersCubit>(); // ✅ قبل أي await
                                          final willActivate = !u.isActive;

                                          final ok = await _confirmToggleActive(
                                            context,
                                            isArabic: isArabic,
                                            willActivate: willActivate,
                                            userName: u.fullName,
                                          );

                                          if (!ok) return;
                                          if (!context.mounted) return; // ✅ مهم بعد await

                                          await usersCubit.toggleActive(u);

                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                willActivate
                                                    ? (isArabic ? 'تم تنشيط المستخدم' : 'User activated')
                                                    : (isArabic ? 'تم إلغاء تنشيط المستخدم' : 'User deactivated'),
                                              ),
                                            ),
                                          );
                                        }, isAdmin: isAdmin,


                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

Widget _headCell({required String text, required double width}) {
  return Container(
    width: width,
    height: double.infinity,
    alignment: Alignment.center,
    // ✅ العناوين في النص
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(color: Colors.black12, width: 0.9),
        bottom: BorderSide(color: Colors.black12, width: 0.9),
      ),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _gridCell({required double width, required Widget child}) {
  return Container(
    width: width,
    height: double.infinity,
    alignment: Alignment.center,
    // ✅ كل المحتوى في النص
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(color: Colors.black12, width: 0.9),
        bottom: BorderSide(color: Colors.black12, width: 0.9),
      ),
    ),
    child: Center(child: child),
  );
}

/// ===== Actions Pills (inline) =====
class UserTableActions extends StatelessWidget {
  final VoidCallback onChangePassword;
  final VoidCallback onActivateUser;
  final String changePasswordText;
  final String activateText;
  final bool isAdmin;

  const UserTableActions({
    super.key,
    required this.onChangePassword,
    required this.onActivateUser,
    required this.changePasswordText,
    required this.activateText, required this.isAdmin,
  });

  Widget _pill({
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fg.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _pill(
          icon: Icons.password_sharp,
          label: changePasswordText,
          fg: const Color(0xFF7A5AF8),
          bg: const Color(0xFFF2EEFF),
          onTap: onChangePassword,
        ),
        if(isAdmin)
        _pill(
          icon: Icons.airplanemode_inactive,
          label: activateText,
          fg: const Color(0xFFE11D48),
          bg: const Color(0xFFFFE7ED),
          onTap: onActivateUser,
        ),
      ],
    );
  }
}

/// ===== Role Chip =====
class _RoleChip extends StatelessWidget {
  final String role;
  final bool isArabic;

  const _RoleChip({required this.role, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    Color fg;
    Color bg;

    switch (role.trim()) {
      case 'Admin':
        fg = const Color(0xFF175CD3);
        bg = const Color(0xFFE8F1FF);
        break;
      case 'Manager':
        fg = const Color(0xFF7A5AF8);
        bg = const Color(0xFFF2EEFF);
        break;
      case 'ReceptionEmployee':
        fg = const Color(0xFF0E9384);
        bg = const Color(0xFFE6FFFB);
        break;
      case 'AccommodationEmployee':
        fg = const Color(0xFFB54708);
        bg = const Color(0xFFFFF4E5);
        break;
      default:
        fg = const Color(0xFF667085);
        bg = const Color(0xFFF2F4F7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Text(
        role.isEmpty ? (isArabic ? 'غير معروف' : 'Unknown') : role,
        style: GoogleFonts.cairo(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}
class ResetPasswordData {
  final String password;
  final String confirm;
  const ResetPasswordData(this.password, this.confirm);
}

Future<ResetPasswordData?> _askNewPassword(BuildContext context, bool isArabic) async {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final passFocus = FocusNode();
  final confirmFocus = FocusNode();

  bool obscurePass = true;
  bool obscureConfirm = true;

  String? errorText;

  bool hasLower = false;
  bool hasUpper = false;
  bool hasDigit = false;
  bool hasSpecial = false;
  bool hasMinLen = false;

  void eval(String v) {
    final s = v;
    hasLower = RegExp(r'[a-z]').hasMatch(s);
    hasUpper = RegExp(r'[A-Z]').hasMatch(s);
    hasDigit = RegExp(r'\d').hasMatch(s);
    hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(s);
    hasMinLen = s.length >= 8;
    }

  // init
  eval('');

  final res = await showDialog<ResetPasswordData?>(
    context: context,
    barrierDismissible: false,
    builder: (dCtx) => StatefulBuilder(
      builder: (dCtx, setState) {
        final title = isArabic ? 'إعادة تعيين كلمة المرور' : 'Reset Password';
        final hintPass = isArabic ? 'اكتب كلمة مرور جديدة' : 'Enter a new password';
        final hintConfirm = isArabic ? 'تأكيد كلمة المرور' : 'Confirm password';

        final helper = isArabic
            ? 'الشروط: 8 أحرف على الأقل + حرف كبير + حرف صغير + رقم + رمز خاص.'
            : 'Rules: min 8 chars + uppercase + lowercase + number + special symbol.';

        String? validateAll() {
          final p = passCtrl.text.trim();
          final c = confirmCtrl.text.trim();

          eval(p);

          if (p.isEmpty || c.isEmpty) {
            return isArabic ? 'من فضلك املأ كلمة المرور والتأكيد' : 'Please fill password and confirm';
          }

          if (!hasMinLen || !hasLower || !hasUpper || !hasDigit || !hasSpecial) {
            return isArabic ? 'كلمة المرور لا تطابق الشروط' : 'Password does not meet the rules';
          }

          if (p != c) {
            return isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';
          }

          return null;
        }

        void submit() {
          final msg = validateAll();
          if (msg != null) {
            setState(() => errorText = msg);
            return;
          }
          Navigator.pop(
            dCtx,
            ResetPasswordData(passCtrl.text.trim(), confirmCtrl.text.trim()),
          );
        }

        Widget ruleRow(bool ok, String ar, String en) {
          final fg = ok ? const Color(0xFF16A34A) : const Color(0xFF667085);
          final bg = ok ? const Color(0xFFEAFBF0) : const Color(0xFFF2F4F7);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: fg.withOpacity(0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 16, color: fg),
                const SizedBox(width: 6),
                Text(
                  isArabic ? ar : en,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ],
            ),
          );
        }

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EEFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7A5AF8).withOpacity(0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF7A5AF8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: const Color(0xff2c334a),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFBFE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helper,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password
                      TextField(
                        controller: passCtrl,
                        focusNode: passFocus,
                        obscureText: obscurePass,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => confirmFocus.requestFocus(),
                        onChanged: (v) {
                          setState(() {
                            eval(v);
                            errorText = null;
                          });
                        },
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xff2c334a),
                        ),
                        decoration: InputDecoration(
                          hintText: hintPass,
                          hintStyle: GoogleFonts.cairo(
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF7A5AF8), width: 1.2),
                          ),
                          suffixIcon: IconButton(
                            tooltip: obscurePass
                                ? (isArabic ? 'إظهار' : 'Show')
                                : (isArabic ? 'إخفاء' : 'Hide'),
                            onPressed: () => setState(() => obscurePass = !obscurePass),
                            icon: Icon(
                              obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Rules chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ruleRow(hasMinLen, '٨ أحرف+', '8+ chars'),
                          ruleRow(hasUpper, 'حرف كبير', 'Uppercase'),
                          ruleRow(hasLower, 'حرف صغير', 'Lowercase'),
                          ruleRow(hasDigit, 'رقم', 'Number'),
                          ruleRow(hasSpecial, 'رمز خاص', 'Special'),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Confirm
                      TextField(
                        controller: confirmCtrl,
                        focusNode: confirmFocus,
                        obscureText: obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => submit(),
                        onChanged: (_) {
                          if (errorText != null) setState(() => errorText = null);
                        },
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xff2c334a),
                        ),
                        decoration: InputDecoration(
                          hintText: hintConfirm,
                          hintStyle: GoogleFonts.cairo(
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                          ),
                          errorText: errorText,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF7A5AF8), width: 1.2),
                          ),
                          suffixIcon: IconButton(
                            tooltip: obscureConfirm
                                ? (isArabic ? 'إظهار' : 'Show')
                                : (isArabic ? 'إخفاء' : 'Hide'),
                            onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              _dialogPillButton(
                label: isArabic ? 'إلغاء' : 'Cancel',
                fg: const Color(0xFF667085),
                bg: const Color(0xFFF2F4F7),
                onTap: () => Navigator.pop(dCtx, null),
              ),
              _dialogPillButton(
                label: isArabic ? 'حفظ' : 'Save',
                fg: Colors.white,
                bg: const Color(0xFF7A5AF8),
                onTap: submit,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        );
      },
    ),
  );

  passCtrl.dispose();
  confirmCtrl.dispose();
  passFocus.dispose();
  confirmFocus.dispose();
  return res;
}



Future<bool> _confirmToggleActive(
    BuildContext context, {
      required bool isArabic,
      required bool willActivate,
      required String userName,
    }) async {
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dCtx) {
      final title = willActivate
          ? (isArabic ? 'تأكيد التنشيط' : 'Confirm activation')
          : (isArabic ? 'تأكيد إلغاء التنشيط' : 'Confirm deactivation');

      final content = willActivate
          ? (isArabic
          ? 'هل تريد تنشيط المستخدم:\n$userName ؟'
          : 'Do you want to activate:\n$userName ?')
          : (isArabic
          ? 'هل تريد إلغاء تنشيط المستخدم:\n$userName ؟'
          : 'Do you want to deactivate:\n$userName ?');

      final okText =
      willActivate ? (isArabic ? 'تنشيط' : 'Activate') : (isArabic ? 'إلغاء التنشيط' : 'Deactivate');

      final okBg = willActivate ? const Color(0xFF16A34A) : const Color(0xFFE11D48);
      final okIcon = willActivate ? Icons.power_settings_new_rounded : Icons.block_rounded;

      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          contentPadding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: okBg.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: okBg.withOpacity(0.18)),
                ),
                child: Icon(okIcon, color: okBg, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: const Color(0xff2c334a),
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: 520,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Text(
              content,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: const Color(0xff2c334a),
              ),
            ),
          ),
          actions: [
            _dialogPillButton(
              label: isArabic ? 'إلغاء' : 'Cancel',
              fg: const Color(0xFF667085),
              bg: const Color(0xFFF2F4F7),
              onTap: () => Navigator.pop(dCtx, false),
            ),
            _dialogPillButton(
              label: okText,
              fg: Colors.white,
              bg: okBg,
              icon: okIcon,
              onTap: () => Navigator.pop(dCtx, true),
            ),
          ],
        ),
      );
    },
  );

  return res == true;
}

/// زرار Pill احترافي للـ Dialogs (نفس ستايل الـ actions عندك)
Widget _dialogPillButton({
  required String label,
  required Color fg,
  required Color bg,
  IconData? icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ],
      ),
    ),
  );
}



class _ForbiddenUsersScreen extends StatelessWidget {
  final bool isArabic;

  const _ForbiddenUsersScreen({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f6fa),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Text(
            isArabic
                ? 'هذه الصفحة خاصة بالمسؤول فقط'
                : 'This page is for admins only',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xff2c334a),
            ),
          ),
        ),
      ),
    );
  }
}
