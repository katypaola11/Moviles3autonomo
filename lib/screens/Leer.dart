import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeerScreen extends StatelessWidget {
  const LeerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis gastos"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: lista(),
    );
  }
}


Future<List> leerFire() async {
  List gastos = [];
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return gastos;

  DatabaseReference ref = FirebaseDatabase.instance.ref('gastos/${user.uid}');
  final snapshot = await ref.get();
  final data = snapshot.value;

  if (data != null) {
    Map mapGastos = data as Map;
    mapGastos.forEach((clave, value) {
      gastos.add({
        "id": clave,
        "titulo": value['titulo'],
        "descripcion": value['descripcion'],
        "gasto": value['gasto'],
      });
    });
  }

  return gastos;
}


Widget lista() {
  return FutureBuilder(
    future: leerFire(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(
            child: Text(
              "No hay gastos registrados",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    item['id'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(
                  item['titulo'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "Gasto: \$${item['gasto']}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => eliminar(item['id']),
                ),
                onTap: () => editarWidget(
                  context,
                  item['id'],
                  item['titulo'],
                  item['descripcion'],
                  item['gasto'],
                ),
              ),
            );
          },
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}

Future<void> eliminar(String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  DatabaseReference ref = FirebaseDatabase.instance.ref("gastos/${user.uid}/$id");
  await ref.remove();
}


void editarWidget(context, String id, String titulo, String descripcion, String gasto) {
  TextEditingController _titulo = TextEditingController();
  TextEditingController _descripcion = TextEditingController();
  TextEditingController _gasto = TextEditingController();

  _titulo.text = titulo;
  _descripcion.text = descripcion;
  _gasto.text = gasto;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          "Editar gasto",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: _titulo,
                decoration: InputDecoration(
                  label: const Text("Título"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descripcion,
                decoration: InputDecoration(
                  label: const Text("Descripción"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _gasto,
                decoration: InputDecoration(
                  label: const Text("Gasto"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      editar(id, _titulo.text, _descripcion.text, _gasto.text);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text("Cancelar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


Future<void> editar(String id, String titulo, String descripcion, String gasto) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  DatabaseReference ref = FirebaseDatabase.instance.ref("gastos/${user.uid}/$id");
  await ref.update({
    "titulo": titulo,
    "descripcion": descripcion,
    "gasto": gasto,
  });
}