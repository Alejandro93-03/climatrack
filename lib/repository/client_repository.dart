import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientRepository {
  final _db = FirebaseFirestore.instance;

  Future<Client?> getClientById(String clientId) async {
    final doc = await _db.collection('clients').doc(clientId).get();

    if (!doc.exists) return null;

    return Client.fromMap(doc.data()!, doc.id);
  }
}
