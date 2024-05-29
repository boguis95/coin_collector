import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddCoinScreen.dart';
import 'ChartScreen.dart';

class CoinListScreen extends StatelessWidget {
  // Référence à la collection 'coins' dans Firestore
  final CollectionReference coins = FirebaseFirestore.instance.collection('coins');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 35.0),
            child: Text(
              'CoinCollector',
              style: TextStyle(color: Colors.black87), // Couleur du texte du titre
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.blue), // Icône de l'action
            onPressed: () {
              // Navigation vers l'écran ChartScreen lorsqu'on appuie sur l'icône
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChartScreen()),
              );
            },
          ),
        ],
      ),
      // Corps de l'écran utilisant un StreamBuilder pour écouter les changements dans Firestore
      body: StreamBuilder(
        stream: coins.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Construit une ListView des pièces de monnaie
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                elevation: 0.65,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  leading: doc['image_url'] != null && doc['image_url'].isNotEmpty
                  // Affiche l'image de la pièce si une URL d'image est disponible
                      ? Image.network(doc['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  // Affiche l'année de la pièce
                  title: Text(
                    doc['year'].toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  // Affiche la rareté, la quantité et la valeur de la pièce
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
      // Bouton flottant pour ajouter une nouvelle pièce
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran AddCoinScreen lorsqu'on appuie sur le bouton
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