import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

class TeacherMessagesScreen extends StatefulWidget {
  const TeacherMessagesScreen({super.key});

  @override
  State<TeacherMessagesScreen> createState() => _TeacherMessagesScreenState();
}

class _TeacherMessagesScreenState extends State<TeacherMessagesScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'أحمد محمد علي (طالب)',
      'lastMsg': 'أستاذي الفاضل، هل يمكن إعادة شرح نقطة الحث الكهرومغناطيسي؟',
      'time': 'منذ 15 دقيقة',
      'unread': 2,
    },
    {
      'id': '2',
      'name': 'ولي أمر الطالبة سارة إبراهيم',
      'lastMsg': 'شكراً جزيلاً لحضرتك على التقرير الشامل ودرجات الاختبار.',
      'time': 'منذ ساعة',
      'unread': 0,
    },
    {
      'id': '3',
      'name': 'محمود حسن (طالب)',
      'lastMsg': 'تم تسليم الواجب المنزلي الخاص بالدرس الثاني.',
      'time': 'أمس',
      'unread': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'الرسائل والتواصل المباشر',
          subtitle: 'محادثات الطلاب وأولياء الأمور بالمنصة',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.r),
            itemCount: _chats.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = _chats[index];
              return _buildChatTile(item);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> item) {
    final int unread = item['unread'] as int;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: unread > 0 ? DeskColors.primarySoft.withAlpha(40) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: unread > 0 ? DeskColors.primary.withAlpha(60) : DeskColors.line,
        ),
      ),
      child: Row(
        children: [
          DeskAvatar(initial: item['name'] as String, radius: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] as String,
                        style: DeskText.strong(13.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(item['time'] as String, style: DeskText.note(10.5.sp)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item['lastMsg'] as String,
                  style: DeskText.body(11.5.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
