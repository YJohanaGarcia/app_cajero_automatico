import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cajero Automático',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(),
    );
  }
}
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ingrese su Clave:',
              style: TextStyle(fontSize: 18),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Clave',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // En este apartado verificammos la clave y 
                // damos acceso a la pantalla 'Saldo'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => startApp(),
                  ),
                );
              },
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class startApp extends StatefulWidget {
  @override
  _startAppState createState() => _startAppState();
}

class _startAppState extends State<startApp> {
  double balance = 50000.0; // Saldo inicial.
  TextEditingController withdrawalController = TextEditingController();
  TextEditingController depositController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  _loadBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('balance') ?? 50000.0;
    });
  }

  _saveBalance(double newBalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', newBalance);
  }

  _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cajero Automático'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Saldo actual: \$${balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: withdrawalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto a retirar',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                double withdrawalAmount = double.tryParse(withdrawalController.text) ?? 0.0;
                if (withdrawalAmount > 0 && withdrawalAmount <= balance) {
                  double newBalance = balance - withdrawalAmount;
                  _saveBalance(newBalance);
                  setState(() {
                    balance = newBalance;
                  });
                  withdrawalController.clear();
                } else {
                  _showErrorDialog('Saldo Insuficiente.');
                }
              },
              child: Text('Retirar'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: depositController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto a consignar',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                double depositAmount = double.tryParse(depositController.text) ?? 0.0;
                if (depositAmount > 0) {
                  double newBalance = balance + depositAmount;
                  _saveBalance(newBalance);
                  setState(() {
                    balance = newBalance;
                  });
                  depositController.clear();
                } else {
                  _showErrorDialog('Monto de consignación inválido.');
                }
              },
              child: Text('Consignar'),
            ),
          ],
        ),
      ),
    );
  }
}