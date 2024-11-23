import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class plantHealthService {

  Future<Map<String, dynamic>> _getActiveApiKey() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('api_keys')
        .orderBy('tokens', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No valid API keys found in Firestore.");
    }

    final doc = querySnapshot.docs.first;
    return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
  }

  // Decrement the token count of the API key
  Future<void> _decrementToken(String docId) async {
    final docRef = FirebaseFirestore.instance.collection('api_keys').doc(docId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("API Key document does not exist.");
      }

      final currentTokens = snapshot.data()!['tokens'] as int;

      if (currentTokens > 0) {
        transaction.update(docRef, {'tokens': currentTokens - 1});
      }
    });
  }

  Future<Map<String, dynamic>?> plantHealth(File image) async {

    try {
      // Get the active API key
      final apiKeyData = await _getActiveApiKey();
      final apiKey = apiKeyData['key'] as String;
      final docId = apiKeyData['id'] as String;

      final url = Uri.parse('https://plant.id/api/v3/health_assessment?language=en&details=local_name,description,url,treatment,classification,common_names,cause');
      final request = http.MultipartRequest('POST', url);
      request.fields['api_key'] = apiKey;
      request.files.add(await http.MultipartFile.fromPath('images', image.path));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode != 200) {
        // Decrement the token count upon successful request
        await _decrementToken(docId);
        return json.decode(responseData.body);
      } else {
        print("Failed to identify plant: ${responseData.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}