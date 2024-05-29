import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // Liste pour stocker les séries de données à afficher dans le graphique
  List<charts.Series<YearlyValue, String>> _seriesLineData = [];

  // Méthode pour générer les données pour le graphique à partir des données de Firestore
  _generateData(List<YearlyValue> data) {
    // Création d'une série de données pour le graphique
    _seriesLineData.add(
      charts.Series(
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        id: 'Value',
        data: data,
        domainFn: (YearlyValue value, _) => value.year.toString(),
        measureFn: (YearlyValue value, _) => value.totalValue,
      ),
    );
  }

  // Méthode asynchrone pour récupérer et préparer les données de Firestore
  Future<List<YearlyValue>> _fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('coins').get();
    Map<int, double> yearlyValues = {};

    // Parcours de chaque document dans la collection 'coins'
    querySnapshot.docs.forEach((doc) {
      int year = doc['year'];
      double value = doc['value'];
      // Mise à jour de la map avec la valeur totale pour chaque année
      yearlyValues.update(year, (existingValue) => existingValue + value, ifAbsent: () => value);
    });

    // Conversion de la map en une liste de YearlyValue et tri par année
    List<YearlyValue> data = yearlyValues.entries
        .map((entry) => YearlyValue(year: entry.key, totalValue: entry.value))
        .toList();

    data.sort((a, b) => a.year.compareTo(b.year));
    return data;
  }

  @override
  void initState() {
    super.initState();
    // Récupération des données et génération des séries de données pour le graphique
    _fetchData().then((data) {
      setState(() {
        _generateData(data); // Génère les données pour le graphique avec les données récupérées
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Evolution de la Valeur Totale',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: _seriesLineData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.BarChart(
          _seriesLineData, // Données à afficher dans le graphique
          animate: true,
          animationDuration: Duration(seconds: 2),
          domainAxis: const charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelRotation: 60,
            ),
          ),
          behaviors: [
            charts.ChartTitle('Année',
                behaviorPosition: charts.BehaviorPosition.bottom,
                titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
            charts.ChartTitle('Valeur Totale',
                behaviorPosition: charts.BehaviorPosition.start,
                titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
          ],
        ),
      ),
    );
  }
}

// Classe représentant les données de valeur annuelle
class YearlyValue {
  final int year;
  final double totalValue;

  YearlyValue({required this.year, required this.totalValue});
}