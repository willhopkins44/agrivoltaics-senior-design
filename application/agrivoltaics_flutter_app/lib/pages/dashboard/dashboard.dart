import 'dart:async';

import 'package:agrivoltaics_flutter_app/app_constants.dart';
import 'package:agrivoltaics_flutter_app/app_state.dart';
import 'package:agrivoltaics_flutter_app/influx.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_appbar.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_drawer.dart';
import 'package:agrivoltaics_flutter_app/pages/dashboard/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:influxdb_client/api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/*

Dashboard Page
- Page containing Dashboard related widgets

*/
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key, required this.site});
  int site;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardState(site),
      child: SafeArea(
        child: Scaffold(
          endDrawer: DashboardDrawer(),
          appBar: DashboardAppBar(),
          body: Dashboard()
        ),
      ),
    );
  }
}

/*

Dashboard
- Skeleton for nested graph-related widgets
- Extracted nested graph widget due to its size and complexity

*/
class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: DashboardGraph()
          ),
        ),
      ],
    );
  }
}

/*

Dashboard Graph
- Main Dashboard widget which displays relevant information in graph form

*/
class DashboardGraph extends StatefulWidget {
  const DashboardGraph({
    super.key,
  });

  @override
  State<DashboardGraph> createState() => _DashboardGraphState();
}

class _DashboardGraphState extends State<DashboardGraph> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return Consumer<DashboardState>(
      builder: (context, dashboardState, child) {
        // Refresh widget according to dashboard state's time interval (real-time data)
        Timer.periodic(dashboardState.timeInterval.duration!, (Timer t) => {if (this.mounted) setState((){})});
        return FutureBuilder<Map<String, List<FluxRecord>>>(
          // Async method called by FutureBuilder widget, whose results will eventually populate widget
          future: getInfluxData
          (
            dashboardState.siteSelection,
            dashboardState.zoneSelection,
            dashboardState.fieldSelection,
            dashboardState.dateRangeSelection,
            dashboardState.timeInterval
          ),

          builder: (BuildContext context, AsyncSnapshot<Map<String, List<FluxRecord>>> snapshot) {
            // Once the data snapshot is populated with above method results, render chart
            if (snapshot.hasData) {
              return SfCartesianChart(
                title: ChartTitle(text: 'Site ${dashboardState.siteSelection}'),
                legend: Legend(isVisible: true),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipSettings: const InteractiveTooltip(
                    enable: true,
                    format: 'series.name\npoint.y | point.x',
                    borderWidth: 20
                  )
                ),
                primaryXAxis: CategoryAxis(),
                palette: const [
                  Colors.blue,
                  Colors.green,
                  Colors.grey,
                  Colors.blueGrey
                ],
                series: <LineSeries<InfluxDatapoint, String>>[
                  for (var data in snapshot.data!.entries)...[
                    LineSeries<InfluxDatapoint, String>(
                      // dataSource: InfluxData(data.value, appState.timezone).data,
                      dataSource: InfluxData(data, appState.timezone).datapoints,
                      xValueMapper: (InfluxDatapoint d, _) => d.timeStamp,
                      yValueMapper: (InfluxDatapoint d, _) => d.value,
                      legendItemText: data.key,
                      name: data.key
                    )
                  ]
                ],
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true
                ),
              );
            } else {
              // The results have not yet been returned. Indicate loading
              return const CircularProgressIndicator();
            }
          },
        );
      }
    );
  }
}

// class BarIndicator extends StatelessWidget {
//   const BarIndicator({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         width: 40, height: 3,
//         decoration: const BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//         ),
//       ),
//     );
//   }
// }