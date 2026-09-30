import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bmi_calculator_model.dart';

class BMICalculatorView extends StatefulWidget {
  const BMICalculatorView({super.key});

  @override
  State<BMICalculatorView> createState() => _BMICalculatorViewState();
}

class _BMICalculatorViewState extends State<BMICalculatorView> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isMetric = true;

  double? _bmiResult;
  String _resultText = '';
  String _interpretation = '';

  Color _getStatusColor() {
    if (_bmiResult == null) return Colors.blueGrey.shade200;

    switch (_resultText.toLowerCase()) {
      case 'normal':
        return const Color(0xFF2ECC71);
      case 'overweight':
      case 'sobrepeso':
        return const Color(0xFFF39C12);
      case 'underweight':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFFE74C3C);
    }
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0 && weight > 0) {
      final calculator = BMICalculatorModel(
        height: height,
        weight: weight,
        isMetric: _isMetric,
      );

      setState(() {
        _bmiResult = calculator.calculateBMI();
        _resultText = calculator.getResult(_bmiResult!);
        _interpretation = calculator.getInterpretation(_bmiResult!);
      });
    } else {
      _showSnackBar('Please enter valid numbers for height and weight.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentStatusColor = _getStatusColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Metric (cm/kg)'),
                              icon: Icon(Icons.square_foot_rounded, size: 18),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Imperial (in/lbs)'),
                              icon: Icon(Icons.straighten_rounded, size: 18),
                            ),
                          ],
                          selected: {_isMetric},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              _isMetric = newSelection.first;
                              _heightController.clear();
                              _weightController.clear();
                              _bmiResult = null;
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: const Color(0xFF8BB7C1),
                            selectedForegroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _heightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(5),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Height',
                                  suffixText: _isMetric ? 'cm' : 'inches',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F3F6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.accessibility_new_rounded,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(5),
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Weight',
                                  suffixText: _isMetric ? 'kg' : 'lbs',
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F3F6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.monitor_weight_rounded,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8BB7C1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Calculate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: _bmiResult != null ? 1.0 : 0.0,
                          child: _bmiResult == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32.0,
                                      horizontal: 24.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: currentStatusColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _resultText,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: currentStatusColor,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _bmiResult?.toStringAsFixed(1) ?? '',
                                          style: const TextStyle(
                                            fontSize: 72,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF2D3436),
                                            height: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _interpretation,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
