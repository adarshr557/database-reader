import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_tester/model/user_details_model.dart';

class DataProvider extends ChangeNotifier {
  late String fetchedname;
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController housenamecontroller = TextEditingController();
  TextEditingController Streetcontroller = TextEditingController();

  void restfieald() {
    usernamecontroller.clear();
    passcontroller.clear();
    agecontroller.clear();
    housenamecontroller.clear();
    Streetcontroller.clear();
    notifyListeners();
  }

  //databse services
  //Firestore irebase services
  List<UserDetails> detailedList = [];
  List<Address> nestedList = [];
  final CollectionReference dataRetriver =
      FirebaseFirestore.instance.collection('userDetails');
  final CollectionReference subcollect =
      FirebaseFirestore.instance // is it used here ?
          .collection('userDetails')
          .doc()
          .collection('address');

//CRUD
// create new user !
  Future<void> createNewuser(String Username, String pass, int age,
      String HouseName, String Street) async {
    var docid = dataRetriver.doc().id;
    try {
      notifyListeners();
      await dataRetriver.doc(docid).set({
        'username': Username,
        'password': pass,
        'age': age,
      }).then((value) async {
        notifyListeners();
        loaddetails();
        //sub collection adding to database
        await dataRetriver
            .doc(docid)
            .collection('address')
            .add({'HouseName': HouseName, 'Street': Street}).then((value) {
          notifyListeners();
          loadaddress(Username);
        });
      });
      // print('Sub collection added to Firestore');

      print('New user document added to Firestore');
    } catch (e) {
      notifyListeners();
      print('Error adding new user document: $e');
    }
  }

  //Update the user data
  Future<void> UpdateUserAddress(
      {required String name,
      required String Housename,
      required String Street}) async {
    try {
      notifyListeners();
      QuerySnapshot querySnapshot =
          await dataRetriver.where('username', isEqualTo: name).get();
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the first (and usually only) matching document
        var docid = querySnapshot.docs[0].id;

        final snapshot = await FirebaseFirestore.instance
            .collection('userDetails')
            .doc(docid) // Use the retrieved document ID here
            .collection('address')
            .get();
        for (DocumentSnapshot documentSnapshot in snapshot.docs) {
          documentSnapshot.reference
              .update({'HouseName': Housename, 'Street': Street}).then((value) {
            loaddetails();
            notifyListeners();
          });
        }
      }

      print('The ${name} "s Address is updated');
    } catch (error) {
      print('The ${name} "s Address is not updated');
      print(error);
    }
  }

  //delete userdata from database
  Future<void> deleteUser({required String? name}) async {
    try {
      notifyListeners();
      QuerySnapshot querySnapshot =
          await dataRetriver.where('username', isEqualTo: name).get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        documentSnapshot.reference.delete().then((value) {
          loaddetails();
          notifyListeners();
        });
      }
      print('The ${name} is removed from the databse');
    } catch (error) {
      print('The ${name} is not removed from the databse');
      print(error);
    }
  }

  //user details loader
  void DetailsLoaderH() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loaddetails();
      notifyListeners();
    });
  }

  Future<void> loaddetails() async {
    try {
      notifyListeners();
      // final snapshot = dataRetriver.get(); is it works??
      final snapshot =
          await FirebaseFirestore.instance.collection('userDetails').get();
      // print('check here${snapshot.docs.length}');
      final userDetails =
          snapshot.docs.map((doc) => UserDetails.fromJson(doc.data())).toList();
      //print('noobtest${userDetails[0]}');
      detailedList = userDetails;
      // print('boomerang ${detailedList[0]}');

      // print('jobb ${userDetails.length}');
      if (detailedList.isEmpty) {
        print('List is empty');
        Text('The List Is empty');
        notifyListeners();
      }
    } catch (error) {
      print(error);
    }
    notifyListeners();
  }

  // address loader
  void AddressLoader(String Username) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadaddress(Username);
      notifyListeners();
    });
  }

  Future<void> loadaddress(String Fetchedusername) async {
    try {
      notifyListeners();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userDetails')
          .where("username", isEqualTo: Fetchedusername)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the document ID of the first (and usually only) matching document
        var docid = querySnapshot.docs[0].id;

        final snapshot = await FirebaseFirestore.instance
            .collection('userDetails')
            .doc(docid) // Use the retrieved document ID here
            .collection('address')
            .get();

        final userAddress =
            snapshot.docs.map((doc) => Address.fromJson(doc.data())).toList();
        nestedList = userAddress;

        if (nestedList.isEmpty) {
          print('List is empty');
          Text('The List Is empty');
          notifyListeners();
        }
      } else {
        // if  no matching documents were found
        print('No matching documents found.');
      }
    } catch (error) {
      print('error Loading the data');
    }
    notifyListeners();
  }
}
