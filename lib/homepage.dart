import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          
          children: [
            const Padding(padding: EdgeInsetsGeometry.all(10)),
            const Text(
              'Welcome Mark!', //add variable here for name from firebase
              style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5,),

            const Text('What would you like to do today?', style: TextStyle(fontSize: 15),),

            const SizedBox(height: 30,),


             Expanded(
              child: InkWell(
                onTap: () {
                 // Navigator.push(context, MaterialPageRoute(builder: builder))
                  Navigator.pushNamed(context, '/newConsult1');

                },
                splashColor: Colors.black26,
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ink.image(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/img/consults.png'),
                    height: 200,
                    width: 500,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstIn),
                    
                  ),

                  Text('Book a new consultation', style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
                  
                  ]
                ),
              
              ),
            ),

            SizedBox(height: 20,),           

            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/scheduleStudent');
                },
                splashColor: Colors.black26,
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ink.image(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/img/schedule.png'),
                    height: 200,
                    width: 500,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstIn),
                    
                  ),

                  Text('View scheduled consultations', style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
                  
                  ]
                ),
              
              ),
            ),

            SizedBox(height: 50,)



          
          ],
        ),
      ),
    );
  }
}