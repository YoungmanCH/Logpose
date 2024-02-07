import 'package:amazon_app/controller/common/time_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule.dart';

class GroupScheduleController {
  ///シングルトンパターンにしています。
  GroupScheduleController._internal();
  static final GroupScheduleController _instance =
      GroupScheduleController._internal();
  static GroupScheduleController get instance => _instance;

  static final db = FirebaseFirestore.instance;
  ///schedule path
  static const collectionPath = 'group_schedules';

  ///Create schudule database.
  static Future<void> create(

      ///Named parameters
      {
    required String groupId,
    required String title,
    required String color,
    String? place,
    String? detail,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    ///Create new document ID.
    final doc = db.collection(collectionPath).doc();

    ///Get created server time.
    final createdAt = FieldValue.serverTimestamp();

    await doc.set({
      'group_id': groupId,
      'title': title,
      'color': color,
      'place': place,
      'detail': detail,
      'start_at': startAt,
      'end_at': endAt,
      'created_at': createdAt,
    });
  }

  ///Get all schedule database.
  static Stream<List<GroupSchedule?>> readAll(String groupId) async* {
    final schedulesStream = db
        .collection(collectionPath)
        .where(
          'group_id',
          isEqualTo: groupId,
        )
        .snapshots();

    await for (final schedules in schedulesStream) {
      final schedulesRefs = schedules.docs.map((doc) {
        final scheduleRef = doc.data() as Map<String, dynamic>?;
        if (scheduleRef == null) {
          return null;
        }
        final groupId = scheduleRef['group_id'] as String;
        final title = scheduleRef['title'] as String;
        final color = scheduleRef['color'] as String;
        final place = scheduleRef['place'] as String?;
        final detail = scheduleRef['detail'] as String?;
        final startAt = convertTimestampToDateTime(scheduleRef['start_at']);
        final endAt = convertTimestampToDateTime(scheduleRef['end_at']);
        final updatedAt = scheduleRef['updated_at'] as Timestamp?;
        final createdAt = scheduleRef['created_at'] as Timestamp?;
        if (createdAt == null) {
          return null;
        }

        return GroupSchedule(
          groupId: groupId,
          title: title,
          color: color,
          place: place,
          detail: detail,
          startAt: startAt!,
          endAt: endAt!,
          updatedAt: updatedAt,
          createdAt: createdAt,
        );
        // return GroupSchedule.fromMap(scheduleRef);
      }).toList();

      yield schedulesRefs;
    }
  }

  // /// Read list of schedule ID.
  // static Stream<List<String?>> readAllScheduleId(String groupId) async* {
  //   final schedulesStream = db
  //       .collection(collectionPath)
  //       .where(
  //         'group_id',
  //         isEqualTo: groupId,
  //       )
  //       .snapshots();

  //   await for (final schedules in schedulesStream) {
  //     final schedulesRefs = schedules.docs.map((doc) {
  //       final scheduleRef = doc.data() as Map<String, dynamic>?;
  //       if (scheduleRef == null) {
  //         return null;
  //       }
  //       final groupId = scheduleRef['group_id'] as String;
  //       final title = scheduleRef['title'] as String;
  //       final color = scheduleRef['color'] as String;
  //       final place = scheduleRef['place'] as String?;
  //       final detail = scheduleRef['detail'] as String?;
  //       final startAt = convertTimestampToDateTime(scheduleRef['start_at']);
  //       final endAt = convertTimestampToDateTime(scheduleRef['end_at']);
  //       final updatedAt = scheduleRef['updated_at'] as Timestamp?;
  //       final createdAt = scheduleRef['created_at'] as Timestamp?;
  //       if (createdAt == null) {
  //         return null;
  //       }

  //       return GroupSchedule(
  //         groupId: groupId,
  //         title: title,
  //         color: color,
  //         place: place,
  //         detail: detail,
  //         startAt: startAt!,
  //         endAt: endAt!,
  //         updatedAt: updatedAt,
  //         createdAt: createdAt,
  //       );
  //     }).toList();

  //     yield schedulesRefs;
  //   }
  // }

  //Get selected schedule database.
  static Future<GroupSchedule> read(String docId) async {
    final snapshot = await db.collection(collectionPath).doc(docId).get();
    final scheduleRef = snapshot.data();
    if (scheduleRef == null) {
      throw Exception('documentId not found.');
    }

    return GroupSchedule.fromMap(scheduleRef);
  }

  ///Update scheule database.
  ///Group ID can't be changed.
  static Future<void> update({
    required String docId,
    required String groupId,
    required String title,
    required String? place,
    required String color,
    required String? detail,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final updatedAt = FieldValue.serverTimestamp();
    final updateData = <String, dynamic>{
      'group_id': groupId,
      'title': title,
      'place': place,
      'color': color,
      'detail': detail,
      'start_at': startAt,
      'end_at': endAt,
      'updated_at': updatedAt,
    };

    await db.collection(collectionPath).doc(docId).update(updateData);
  }

  static Future<void> delete(String docId) async {
    await db.collection(collectionPath).doc(docId).delete();
  }
}
