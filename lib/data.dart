import 'package:cloud_firestore/cloud_firestore.dart';

class Module {
  final String modCode;
  final String modIcon;
  final List<String> lectureSelect;

  Module(this.modCode, this.modIcon, this.lectureSelect);
}


class studentProfile {
  String adm, classNo, email, name;
  List<String> lecturers;
  List<Module> mods;

  studentProfile(this.adm, this.classNo, this.email, this.name, this.lecturers, this.mods);
}

class studentProfile_Service {
  static List<studentProfile> z = [];
  static CollectionReference studentData =
      FirebaseFirestore.instance.collection('students');

  static Future<void> getAllStudents() async {
    z.clear();
    QuerySnapshot qs = await studentData.get();

    for (var doc in qs.docs) {
      final studentInfo = doc.data() as Map<String, dynamic>;

      // Lecturers
      final List<String> lecturers =
          studentInfo['Lecturers'] != null
              ? List<String>.from(studentInfo['Lecturers'])
              : [];

      final List<Module> mods = studentInfo['Modules'] != null
        ? (studentInfo['Modules'] as List).map((m) {
            final List<String> moduleLecturers = m['lecturer'] != null
                ? List<String>.from(m['lecturer'])
                : [];
            return Module(
              m['modCode'] ?? 'Unknown',
              m['modIcon'] ?? 'book',
              moduleLecturers,
            );
          }).toList()
        : [];

      z.add(
        studentProfile(
          studentInfo['adm'],
          studentInfo['class'],
          studentInfo['email'],
          studentInfo['name'],
          lecturers,
          mods,
        ),
      );
    }
  }

  static studentProfile? getProfileAt(int index) {
    if (index < 0 || index >= z.length) return null;
    return z[index];
  }
}


class Availability {
  String date, timeslots;

  Availability(this.date, this.timeslots);

  @override
  String toString() => 'Availability(date: $date, timeslots: $timeslots)';
}

class LectureInfo {
  String staffID;
  String name;
  String email;
  List<Availability> availability;

  LectureInfo(this.staffID, this.name, this.email, this.availability);

  @override
  String toString() =>
      'LectureInfo(staffID: $staffID, name: $name, email: $email, availability: $availability)';
}

class LectureProfileService {
  static List<LectureInfo> lecturers = [];

  static CollectionReference lectureData =
      FirebaseFirestore.instance.collection('lecturers');

  static Future<void> getAllLecturers() async {
    lecturers.clear();

    print('Fetching lecturers from Firebase...');
    QuerySnapshot qs = await lectureData.get();

    for (var doc in qs.docs) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) continue; // skip empty docs
      print('Raw doc data: $data');

      final staffID = data['adm']?.toString() ?? '';
      final name = data['name']?.toString() ?? '';
      final email = data['email']?.toString() ?? '';

      final List<Availability> availList =
          (data['availability'] as List<dynamic>?)
                  ?.map((a) {
                    final map = a as Map<String, dynamic>? ?? {};
                    final date = map['date']?.toString() ?? '';
                    final timeslots = map['timeslots']?.toString() ?? '';
                    return Availability(date, timeslots);
                  })
                  .where((a) => a.date.isNotEmpty && a.timeslots.isNotEmpty)
                  .toList() ??
              [];

      final lecture = LectureInfo(staffID, name, email, availList);
      lecturers.add(lecture);

      print('Parsed LectureInfo: $lecture');
    }

    print('Total lecturers fetched: ${lecturers.length}');
  }

  static LectureInfo getProfileAt(int index) {
    return lecturers[index];
  }
}



class consults {
  String lecturer, lectureNotes, location, mod, status, student, studentNotes, timeslot;
  List<int> dates;

  consults(this.lecturer, this.lectureNotes, this.location, this.mod, this.status, this.student,
          this.studentNotes, this.timeslot, this.dates);

}


class consultService {
    static List<consults> completed = [];
    static List<consults> scheduled = [];
    static List<consults> pending = [];

    static CollectionReference consult =
      FirebaseFirestore.instance.collection('consults');

    static Future<void> getAllConsults() async {
      completed.clear();
      scheduled.clear();
      pending.clear();
      QuerySnapshot qs = await consult.get();
      print(qs.docs);

      for (int i=0;i<qs.docs.length;i++){
        DocumentSnapshot doc = qs.docs[i];
        Map<String, dynamic> consultInfo = doc.data() as Map<String,dynamic>;
      
        final lecturer = consultInfo['lecturer']?.toString() ?? 'Unknown';
        final lecturerNotes = consultInfo['lecturer_notes']?.toString() ?? '';
        final location = consultInfo['location']?.toString() ?? 'Unknown';
        final module = consultInfo['module']?.toString() ?? 'Unknown';
        final student = consultInfo['student']?.toString() ?? 'Unknown';
        final studentNotes = consultInfo['student_notes']?.toString() ?? '';
        final timeslot = consultInfo['timeslot']?.toString() ?? '';



      // ✅ Normalize status
        final status = (consultInfo['status']?.toString() ?? 'pending').trim().toLowerCase();

        // ✅ Safe date conversion
        final datesDynamic = consultInfo['date'];
        final dates = <int>[];
        if (datesDynamic != null && datesDynamic is List) {
          for (var d in datesDynamic) {
            if (d != null) dates.add(int.tryParse(d.toString()) ?? 0);
          }
        }


      // Create consult object
        final c = consults(
          lecturer,
          lecturerNotes,
          location,
          module,
          status,
          student,
          studentNotes,
          timeslot,
          dates,
        );



      if (status == 'completed') {
        completed.add(c);
        print(completed);
      } else if (status == 'scheduled') {
        scheduled.add(c);
      } else {
        pending.add(c);
      }
      }

    // Debug
    print('Completed: ${completed.length}');
    print('Scheduled: ${scheduled.length}');
    print('Pending: ${pending.length}');

  }

}



// import 'package:cloud_firestore/cloud_firestore.dart';

// class studentProfile {
//   String adm="", classNo="", email="" , name="";

//   studentProfile(this.adm, this.classNo, this.email, this.name);

// }

// class studentProfile_Service {
//   static List <studentProfile> z = [];

//   static String adm = "";
//   static String classNo = "";
//   static String email = "";
//   static String name = "";

//   static CollectionReference studentData = FirebaseFirestore.instance.collection('students');

//   static Future<void> getAllStudents() async{
//     z.clear();
//     QuerySnapshot qs = await studentData.get();

//     for (int i=0;i<qs.docs.length;i++){
//       DocumentSnapshot doc = qs.docs[i];
//       Map<String, dynamic> studentInfo = doc.data() as Map<String,dynamic>;
//       z.add(studentProfile(studentInfo['adm'], studentInfo['class'], studentInfo['email'], studentInfo['name']));
//     }


//   }

//   static studentProfile getProfileAt(int index){
//     return (z[index]);
//   }

// }


// class consults {
//   String lecturer="", lectureNotes="", location="", mod="", status="", student="", studentNotes="", timeslot="";
//   List dates = [];

//   consults(this.lecturer, this.lectureNotes, this.location, this.mod, 
//   this.status, this.student, this.studentNotes, this.timeslot, this.dates);
// }

// class consultService {

//   static List <consults> completed = [];
//   static List <consults> scheduled = [];
//   static List <consults> pending = [];

//   static String lecturer = "";
//   static String lectureNotes = "";
//   static String location = "";
//   static String mod = "";
//   static String status = "";
//   static String studentNotes = "";
//   static String timeslot = "";
//   static List dates = [];

//   static CollectionReference consult = FirebaseFirestore.instance.collection('consults');

//   static Future<void> getAllConsults() async{
//     // completed.clear();
//     // scheduled.clear();
//     // pending.clear();
//     QuerySnapshot qs = await consult.get();

//     for (int i=0;i<qs.docs.length;i++){
//       DocumentSnapshot doc = qs.docs[i];
//       Map<String, dynamic> consultInfo = doc.data() as Map<String,dynamic>;


//       if(consultInfo['status'].equalsTo("completed")){
//         completed.add(consults(consultInfo['lecturer'], consultInfo['lecturer_notes'], consultInfo['location'], 
//         consultInfo['module'], consultInfo['status'], consultInfo['student'], consultInfo['student_notes'], 
//         consultInfo['timeslot'], consultInfo['date']
//         ));

//       } else if(consultInfo['status'] == 'scheduled'){
//         completed.add(consults(consultInfo['lecturer'], consultInfo['lecturer_notes'], consultInfo['location'], 
//         consultInfo['module'], consultInfo['status'], consultInfo['student'], consultInfo['student_notes'], 
//         consultInfo['timeslot'], consultInfo['date']
//         ));

//       } else if(consultInfo['status'] == 'pending'){
//         completed.add(consults(consultInfo['lecturer'], consultInfo['lecturer_notes'], consultInfo['location'], 
//         consultInfo['module'], consultInfo['status'], consultInfo['student'], consultInfo['student_notes'], 
//         consultInfo['timeslot'], consultInfo['date']
//         ));

//       }
      
      
//     }

//     print(scheduled);
//     print(pending);


//   }

//   static consults getComplete(int index){
//     return (completed[index]);
//   }

//   static consults getScheduled(int index){
//     return (scheduled[index]);
//   }

//   static consults getPending(int index){
//     return (pending[index]);
//   }

// }