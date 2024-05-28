import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AddCoinScreen.dart';
import 'ChartScreen.dart';


class CoinListScreen extends StatelessWidget {
  final CollectionReference coins = FirebaseFirestore.instance.collection('coins');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 35.0),
            child: Text('CoinCollector',
            style: TextStyle(color: Colors.black87),),
          ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.blue,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChartScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: coins.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                elevation: 0.65,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  leading: doc['image_url'] != null && doc['image_url'].isNotEmpty
                      ? Image.network(doc['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  title: Text(
                    doc['year'].toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  subtitle: Text(
                    'Rareté: ${doc['rarity']}, Quantité: ${doc['quantity']}, Valeur: \$${doc['value']}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCoinScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}