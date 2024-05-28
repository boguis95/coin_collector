import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<charts.Series<YearlyValue, String>> _seriesLineData = [];

  _generateData(List<YearlyValue> data) {
    _seriesLineData.add(
      charts.Series(
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        id: 'Value',
        data: data,
        domainFn: (YearlyValue value, _) => value.year.toString(), // Utiliser l'année comme domaine (x-axis)
        measureFn: (YearlyValue value, _) => value.totalValue, // Utiliser la valeur totale comme mesure (y-axis)
      ),
    );
  }

  Future<List<YearlyValue>> _fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('coins').get();
    Map<int, double> yearlyValues = {};

    querySnapshot.docs.forEach((doc) {
      int year = doc['year'];
      double value = doc['value'];
      yearlyValues.update(year, (existingValue) => existingValue + value, ifAbsent: () => value);
    });

    List<YearlyValue> data = yearlyValues.entries
        .map((entry) => YearlyValue(year: entry.key, totalValue: entry.value))
        .toList();

    data.sort((a, b) => a.year.compareTo(b.year));
    return data;
  }

  @override
  void initState() {
    super.initState();
    _fetchData().then((data) {
      setState(() {
        _generateData(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolution de la Valeur Totale',
              style: TextStyle(color: Colors.black87),),
      ),
      body: _seriesLineData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.BarChart(
          _seriesLineData,
          animate: true,
          animationDuration: Duration(seconds: 2),
          domainAxis: const charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelRotation: 60, // Rotation des labels pour une meilleure lisibilité
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

class YearlyValue {
  final int year;
  final double totalValue;

  YearlyValue({required this.year, required this.totalValue});
}