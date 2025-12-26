import 'package:firebase_database/firebase_database.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Guardarscreen extends StatelessWidget {
  const Guardarscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Gasto"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: formulario(context),
    );
  }
}

Widget formulario(context) {
  TextEditingController id = TextEditingController();
  TextEditingController titulo = TextEditingController();
  TextEditingController descripcion = TextEditingController();
  TextEditingController gasto = TextEditingController();

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          TextField(
            controller: id,
            decoration: InputDecoration(
              label: const Text("Ingresar ID"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.tag),
            ),
          ),
          
          const SizedBox(height: 15),
          
          TextField(
            controller: titulo,
            decoration: InputDecoration(
              label: const Text("Ingresar titulo de gasto"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          
          const SizedBox(height: 15),
          
          TextField(
            controller: descripcion,
            decoration: InputDecoration(
              label: const Text("Ingresar la descripcion del gasto"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          
          const SizedBox(height: 15),
          
          TextField(
            controller: gasto,
            decoration: InputDecoration(
              label: const Text("Ingresar el monto del gasto"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () => guardarG(id.text, titulo.text, descripcion.text, gasto.text, context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> guardarG(String id, titulo, descripcion, gasto, context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  DatabaseReference ref = FirebaseDatabase.instance.ref("gastos/${user.uid}/$id");

  await ref.set({
    "titulo": titulo,
    "descripcion": descripcion,
    "gasto": gasto,
  });

  Navigator.pushNamed(context, '/leer');
}