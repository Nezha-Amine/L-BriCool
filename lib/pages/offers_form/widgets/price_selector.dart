import 'package:flutter/material.dart';

class PriceSelector extends StatefulWidget {
  final double initialPrice;
  final Function(double) onPriceChanged;

  const PriceSelector({
    Key? key,
    required this.initialPrice,
    required this.onPriceChanged,
  }) : super(key: key);

  @override
  _PriceSelectorState createState() => _PriceSelectorState();
}

class _PriceSelectorState extends State<PriceSelector> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.initialPrice.toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Starting at: ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10),
        Icon(
          Icons.attach_money,
          color: Color(0xFF4527A0),
        ),
        SizedBox(width: 5),
        Container(
          width: 80,
          child: TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '100',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                try {
                  final price = double.parse(value);
                  widget.onPriceChanged(price);
                } catch (e) {
                  // Handle invalid input
                }
              }
            },
          ),
        ),
        Text('DH/h', style: TextStyle(color: Color(0xFF4527A0), fontWeight: FontWeight.bold)),
      ],
    );
  }
}