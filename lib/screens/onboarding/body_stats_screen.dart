import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BodyStatsScreen extends StatefulWidget {
  final Function(double, double) onNext;
  
  const BodyStatsScreen({super.key, required this.onNext});

  @override
  State<BodyStatsScreen> createState() => _BodyStatsScreenState();
}

class _BodyStatsScreenState extends State<BodyStatsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  bool _useImperialWeight = false;
  bool _useImperialHeight = false;
  
  double _getWeightInKg() {
    final weight = double.parse(_weightController.text);
    return _useImperialWeight ? weight * 0.453592 : weight;
  }
  
  double _getHeightInCm() {
    final height = double.parse(_heightController.text);
    return _useImperialHeight ? height * 2.54 : height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Your measurements",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Your height and weight help calculate your ideal water intake",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: "Weight",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monitor_weight),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Required";
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return "Invalid weight";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("kg"),
                      selected: !_useImperialWeight,
                      onSelected: (selected) {
                        setState(() {
                          _useImperialWeight = !selected;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("lbs"),
                      selected: _useImperialWeight,
                      onSelected: (selected) {
                        setState(() {
                          _useImperialWeight = selected;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: "Height",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Required";
                          }
                          final height = double.tryParse(value);
                          if (height == null || height <= 0) {
                            return "Invalid height";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text("cm"),
                      selected: !_useImperialHeight,
                      onSelected: (selected) {
                        setState(() {
                          _useImperialHeight = !selected;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("in"),
                      selected: _useImperialHeight,
                      onSelected: (selected) {
                        setState(() {
                          _useImperialHeight = selected;
                        });
                      },
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onNext(_getWeightInKg(), _getHeightInCm());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Next", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 