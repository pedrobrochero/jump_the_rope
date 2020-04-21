
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:jump_the_rope/data/models/session_model.dart';
import 'package:jump_the_rope/providers/firestore.dart';
import 'package:jump_the_rope/utils/datetime_utils.dart';

class GraphBarWidget extends StatelessWidget {

  final Stream stream;
  final Color _color;

  GraphBarWidget(this.stream, this._color);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        if (snapshot.data.documents.length == 0) return Center(child: Text('No hay informacion para mostrar.', style: TextStyle(color: Colors.black54, fontSize: 12)),heightFactor: 2,);

        final data = List<SessionModel>();
        snapshot.data.documents.forEach((doc) {
          final session = SessionModel( 
            date: doc['date'].toDate(),
            rounds: doc['rounds'],
            id: doc.documentID
          );
          data.add(session);
        });

        List<charts.Series<SessionModel, String>> series = [
          charts.Series<SessionModel, String>(
            id: 'DailySessions',
            colorFn: (_, __) => charts.ColorUtil.fromDartColor(_color).lighter,
            domainFn: (value, _) => value.shortDate(),
            measureFn: (value, _) => value.getTotal(),
            data: data,
            labelAccessorFn: (value, _) => value.getTotal().toString(),
          )
        ];

        return charts.BarChart(
          series,
          animate: true,
          domainAxis: charts.OrdinalAxisSpec(
            viewport: charts.OrdinalViewport(
              DateTimeUtils.dateToString(DateTime.now()).substring(5),5)
          ),
          behaviors: [
            charts.SlidingViewport(),
            charts.PanAndZoomBehavior(),
            charts.InitialSelection(selectedDataConfig: [
              charts.SeriesDatumConfig<String>('DailySessions', DateTimeUtils.dateToString(DateTime.now()).substring(5))
            ])
          ],
          barRendererDecorator: charts.BarLabelDecorator<String>()
        );

      },
    );
  }
}