import 'package:flutter/material.dart';

import '../../../controllers/gig_controller.dart';


class AddressSelector extends StatefulWidget {
  final Function(String) onAddressSelected;

  const AddressSelector({
    Key? key,
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  _AddressSelectorState createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  final TextEditingController _addressController = TextEditingController();
  final GigController _gigController = GigController();
  List<String> _savedAddresses = [];
  bool _useNewAddress = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _gigController.getCurrentUser();

      if (user != null && user.address.isNotEmpty) {
        setState(() {
          _savedAddresses = ['Home: ${user.address}'];

          if (_savedAddresses.isNotEmpty) {
            _addressController.text = _savedAddresses[0];
            // Defer callback until after build is complete
            Future.microtask(() {
              if (mounted) {
                widget.onAddressSelected(_savedAddresses[0]);
              }
            });
          }
        });
      } else {
        // If no address found, use default addresses
        setState(() {
          _savedAddresses = [
            'Home: 123 Main St, Casablanca',
            'Work: 456 Business Ave, Casablanca',
          ];

          _addressController.text = _savedAddresses[0];
          Future.microtask(() {
            if (mounted) {
              widget.onAddressSelected(_savedAddresses[0]);
            }
          });
        });
      }
    } catch (e) {
      print('Error loading user address: $e');
      // Use default addresses in case of error
      setState(() {
        _savedAddresses = [
          'Home: 123 Main St, Casablanca',
          'Work: 456 Business Ave, Casablanca',
        ];

        _addressController.text = _savedAddresses[0];
        Future.microtask(() {
          if (mounted) {
            widget.onAddressSelected(_savedAddresses[0]);
          }
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        // Toggle between saved and new address
        Row(
          children: [
            Switch(
              value: _useNewAddress,
              activeColor: Color(0xFF4527A0),
              onChanged: (value) {
                setState(() {
                  _useNewAddress = value;
                  if (!value && _savedAddresses.isNotEmpty) {
                    _addressController.text = _savedAddresses[0];
                    widget.onAddressSelected(_savedAddresses[0]);
                  } else {
                    _addressController.clear();
                  }
                });
              },
            ),
            Text(
              _useNewAddress ? 'New Address' : 'Saved Addresses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 10),
        if (_isLoading)
          Center(child: CircularProgressIndicator())
        else if (_useNewAddress)
        // New address field
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Enter the address',
              prefixIcon: Icon(Icons.location_on),
              suffixIcon: IconButton(
                icon: Icon(Icons.my_location),
                onPressed: () {
                  // Use current location logic would go here
                  final currentLocationAddress = 'Current Location: 789 Current St, Casablanca';
                  setState(() {
                    _addressController.text = currentLocationAddress;
                    widget.onAddressSelected(currentLocationAddress);
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              widget.onAddressSelected(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
          )
        else
        // Saved addresses dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _addressController.text.isEmpty && _savedAddresses.isNotEmpty
                    ? _savedAddresses[0]
                    : _addressController.text,
                items: _savedAddresses.map((String address) {
                  return DropdownMenuItem<String>(
                    value: address,
                    child: Text(address, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _addressController.text = value;
                      widget.onAddressSelected(value);
                    });
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}