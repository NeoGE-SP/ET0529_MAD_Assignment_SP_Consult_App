import 'package:cloud_firestore/cloud_firestore.dart';


class studentProfile {
  String adm, classNo, email, name;

  studentProfile(this.adm, this.classNo, this.email, this.name);
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

      z.add(
        studentProfile(
          studentInfo['adm'],
          studentInfo['class'],
          studentInfo['email'],
          studentInfo['name'],
        ),
      );
    }
  }

  static studentProfile getProfileAt(int index) {
    return z[index];
  }
}

class lectureProfile {
  String staffID, email, name;

  lectureProfile(this.staffID, this.email, this.name);
}

class lectureProfile_Service {


  static List<lectureProfile> z = [];

  static CollectionReference lectureData =
      FirebaseFirestore.instance.collection('lecturers');

  static Future<void> getAllStudents() async {
    z.clear();

    QuerySnapshot qs = await lectureData.get();

    for (var doc in qs.docs) {
      final lectureInfo = doc.data() as Map<String, dynamic>;

      z.add(
        lectureProfile(
          lectureInfo['adm'],
          lectureInfo['name'],
          lectureInfo['email'],
        ),
      );
    }
  }

  static lectureProfile getProfileAt(int index) {
    return z[index];
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