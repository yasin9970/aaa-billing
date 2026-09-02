import 'package:flutter/material.dart';
import '../../database/security_dao.dart';
import '../../utils/colors.dart';
import '../home_nav_screen.dart';

enum PinMode { unlock, setup }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  const PinScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  String _savedPin = '';
  String _tempSetupPin = '';
  bool _isConfirming = false;
  String _title = "Enter Security PIN";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (widget.mode == PinMode.unlock) {
      _savedPin = await SecurityDAO.getPin();
      setState(() => _title = "Enter 4-Digit PIN to Unlock");
    } else {
      setState(() => _title = "Enter New 4-Digit PIN");
    }
  }

  void _onKeyPress(String val) async {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += val);
      if (_enteredPin.length == 4) {
        _handleComplete();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  Future<void> _handleComplete() async {
    if (widget.mode == PinMode.unlock) {
      if (_enteredPin == _savedPin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeNavScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incorrect PIN! Try again.")));
        setState(() => _enteredPin = '');
      }
    } else {
      if (!_isConfirming) {
        _tempSetupPin = _enteredPin;
        setState(() {
          _enteredPin = '';
          _isConfirming = true;
          _title = "Confirm Your 4-Digit PIN";
        });
      } else {
        if (_enteredPin == _tempSetupPin) {
          await SecurityDAO.setPin(_enteredPin, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN Lock Activated!")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PINs do not match! Start over.")));
          setState(() {
            _enteredPin = '';
            _tempSetupPin = '';
            _isConfirming = false;
            _title = "Enter New 4-Digit PIN";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.mode == PinMode.setup ? AppBar(title: const Text("Security PIN")) : null,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(_title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            // 4 Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.primary : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const Spacer(),
            // Numeric Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
              child: Column(
                children: [
                  _numRow(['1', '2', '3']),
                  const SizedBox(height: 14),
                  _numRow(['4', '5', '6']),
                  const SizedBox(height: 14),
                  _numRow(['7', '8', '9']),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 70),
                      _numButton('0'),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: IconButton(
                          icon: const Icon(Icons.backspace_outlined, size: 28),
                          onPressed: _onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _numRow(List<String> nums) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: nums.map((n) => _numButton(n)).toList(),
    );
  }

  Widget _numButton(String val) {
    return InkWell(
      borderRadius: BorderRadius.circular(35),
      onTap: () => _onKeyPress(val),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
        alignment: Alignment.center,
        child: Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
    );
  }
}
