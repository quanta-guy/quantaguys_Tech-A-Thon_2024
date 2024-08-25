import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(StockPredictionApp());

class StockPredictionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Prediction App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockPredictionPage(),
    );
  }
}

class StockPredictionPage extends StatefulWidget {
  @override
  _StockPredictionPageState createState() => _StockPredictionPageState();
}

class _StockPredictionPageState extends State<StockPredictionPage> {
  String? _selectedTicker;
  String _predictionText = '';
  Color _predictionColor = Colors.black;
  double _percentageChange = 0.0;
  double _currentPrice = 0.0; // Variable to hold the current price
  int _forecastingPeriod = 30; // Default forecasting period is 30 days
  List<ChartData> _chartData = [];
  List<ChartData> _truePriceData = [];
  bool _isLoading = false; // Loading state

  final List<String> _tickers = ['AAPL', 'GOOG', 'TSLA', 'AMZN', 'MSFT'];

  void _fetchStockData() async {
    if (_selectedTicker == null) return;

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    final response = await http.post(
      Uri.parse(
          'http://192.168.29.20:8000/stock/$_selectedTicker?forecasting_period=$_forecastingPeriod'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('API Response: $data'); // Debugging output

      final historicalPrices = data['historical_prices'] as List<dynamic>?;
      final predictedPrices = data['predicted_prices'] as List<dynamic>?;

      if (historicalPrices == null || predictedPrices == null) {
        setState(() {
          _predictionText = 'Error: Data not available';
          _predictionColor = Colors.red;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _chartData = [];
        _truePriceData = [];
        _currentPrice = data['current_price'] ?? 0.0; // Set the current price

        // Add historical prices (true prices)
        for (int i = 0; i < historicalPrices.length; i++) {
          _truePriceData
              .add(ChartData(i.toDouble(), historicalPrices[i].toDouble()));
        }

        // Add predicted prices starting from the end of the true prices
        for (int i = 0; i < predictedPrices.length; i++) {
          _chartData.add(ChartData((_truePriceData.length + i).toDouble(),
              predictedPrices[i].toDouble()));
        }

        final prediction = data['prediction'];
        _predictionText = prediction == 'CALL' ? 'CALL' : 'SELL';
        _predictionColor = prediction == 'CALL' ? Colors.green : Colors.red;

        // Calculate percentage change
        double futurePrice = predictedPrices.last;
        _percentageChange =
            ((futurePrice - _currentPrice) / _currentPrice) * 100;
        _isLoading = false; // Set loading state to false after data is loaded
      });
    } else {
      setState(() {
        _predictionText = 'Error fetching data';
        _predictionColor = Colors.red;
        _percentageChange = 0.0; // Reset percentage change on error
        _isLoading = false; // Set loading state to false on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Prediction'),
      ),
      body: SingleChildScrollView(
        // Enable vertical scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Stock Ticker',
                  border: OutlineInputBorder(),
                ),
                items: _tickers.map((String ticker) {
                  return DropdownMenuItem<String>(
                    value: ticker,
                    child: Text(ticker),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTicker = value;
                  });
                  _fetchStockData();
                },
                value: _selectedTicker,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Forecasting Period: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: Slider(
                      value: _forecastingPeriod.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: _forecastingPeriod.toString(),
                      onChanged: (value) {
                        setState(() {
                          _forecastingPeriod = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text(
                    '$_forecastingPeriod days',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Current Price: \$${_currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _predictionText,
                style: TextStyle(
                  color: _predictionColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Percentage Change: ${_percentageChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: _percentageChange >= 0 ? Colors.green : Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator while data is being processed
                  : SfCartesianChart(
                      primaryXAxis: NumericAxis(
                        title: AxisTitle(text: 'Days'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Stock Price'),
                      ),
                      series: <ChartSeries>[
                        LineSeries<ChartData, double>(
                          name: 'True Prices',
                          dataSource: _truePriceData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y1,
                          color: Colors.blue,
                        ),
                        LineSeries<ChartData, double>(
                          name: 'Predicted Prices',
                          dataSource: _chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y1,
                          color: Colors.red,
                        ),
                      ],
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y1;

  ChartData(this.x, this.y1);
}
