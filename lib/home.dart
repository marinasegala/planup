import 'package:flutter/material.dart';
import 'create_travel.dart';

import 'package:planup/db/travel_db.dart';
import 'package:planup/model/travel.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePage();
}

class _HomePage extends State<Home> {

  late List<Travel> travel;
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    refreshTravel();
  }

  @override
  void dispose(){
    TravelDatabase.instance.close();
    super.dispose();
  }

  Future refreshTravel() async{
    setState(() => isLoading = true);
    this.travel = await TravelDatabase.instance.readAll();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I tuoi viaggi'),
        actions: [Icon(Icons.search), SizedBox(width: 12)],
      ),
      // body: const Center(child: Text('Press the + button below!')),
      body: Center(
        child: isLoading
          ? CircularProgressIndicator()
          : travel.isEmpty
          ? Text('No Travel', style: TextStyle(color: Colors.white, fontSize: 24))
          : buildTravel(),
        ),
      
      // // An example of the floating action button.
      // //
      // // https://m3.material.io/components/floating-action-button/specs

      // floatingActionButton: FloatingActionButton(
        
      //   onPressed: () {
      //     // Add your onPressed code here!
      //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     //                 content: Text('Text button is pressed')));
      //     // const New();
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const CreateTravelPage()),
      //     );
      //   },
      //   backgroundColor: const Color.fromARGB(255, 255, 217, 104),
      //   foregroundColor: Colors.black,
      //   child: const Icon(Icons.add),
      // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditNotePage())
            );
            refreshTravel();
          },
          backgroundColor: Colors.black,
          child: Icon(Icons.add),
        ),
    );
  }

  Widget buildTravel() => StaggeredGridView.countBuilder(
    padding: EdgeInsets.all(8),
    itemCount: travel.length,
    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    crossAxisCount: 4,
    crossAxisSpacing: 4,
    itemBuilder: (context, index) {
      final trav = travel[index];

      return GestureDetector(
        onTap: () async{
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Delate(id: travel.id!),
          ));
        }
      )
    },
  );
  
}
