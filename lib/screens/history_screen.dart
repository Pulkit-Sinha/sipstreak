import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/water_tracking_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<DateTime, double> historyData = {};
  bool isLoading = true;
  int selectedDays = 7;
  double weeklyAverage = 0.0;
  double monthlyAverage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() => isLoading = true);
    
    final [history, weekly, monthly] = await Future.wait([
      WaterTrackingService.getHistoryData(selectedDays),
      WaterTrackingService.getWeeklyAverage(),
      WaterTrackingService.getMonthlyAverage(),
    ]);
    
    setState(() {
      historyData = history as Map<DateTime, double>;
      weeklyAverage = weekly as double;
      monthlyAverage = monthly as double;
      isLoading = false;
    });
  }

  List<FlSpot> _getChartData() {
    if (historyData.isEmpty) return [];
    
    final sortedEntries = historyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value / 1000); // Convert to liters
    }).toList();
  }

  String _formatDate(DateTime date) {
    if (selectedDays <= 7) {
      return DateFormat('E').format(date); // Mon, Tue, etc.
    } else {
      return DateFormat('M/d').format(date); // 1/15, 1/16, etc.
    }
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake History'),
        backgroundColor: Colors.lightBlue.shade600,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune, color: Colors.white),
            onSelected: (days) {
              setState(() {
                selectedDays = days;
              });
              _loadHistoryData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 14, child: Text('Last 2 weeks')),
              const PopupMenuItem(value: 30, child: Text('Last month')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time period selector
                  Text(
                    'Showing last ${selectedDays == 7 ? "week" : selectedDays == 14 ? "2 weeks" : "month"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlue.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics cards
                  Row(
                    children: [
                      _buildStatCard(
                        'WEEKLY AVG',
                        '${(weeklyAverage / 1000).toStringAsFixed(1)}L',
                        'per day',
                        Icons.trending_up,
                        Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        'MONTHLY AVG',
                        '${(monthlyAverage / 1000).toStringAsFixed(1)}L',
                        'per day',
                        Icons.calendar_month,
                        Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        'BEST DAY',
                        historyData.isNotEmpty
                            ? '${(historyData.values.reduce((a, b) => a > b ? a : b) / 1000).toStringAsFixed(1)}L'
                            : '0L',
                        'peak intake',
                        Icons.star,
                        Colors.orange.shade600,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Chart
                  Text(
                    'Daily Water Intake',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlue.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: historyData.isEmpty
                        ? const Center(
                            child: Text(
                              'No data available\nStart tracking your water intake!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < historyData.length) {
                                        final date = historyData.keys.elementAt(index);
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            _formatDate(date),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      return Text(
                                        '${value.toInt()}L',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                    reservedSize: 42,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: (historyData.length - 1).toDouble(),
                              minY: 0,
                              maxY: historyData.isNotEmpty 
                                  ? (historyData.values.reduce((a, b) => a > b ? a : b) / 1000 * 1.2)
                                  : 4,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getChartData(),
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightBlue.shade400,
                                      Colors.lightBlue.shade600,
                                    ],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.lightBlue.shade600,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.lightBlue.shade200.withOpacity(0.3),
                                        Colors.lightBlue.shade100.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Recent days summary
                  Text(
                    'Recent Days',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...historyData.entries.toList().reversed.take(5).map((entry) {
                    final date = entry.key;
                    final intake = entry.value;
                    final isToday = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.water_drop,
                            color: Colors.lightBlue.shade600,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isToday ? 'Today' : DateFormat('EEEE, MMM d').format(date),
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text('${(intake / 1000).toStringAsFixed(1)}L consumed'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: intake >= 2000 ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            intake >= 2000 ? 'Goal Met' : 'Needs More',
                            style: TextStyle(
                              color: intake >= 2000 ? Colors.green.shade700 : Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}