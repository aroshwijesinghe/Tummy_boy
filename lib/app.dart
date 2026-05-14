import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'services/pushup_service.dart';

class TummyBoyApp extends StatefulWidget {
  const TummyBoyApp({super.key});

  @override
  State<TummyBoyApp> createState() => _TummyBoyAppState();
}

class _TummyBoyAppState extends State<TummyBoyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDark = await PushupService.getDarkModeEnabled();
    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
      });
    }
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await PushupService.setDarkModeEnabled(_isDarkMode);
  }

  ThemeData _buildLightTheme() {
    const seed = Color(0xFF0A8F72);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF3FBF8),
      cardTheme: const CardThemeData(
        elevation: 3,
        margin: EdgeInsets.zero,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const seed = Color(0xFF2DD4BF);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF061612),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tummy Boy Fitness',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: PushupCounterPage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class PushupCounterPage extends StatefulWidget {
  const PushupCounterPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<PushupCounterPage> createState() => _PushupCounterPageState();
}

class _PushupCounterPageState extends State<PushupCounterPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tummy Boy Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Light' : 'Switch to Dark',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF0C2E2A), Color(0xFF081A17)]
                  : const [Color(0xFF4FD1C5), Color(0xFF0EA5A0)],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: const [
          HomeTab(),
          StatisticsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Progress'),
        ],
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _todayCount = 0;
  double _todayDistance = 0;

  final TextEditingController _pushupController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    final now = DateTime.now();
    final count = await PushupService.getPushupCount(now);
    final distance = await PushupService.getRunDistance(now);
    if (!mounted) return;
    setState(() {
      _todayCount = count;
      _todayDistance = distance;
    });
  }

  Future<void> _incrementCount() async {
    await PushupService.incrementPushupCount(DateTime.now());
    await _loadTodayData();
  }

  Future<void> _resetToday() async {
    final now = DateTime.now();
    await PushupService.resetPushupCount(now);
    await PushupService.setRunDistance(now, 0);
    await _loadTodayData();
  }

  Future<void> _showTodayPushupDialog() async {
    _pushupController.text = _todayCount.toString();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Today Pushups'),
        content: TextField(
          controller: _pushupController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter count',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final count = int.tryParse(_pushupController.text.trim());
              if (count == null || count < 0) return;
              await PushupService.setPushupCount(DateTime.now(), count);
              await _loadTodayData();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTodayRunDialog() async {
    _distanceController.text = _todayDistance.toStringAsFixed(2);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Today Run Distance (km)'),
        content: TextField(
          controller: _distanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'e.g. 2.5',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final distance = double.tryParse(_distanceController.text.trim());
              if (distance == null || distance < 0) return;
              await PushupService.setRunDistance(DateTime.now(), distance);
              await _loadTodayData();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPastDayEditor() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;

    final existingPushups = await PushupService.getPushupCount(picked);
    final existingDistance = await PushupService.getRunDistance(picked);
    _pushupController.text = existingPushups.toString();
    _distanceController.text = existingDistance.toStringAsFixed(2);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${picked.day}/${picked.month}/${picked.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pushupController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pushups',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Run Distance (km)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final pushups = int.tryParse(_pushupController.text.trim());
              final distance = double.tryParse(_distanceController.text.trim());
              if (pushups == null || pushups < 0 || distance == null || distance < 0) return;

              await PushupService.setPushupCount(picked, pushups);
              await PushupService.setRunDistance(picked, distance);
              await _loadTodayData();

              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save Day'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF071F1B), Color(0xFF02100E)]
              : const [Color(0xFFE8FFFA), Color(0xFFF6FCFF)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const Text('Today\'s Pushups', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildPushupCircle(context),
                const SizedBox(height: 24),
                _buildRunDistanceCard(context),
                const SizedBox(height: 24),
                ElevatedButton.icon(onPressed: _incrementCount, icon: const Icon(Icons.add), label: const Text('Add Pushup')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _showTodayPushupDialog, icon: const Icon(Icons.edit), label: const Text('Edit Today Pushups')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _showTodayRunDialog, icon: const Icon(Icons.directions_run), label: const Text('Edit Today Distance')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _showPastDayEditor, icon: const Icon(Icons.calendar_month), label: const Text('Add/Edit Past Day')),
                const SizedBox(height: 10),
                TextButton.icon(onPressed: _resetToday, icon: const Icon(Icons.refresh), label: const Text('Reset Today Data')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPushupCircle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 210,
      height: 210,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark ? const [Color(0xFF1EA690), Color(0xFF0A6455)] : const [Color(0xFF2DD4BF), Color(0xFF0E9F8B)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0EA5A0)).withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$_todayCount',
          style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRunDistanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.route, size: 30),
            const SizedBox(width: 14),
            const Expanded(
              child: Text('Distance Ran Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Text('${_todayDistance.toStringAsFixed(2)} km', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pushupController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  late DateTime _selectedWeekStart;
  Map<DateTime, int> _weeklyPushupData = {};
  Map<DateTime, double> _weeklyRunData = {};

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = PushupService.getWeekStart(DateTime.now());
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final pushups = await PushupService.getWeeklyData(_selectedWeekStart);
    final runDistance = await PushupService.getWeeklyRunData(_selectedWeekStart);

    if (!mounted) return;
    setState(() {
      _weeklyPushupData = pushups;
      _weeklyRunData = runDistance;
    });
  }

  void _moveWeek(int deltaDays) {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(Duration(days: deltaDays));
    });
    _loadWeeklyData();
  }

  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}';
  }

  int get _totalWeeklyPushups => _weeklyPushupData.values.fold(0, (sum, count) => sum + count);

  int get _maxWeeklyPushups => _weeklyPushupData.values.isEmpty ? 0 : _weeklyPushupData.values.reduce((a, b) => a > b ? a : b);

  double get _totalWeeklyRunKm => _weeklyRunData.values.fold(0.0, (sum, km) => sum + km);

  double get _maxWeeklyRunKm => _weeklyRunData.values.isEmpty ? 0 : _weeklyRunData.values.reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Week of ${_formatWeekRange(_selectedWeekStart)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(onPressed: () => _moveWeek(-7), icon: const Icon(Icons.arrow_left), label: const Text('Previous')),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedWeekStart = PushupService.getWeekStart(DateTime.now());
                            });
                            _loadWeeklyData();
                          },
                          icon: const Icon(Icons.today),
                          label: const Text('Today'),
                        ),
                        OutlinedButton.icon(onPressed: () => _moveWeek(7), icon: const Icon(Icons.arrow_right), label: const Text('Next')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: StatCard(title: 'Weekly Pushups', value: '$_totalWeeklyPushups', color: Colors.teal)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(title: 'Run Distance', value: '${_totalWeeklyRunKm.toStringAsFixed(2)} km', color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            _buildPushupBarChart(),
            const SizedBox(height: 16),
            _buildRunLineChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPushupBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pushups Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: (_maxWeeklyPushups + 10).toDouble().clamp(10, 10000),
                  barGroups: List.generate(7, (index) {
                    final date = _selectedWeekStart.add(Duration(days: index));
                    final count = _weeklyPushupData[date] ?? 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          width: 16,
                          color: Colors.teal.shade500,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(days[value.toInt()]),
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunLineChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Run Distance Progress (Peak ${_maxWeeklyRunKm.toStringAsFixed(2)} km)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: (_maxWeeklyRunKm + 1).clamp(1, 1000),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue.shade400,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                      spots: List.generate(7, (index) {
                        final date = _selectedWeekStart.add(Duration(days: index));
                        final distance = _weeklyRunData[date] ?? 0;
                        return FlSpot(index.toDouble(), distance);
                      }),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          return idx >= 0 && idx < days.length ? Text(days[idx]) : const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.30), color.withOpacity(0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
