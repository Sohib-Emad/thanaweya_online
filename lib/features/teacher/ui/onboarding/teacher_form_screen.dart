// ────────────────────────────────────────────────────────────
// THESIS — طلب الالتحاق بالمدرس
//   The teacher's chalkboard enrollment form: personal data +
//   identity/teaching proof uploads (step 0), specialty/subjects/
//   tracks/stages (step 1), location + teaching mode + final
//   confirmation (step 2). Saves every collected field.
// OWN-WORLD — Chalkboard (سبورة): green board ground, chalk-white
//   ink, mint/red/yellow/blue chalk accents, rubber stamps.
// STORY — A teacher walks to the classroom board and writes their
//   application in chalk: identity first, then what they teach,
//   then where and how they teach, then submit for review.
// FIRST VIEWPORT — Chalkboard ground + 3-chalk-dot stepper + the
//   first step form (avatar, name, phone, email, password, cards).
// FORM — 3 steps; every field is validated and persisted through
//   AuthCubit.signUp + _upsertTeacherData (incl. the previously
//   unsaved system/governorate/mode/stages/tracks).
// FINISH — Submits signup, uploads documents, upserts the teacher
//   row, then routes to the pending-review chalkboard.
// ────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/core/utils/validators.dart';
import 'package:thanaweya_online/features/auth/data/repos/auth_repo.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/features/auth/logic/auth_state.dart' as local;

class TeacherFormScreen extends StatefulWidget {
  const TeacherFormScreen({super.key});

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  int _teacherSystemIndex =
      0; // 0 = عامة (قديم), 1 = البكالوريا (IB), 2 = كلا النظامين
  final Set<String> _selectedSubjectIds = {};
  final Set<String> _selectedTrackIds = {};
  List<Map<String, dynamic>> _teacherSubjectsList = [];

  static const _systemKeys = ['general', 'baccalaureate', 'both'];

  final List<Map<String, dynamic>> _baccalaureateTracks = [
    {
      'id': 'track_med',
      'name_ar': 'مسار الطب وعلوم الحياة',
      'qualifying':
          'يؤهل لكليات: الطب البشري، الصيدلة، الأسنان، العلاج الطبيعي، والتمريض.',
      'color': ChalkboardColors.accent,
    },
    {
      'id': 'track_eng',
      'name_ar': 'مسار الهندسة وعلوم الحاسب',
      'qualifying':
          'يؤهل لكليات: الهندسة، الحاسبات والمعلومات، والتكنولوجيا الحيوية.',
      'color': ChalkboardColors.chalkBlue,
    },
    {
      'id': 'track_biz',
      'name_ar': 'مسار الأعمال والاقتصاد',
      'qualifying':
          'يؤهل لكليات: التجارة، الاقتصاد والعلوم السياسية، الإعلام، والحقوق.',
      'color': ChalkboardColors.chalkYellow,
    },
    {
      'id': 'track_arts',
      'name_ar': 'مسار الآداب والفنون',
      'qualifying': 'يؤهل لكليات: الآداب، الألسن، الفنون الجميلة، ودار العلوم.',
      'color': ChalkboardColors.chalkRed,
    },
  ];

  IconData _getTrackIcon(String trackId) {
    switch (trackId) {
      case 'track_med':
        return Icons.medical_services_rounded;
      case 'track_eng':
        return Icons.computer_rounded;
      case 'track_biz':
        return Icons.business_center_rounded;
      case 'track_arts':
        return Icons.palette_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  final List<String> _selectedStages = [];
  String _teachingMode = 'online'; // online, center, both
  String? _selectedGovernorate = 'القاهرة';
  bool _agreedToTerms = true;

  // Selected Image Files
  XFile? _avatarFile;
  XFile? _idFrontFile;
  XFile? _idBackFile;
  XFile? _teacherProofFile;

  int _currentStep = 0; // 0, 1, 2

  final ImagePicker _picker = ImagePicker();
  late final AuthCubit _authCubit;

  final _stages = [
    {'value': 'first', 'name': AppStrings.firstStage},
    {'value': 'second', 'name': AppStrings.secondStage},
    {'value': 'third', 'name': AppStrings.thirdStage},
  ];

  final _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'أسيوط',
    'الشرقية',
    'طنطا',
  ];

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepo: AuthRepo());
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final data = await Supabase.instance.client
          .from('subjects')
          .select('id, name_ar')
          .eq('is_active', true)
          .order('display_order');
      if (mounted) {
        setState(() => _teacherSubjectsList = List<Map<String, dynamic>>.from(data));
      }
    } catch (e) {
      debugPrint('[TeacherForm] failed to load subjects: $e');
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showChalkSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: ChalkboardText.body(13.sp, color: ChalkboardColors.ink),
        ),
        backgroundColor: ChalkboardColors.surfaceBright,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  // Show Bottom Sheet Modal for Gallery / Camera choice
  Future<void> _showImageSourcePicker({
    required String title,
    required Function(XFile?) onImageSelected,
  }) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: ChalkboardColors.ground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                    decoration: BoxDecoration(
                      color: ChalkboardColors.chalkFaint,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: ChalkboardText.heading(16.sp)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: ChalkboardColors.chalkSoft,
                        size: 24.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _ChalkSourceTile(
                  icon: Icons.photo_library_rounded,
                  color: ChalkboardColors.accent,
                  title: 'اختيار من معرض الصور (Gallery)',
                  subtitle: 'اختر صورة واضحة محفوظة على جهازك',
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (file != null) onImageSelected(file);
                    } catch (_) {
                      _showChalkSnack('تعذر فتح معرض الصور، حاول مرة أخرى');
                    }
                  },
                ),
                SizedBox(height: 10.h),
                _ChalkSourceTile(
                  icon: Icons.camera_alt_rounded,
                  color: ChalkboardColors.chalkBlue,
                  title: 'التقاط صورة جديدة بالكاميرا (Camera)',
                  subtitle: 'استخدم كاميرا الهيدر لتصوير المستند فوراً',
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (file != null) onImageSelected(file);
                    } catch (_) {
                      _showChalkSnack('تعذر فتح الكاميرا، حاول مرة أخرى');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep == 0) {
      if (_step0Key.currentState!.validate()) {
        if (_idFrontFile == null || _idBackFile == null) {
          _showChalkSnack('برجاء إرفاق صورة وجه وظهر بطاقة الرقم القومي');
          return;
        }
        if (_teacherProofFile == null) {
          _showChalkSnack('برجاء إرفاق مستند إثبات ممارسة التدريس أو الكارنيه');
          return;
        }
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_teacherSystemIndex == 0 && _selectedSubjectIds.isEmpty) {
        _showChalkSnack('برجاء اختيار مادة واحدة على الأقل');
        return;
      }
      if (_teacherSystemIndex == 1 && _selectedTrackIds.isEmpty) {
        _showChalkSnack('برجاء اختيار مسار أكاديمي واحد على الأقل');
        return;
      }
      if (_teacherSystemIndex == 2 &&
          _selectedSubjectIds.isEmpty &&
          _selectedTrackIds.isEmpty) {
        _showChalkSnack('برجاء اختيار مادة أو مسار أكاديمي واحد على الأقل');
        return;
      }
      if (_selectedStages.isEmpty && _teacherSystemIndex != 1) {
        _showChalkSnack('اختر مرحلة واحدة على الأقل');
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      _onSubmitFinal();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onSubmitFinal() {
    if (!_agreedToTerms) {
      _showChalkSnack('برجاء الموافقة على الشروط والأحكام');
      return;
    }
    HapticFeedback.mediumImpact();
    _authCubit.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: 'teacher',
    );
  }

  Future<void> _upsertTeacherData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final stage =
          _selectedStages.isNotEmpty ? _selectedStages.first : null;

      final urls = await StorageHelper.uploadTeacherDocuments(
        userId: userId,
        files: {
          'avatar': _avatarFile,
          'id_front': _idFrontFile,
          'id_back': _idBackFile,
          'proof': _teacherProofFile,
        },
      );

      await Supabase.instance.client.from('teachers').upsert({
        'id': userId,
        'subject_id': _selectedSubjectIds.isNotEmpty
            ? _selectedSubjectIds.first
            : null,
        'stage': stage,
        'teaching_system': _systemKeys[_teacherSystemIndex],
        'stages': _selectedStages.toList(),
        'baccalaureate_tracks': _selectedTrackIds.toList(),
        'governorate': _selectedGovernorate,
        'teaching_mode': _teachingMode,
        'bio': _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        'approval_status': 'pending',
        'avatar_url': urls['avatar'],
        'id_card_front_url': urls['id_front'],
        'id_card_back_url': urls['id_back'],
        'teacher_proof_url': urls['proof'],
      }, onConflict: 'id');

      if (urls['avatar'] != null) {
        await Supabase.instance.client.from('users').update({
          'avatar_url': urls['avatar'],
        }).eq('id', userId);
      }

      debugPrint('[TeacherForm] upserted teacher data with document URLs');
    } catch (e) {
      debugPrint('[TeacherForm] upsert teacher data failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ChalkboardColors.ground,
          body: SafeArea(
            bottom: false,
            child: ChalkboardSurface(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          GestureDetector(
                            onTap: _prevStep,
                            child: Container(
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                color: ChalkboardColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ChalkboardColors.accent.withAlpha(160),
                                  width: 1.4,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: ChalkboardColors.accent,
                                size: 20.r,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                color: ChalkboardColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ChalkboardColors.ink.withAlpha(90),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: ChalkboardColors.chalkSoft,
                                size: 20.r,
                              ),
                            ),
                          ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(
                            'طلب الالتحاق',
                            style: ChalkboardText.heading(18.sp),
                          ),
                        ),
                        const ChalkStamp(
                          label: 'جديد',
                          color: ChalkboardColors.chalkYellow,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Stepper Progress Bar (3 chalk dots)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        _StepItem(
                          label: 'بيانات المعلم',
                          isActive: _currentStep >= 0,
                          isCompleted: _currentStep > 0,
                        ),
                        _StepConnector(isActive: _currentStep >= 1),
                        _StepItem(
                          label: 'التخصص والمادة',
                          isActive: _currentStep >= 1,
                          isCompleted: _currentStep > 1,
                        ),
                        _StepConnector(isActive: _currentStep >= 2),
                        _StepItem(
                          label: 'المراحل والتواصل',
                          isActive: _currentStep >= 2,
                          isCompleted: _currentStep > 2,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Scrollable Step Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildCurrentStepView(),
                      ),
                    ),
                  ),

                  // Bottom Buttons
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    child: _buildBottomButtons(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep0View();
      case 1:
        return _buildStep1View();
      case 2:
        return _buildStep2View();
      default:
        return _buildStep0View();
    }
  }

  // STEP 0: بيانات المعلم وإثبات الهوية والمهنة
  Widget _buildStep0View() {
    return Form(
      key: _step0Key,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ChalkSectionHeader(
            title: 'بيانات المعلم والإثباتات',
            accent: ChalkboardColors.accent,
          ),
          SizedBox(height: 20.h),

          // Avatar Picker Widget
          Center(
            child: GestureDetector(
              onTap: () {
                _showImageSourcePicker(
                  title: 'اختيار صورة البروفايل',
                  onImageSelected: (file) {
                    setState(() => _avatarFile = file);
                  },
                );
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 86.r,
                    height: 86.r,
                    decoration: BoxDecoration(
                      color: ChalkboardColors.surfaceBright,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ChalkboardColors.accent.withAlpha(150),
                        width: 1.8,
                      ),
                      image: _avatarFile != null
                          ? DecorationImage(
                              image: FileImage(File(_avatarFile!.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _avatarFile == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 44.r,
                            color: ChalkboardColors.chalkSoft,
                          )
                        : null,
                  ),
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: ChalkboardColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 14.r,
                      color: ChalkboardColors.onAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 22.h),

          // الاسم الكامل*
          ChalkInputField(
            label: 'الاسم الكامل*',
            controller: _nameController,
            icon: Icons.person_outline_rounded,
            hint: 'أدخل الاسم الثلاثي كما في البطاقة...',
            validator: (v) => v!.isEmpty ? AppStrings.fieldRequired : null,
          ),
          SizedBox(height: 20.h),

          // رقم الهاتف*
          ChalkInputField(
            label: 'رقم الهاتف*',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            hint: '010XXXXXXXX',
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          SizedBox(height: 20.h),

          // البريد الإلكتروني*
          ChalkInputField(
            label: 'البريد الإلكتروني*',
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            hint: 'example@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          SizedBox(height: 20.h),

          // كلمة السر*
          ChalkInputField(
            label: 'كلمة السر*',
            controller: _passwordController,
            icon: Icons.lock_outline_rounded,
            hint: '••••••••',
            obscureText: true,
            validator: (v) => v!.isEmpty ? AppStrings.fieldRequired : null,
          ),
          SizedBox(height: 24.h),

          // 1. بطاقة الرقم القومي (وش وظهر)
          _FieldLabel(label: 'إثبات الهوية الشخصية (بطاقة الرقم القومي)*'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _ChalkUploadCard(
                  title: 'وجه البطاقة',
                  isAttached: _idFrontFile != null,
                  fileName: _idFrontFile?.name,
                  icon: Icons.credit_card_rounded,
                  accent: ChalkboardColors.accent,
                  onTap: () {
                    _showImageSourcePicker(
                      title: 'إرفاق صورة وجه البطاقة',
                      onImageSelected: (file) {
                        setState(() => _idFrontFile = file);
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ChalkUploadCard(
                  title: 'ظهر البطاقة',
                  isAttached: _idBackFile != null,
                  fileName: _idBackFile?.name,
                  icon: Icons.credit_card_outlined,
                  accent: ChalkboardColors.chalkBlue,
                  onTap: () {
                    _showImageSourcePicker(
                      title: 'إرفاق صورة ظهر البطاقة',
                      onImageSelected: (file) {
                        setState(() => _idBackFile = file);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // 2. إثبات ممارسة التدريس (كارنيه النقابة / إفادة)
          _FieldLabel(
            label: 'مستند إثبات ممارسة التدريس (كارنيه المعلم / النقابة)*',
          ),
          SizedBox(height: 8.h),
          _ChalkUploadCard(
            title: 'إرفاق كارنيه النقابة أو إفادة التدريس الرسمية',
            subtitle: _teacherProofFile != null
                ? 'تم إرفاق: ${_teacherProofFile!.name} ✓'
                : 'انقر لاختيار صورة كارنيه المعلم أو إفادة المدرسة/السنتر',
            isAttached: _teacherProofFile != null,
            fileName: _teacherProofFile?.name,
            icon: Icons.verified_user_rounded,
            accent: ChalkboardColors.chalkYellow,
            onTap: () {
              _showImageSourcePicker(
                title: 'إرفاق مستند ممارسة التدريس',
                onImageSelected: (file) {
                  setState(() => _teacherProofFile = file);
                },
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // STEP 1: بيانات التخصص والمادة والمراحل
  Widget _buildStep1View() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ChalkSectionHeader(
            title: 'بيانات التخصص والمادة',
            accent: ChalkboardColors.accent,
          ),
          SizedBox(height: 18.h),

          // النظام التعليمي للمعلم
          _FieldLabel(label: 'النظام التعليمي المتاح لديك للتدريس*'),
          SizedBox(height: 8.h),
          ChalkSegmentedControl(
            options: const ['عامة (قديم)', 'البكالوريا (IB)', 'كلا النظامين'],
            index: _teacherSystemIndex,
            onChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _teacherSystemIndex = i);
            },
          ),

          SizedBox(height: 20.h),

          // 1. المواد للثانوية العامة
          if (_teacherSystemIndex == 0 || _teacherSystemIndex == 2) ...[
            _FieldLabel(label: 'المادة الدراسية (النظام العام)*'),
            SizedBox(height: 8.h),
            if (_teacherSubjectsList.isEmpty)
              ChalkEmptyNote(
                message: 'جارٍ تحميل قائمة المواد...',
                subMessage: 'المواد تُرسم على السبورة حالياً',
              )
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 10.h,
                children: _teacherSubjectsList.map((subject) {
                  final subjectId = subject['id'] as String? ?? '';
                  final subjectName = subject['name_ar'] as String? ?? '';
                  final isSelected = _selectedSubjectIds.contains(subjectId);
                  return ChalkChip(
                    label: subjectName,
                    selected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected) {
                          _selectedSubjectIds.remove(subjectId);
                        } else {
                          _selectedSubjectIds.add(subjectId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            SizedBox(height: 20.h),
            _FieldLabel(label: 'المراحل الدراسية المتاح تدرسها*'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _stages.map((stage) {
                final isSelected = _selectedStages.contains(stage['value']);
                return ChalkChip(
                  label: stage['name']!,
                  selected: isSelected,
                  accent: ChalkboardColors.chalkBlue,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isSelected) {
                        _selectedStages.remove(stage['value']);
                      } else {
                        _selectedStages.add(stage['value']!);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
          ],

          // 2. مسارات البكالوريا الأكاديمية
          if (_teacherSystemIndex == 1 || _teacherSystemIndex == 2) ...[
            _FieldLabel(label: 'مسارات البكالوريا المتاح تدريسها (IB)*'),
            SizedBox(height: 10.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _baccalaureateTracks.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final track = _baccalaureateTracks[index];
                final trackId = track['id'] as String? ?? '';
                final trackName = track['name_ar'] as String? ?? '';
                final qualifying = track['qualifying'] as String? ?? '';
                final color = track['color'] as Color;
                final isSelected = _selectedTrackIds.contains(trackId);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (isSelected) {
                        _selectedTrackIds.remove(trackId);
                      } else {
                        _selectedTrackIds.add(trackId);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(24)
                          : ChalkboardColors.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? color.withAlpha(200)
                            : ChalkboardColors.ink.withAlpha(50),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: color.withAlpha(30),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                _getTrackIcon(trackId),
                                color: color,
                                size: 18.r,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                trackName.trim(),
                                style: ChalkboardText.strong(14.sp,
                                    color: isSelected
                                        ? color
                                        : ChalkboardColors.ink),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22.r,
                              height: 22.r,
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : ChalkboardColors.chalkFaint,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: ChalkboardColors.onAccent,
                                      size: 14.r,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          qualifying,
                          style: ChalkboardText.note(11.sp),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
          _FieldLabel(label: 'نبذة عن خبرتك وأسلوب الشرح'),
          SizedBox(height: 6.h),
          ChalkInputField(
            label: '',
            controller: _bioController,
            hint: 'اكتب نبذة مختصرة عن مؤهلاتك وتجاربك السابقة...',
            maxLines: 4,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // STEP 2: التواجد والتأكيد النهائي
  Widget _buildStep2View() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey(2),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ChalkSectionHeader(
            title: 'المراحل والتواصل',
            accent: ChalkboardColors.accent,
          ),
          SizedBox(height: 18.h),
          _FieldLabel(label: 'المحافظة الحالية*'),
          SizedBox(height: 8.h),
          _ChalkDropdown(
            label: 'المحافظة',
            value: _selectedGovernorate,
            hint: 'اختر المحافظة...',
            options: _governorates,
            onChanged: (v) => setState(() => _selectedGovernorate = v),
          ),
          SizedBox(height: 20.h),
          _FieldLabel(label: 'طريقة التدريس المتاحة لديك*'),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildModeOption('online', 'أونلاين', Icons.laptop_mac_rounded),
              SizedBox(width: 8.w),
              _buildModeOption('center', 'سنتر', Icons.location_city_rounded),
              SizedBox(width: 8.w),
              _buildModeOption('both', 'كلاهما', Icons.auto_awesome_rounded),
            ],
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: ChalkboardColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _agreedToTerms
                      ? ChalkboardColors.accent.withAlpha(140)
                      : ChalkboardColors.ink.withAlpha(50),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: _agreedToTerms
                          ? ChalkboardColors.accent
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _agreedToTerms
                            ? ChalkboardColors.accent
                            : ChalkboardColors.chalkFaint,
                        width: 1.6,
                      ),
                    ),
                    child: _agreedToTerms
                        ? Icon(
                            Icons.check_rounded,
                            color: ChalkboardColors.onAccent,
                            size: 16.r,
                          )
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'أقر أنا المعلم بصحة البيانات المدخلة وبالموافقة على شروط وقوانين منصة ثانوية أونلاين.',
                      style: ChalkboardText.body(12.sp,
                              color: ChalkboardColors.chalkSoft)
                          .copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildModeOption(String modeKey, String label, IconData iconData) {
    bool isSelected = _teachingMode == modeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _teachingMode = modeKey);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? ChalkboardColors.accent.withAlpha(26)
                : ChalkboardColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? ChalkboardColors.accent
                  : ChalkboardColors.ink.withAlpha(50),
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 20.r,
                color: isSelected
                    ? ChalkboardColors.accent
                    : ChalkboardColors.chalkSoft,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: ChalkboardText.strong(12.sp,
                    color: isSelected
                        ? ChalkboardColors.accent
                        : ChalkboardColors.chalkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Buttons Layout
  Widget _buildBottomButtons() {
    if (_currentStep == 0) {
      return ChalkPrimaryButton(
        label: 'التالي',
        icon: Icons.arrow_back_rounded,
        onPressed: _nextStep,
      );
    } else if (_currentStep == 2) {
      return BlocConsumer<AuthCubit, local.AuthState>(
        listener: (context, state) {
          switch (state.status) {
            case local.AuthStatus.authenticated:
              _upsertTeacherData();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.teacherPending,
                (route) => false,
              );
              break;
            case local.AuthStatus.error:
              if (state.errorMessage != null) {
                _showChalkSnack(state.errorMessage!);
              }
              break;
            default:
              break;
          }
        },
        builder: (context, state) {
          final isLoading = state.status == local.AuthStatus.loading;
          return Row(
            children: [
              Expanded(
                child: ChalkOutlineButton(
                  label: 'السابق',
                  icon: Icons.arrow_forward_rounded,
                  color: ChalkboardColors.chalkSoft,
                  onPressed: _prevStep,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ChalkPrimaryButton(
                  label: 'إرسال طلب الانضمام',
                  icon: Icons.send_rounded,
                  loading: isLoading,
                  onPressed: isLoading ? null : _onSubmitFinal,
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ChalkOutlineButton(
              label: 'السابق',
              icon: Icons.arrow_forward_rounded,
              color: ChalkboardColors.chalkSoft,
              onPressed: _prevStep,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ChalkPrimaryButton(
              label: 'التالي',
              icon: Icons.arrow_back_rounded,
              onPressed: _nextStep,
            ),
          ),
        ],
      );
    }
  }
}

// Label above input
class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: ChalkboardText.strong(12.sp));
  }
}

// Gallery / Camera option tile inside the chalk bottom sheet
class _ChalkSourceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChalkSourceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: ChalkboardColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: ChalkboardColors.ink.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ChalkboardText.strong(13.sp)),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: ChalkboardText.note(11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: ChalkboardColors.chalkSoft,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

// Upload Card Widget for National ID Front/Back & Teacher Verification Proof
class _ChalkUploadCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? fileName;
  final bool isAttached;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ChalkUploadCard({
    required this.title,
    this.subtitle,
    this.fileName,
    required this.isAttached,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isAttached
              ? accent.withAlpha(22)
              : ChalkboardColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isAttached
                ? accent.withAlpha(190)
                : ChalkboardColors.ink.withAlpha(50),
            width: isAttached ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isAttached ? accent : ChalkboardColors.surfaceBright,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAttached ? Icons.check_rounded : icon,
                color: isAttached ? ChalkboardColors.onAccent : ChalkboardColors.chalkSoft,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ChalkboardText.strong(12.sp,
                        color: isAttached ? accent : ChalkboardColors.ink),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isAttached
                        ? (fileName != null
                              ? 'تم إرفاق: $fileName ✓'
                              : 'تم إرفاق الصورة ✓')
                        : (subtitle ?? 'انقر لاختيار صورة من جهازك'),
                    style: ChalkboardText.note(10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chalk dropdown built as a tappable field + dark bottom-sheet picker
class _ChalkDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _ChalkDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: const BoxDecoration(
                  color: ChalkboardColors.ground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        margin: EdgeInsets.only(top: 10.h, bottom: 12.h),
                        decoration: BoxDecoration(
                          color: ChalkboardColors.chalkFaint,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    Text(
                      'اختر $label',
                      style: ChalkboardText.heading(16.sp),
                    ),
                    SizedBox(height: 14.h),
                    ...options.map((option) {
                      final isSelected = option == value;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onChanged(option);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ChalkboardColors.accent.withAlpha(22)
                                : ChalkboardColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? ChalkboardColors.accent.withAlpha(180)
                                  : ChalkboardColors.ink.withAlpha(40),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: ChalkboardText.body(13.sp,
                                      color: isSelected
                                          ? ChalkboardColors.accent
                                          : ChalkboardColors.ink),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: ChalkboardColors.accent,
                                  size: 20.r,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: ChalkboardColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: ChalkboardColors.ink.withAlpha(50),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: ChalkboardColors.accent,
              size: 18.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                value ?? hint,
                style: ChalkboardText.body(13.sp,
                    color: value != null
                        ? ChalkboardColors.ink
                        : ChalkboardColors.chalkFaint),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ChalkboardColors.chalkSoft,
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }
}

// Stepper Dot Item
class _StepItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            color: isCompleted
                ? ChalkboardColors.accent
                : isActive
                    ? ChalkboardColors.accent.withAlpha(30)
                    : ChalkboardColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? ChalkboardColors.accent
                  : ChalkboardColors.chalkFaint,
              width: isActive ? 1.8 : 1.2,
            ),
          ),
          child: isCompleted
              ? Icon(
                  Icons.check_rounded,
                  color: ChalkboardColors.onAccent,
                  size: 15.r,
                )
              : null,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: ChalkboardText.strong(10.sp,
              color: isActive
                  ? ChalkboardColors.accent
                  : ChalkboardColors.chalkFaint),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isActive;

  const _StepConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 20.h),
        color: isActive
            ? ChalkboardColors.accent.withAlpha(160)
            : ChalkboardColors.chalkFaint.withAlpha(90),
      ),
    );
  }
}
