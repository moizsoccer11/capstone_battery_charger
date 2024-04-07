import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';


class BatteryPage extends StatefulWidget{
  @override
  _BatteryPageState createState() => _BatteryPageState();
}
class _BatteryPageState extends State<BatteryPage>{
  //Battery One
  BatteryState batteryOneState = BatteryState.Full;
  int batteryOneLevel = 100;
  double tempBatteryOne= 10;
  //Battery Two
  BatteryState batteryTwoState = BatteryState.Full;
  int batteryTwoLevel = 100;
  double tempBatteryTwo= 10;
  //Bluetooth instance
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
// Function to discover and connect to a Bluetooth device
  Future<void> discoverDevices() async {
    List<BluetoothDevice> devices = [];
    // Start scanning for devices
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "HC-05") {
          devices.add(result.device);
        }
      }
    });
    // Stop scanning after a few seconds (adjust as needed)
    await Future.delayed(Duration(seconds: 5));
    flutterBlue.stopScan();

    // Connect to the first discovered device (you may want to display a list to choose from)
    if (devices.isNotEmpty) {
      connectToDevice(devices.first);
    }
  }

// Function to connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (await device.connect()) {
      connectedDevice = device;
      // Implement further logic for characteristic discovery and communication
    } else {
      // Handle connection failure
    }
  }

// Function to read battery charge characteristic from the connected device
  Future<void> readBatteryCharge() async {
    if (connectedDevice != null) {
      List<BluetoothService> services = await connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == 'your_battery_charge_uuid') {
            List<int> value = await characteristic.read();
            // Process the received value (battery charge) and update UI
            double batteryCharge = value[0] / 100.0; // Assuming the value is a percentage between 0 and 100
            setState(() {
              this.batteryCharge = batteryCharge;
            });
          }
        }
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Ardunio Based 18650 Battery Charger"),
          centerTitle:true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Battery One
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                batteryLabel("Battery 1"),
                const SizedBox(height: 32),
                batteryStateContainer(batteryOneState),
                const SizedBox(height: 32),
                batteryLevelDisplay(batteryOneLevel),
                const SizedBox(height: 32),
                tempDisplay(tempBatteryOne),
              ],
            ),
            // Add some spacing between the two battery containers
            const SizedBox(width: 20),
            // Battery Two
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                batteryLabel("Battery 2"),
                const SizedBox(height: 32),
                batteryStateContainer(batteryTwoState),
                const SizedBox(height: 32),
                batteryLevelDisplay(batteryTwoLevel),
                const SizedBox(height: 32),
                tempDisplay(tempBatteryOne),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget batteryStateContainer(BatteryState batteryState){
    const style = TextStyle(fontSize: 24, color: Colors.white);
    const double size = 150;

    switch(batteryState){
      case BatteryState.Full:
        const color = Colors.green;
        return Column(
          children: [
            const Icon(Icons.battery_full, size: size, color: color),
            Text('Full!', style: style.copyWith(color: color)),
          ],
        );
      case BatteryState.Charging:
        const color = Colors.green;

        return Column(
          children: [
            const Icon(Icons.battery_charging_full, size: size, color: color),
            Text('Charging...', style: style.copyWith(color: color)),
          ],
        );
      case BatteryState.NoBattery:
      default:
        const color = Colors.red;
        return Column(
          children: [
            const Icon(Icons.battery_alert, size: size, color: color),
            Text('No Battery Inserted...', style: style.copyWith(color: color)),
          ],
        );
    }
  }
  Widget batteryLevelDisplay(int batteryLevel){
    return Text(
        '$batteryLevel%',
        style: const TextStyle(
        fontSize: 32,
        color: Colors.white,
        fontWeight: FontWeight.bold,
    )
    );
  }
  //Battery Label Text
  Widget batteryLabel(String name){
    return Text(
        '$name',
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )
    );
  }
  //Temperature Display
  Widget tempDisplay(double tempLevel){
    const style = TextStyle(fontSize: 24, color: Colors.white);
    const double size = 150;
    return Column(
      children: [
        const Icon(Icons.thermostat_rounded, size: size, color: Colors.white),
        Text('$tempLevel°C', style: style.copyWith(color: Colors.white)),
      ],
    );
  }
}





//ENUM for BatteryState
enum BatteryState {
  Charging,
  Full,
  NoBattery,
}