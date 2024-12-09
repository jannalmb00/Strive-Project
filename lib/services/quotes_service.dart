import 'package:strive_project/models/quote_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



class QuotesService{
  final api_url ="https://zenquotes.io/api/quotes/";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String quotesCollection = "quotes";
  static const String quoteDocId = "quote_of_the_day";

  Future<Map<String, dynamic>?> getQuoteFromFirebase() async {
    try {
      DocumentSnapshot doc = await _firestore.collection(quotesCollection).doc(quoteDocId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print("Error fetching quote: $e");
    }
    return null;
  }

  Future<void> saveQuoteToFirebase(Map<String, dynamic> quote) async {
    try {
      await _firestore.collection(quotesCollection).doc(quoteDocId).set({
        'quoteText': quote['quoteText'],
        'author': quote['author'],
        'lastFetchedDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error saving quote: $e");
    }
  }

  Future<bool> isQuoteFetchedToday() async {
    try {
      DocumentSnapshot doc = await _firestore.collection(quotesCollection).doc(quoteDocId).get();
      if (doc.exists) {
        var lastFetchedDate = doc['lastFetchedDate'];
        if (lastFetchedDate != null) {
          DateTime lastFetched = DateTime.parse(lastFetchedDate);
          String currentDate = DateTime.now().toIso8601String().split('T')[0]; // Get current date (YYYY-MM-DD)
          String lastFetchedFormatted = lastFetched.toIso8601String().split('T')[0];
          return currentDate == lastFetchedFormatted; // Compare dates
        }
      }
    } catch (e) {
      print("Error checking last fetched date: $e");
    }
    return false;
  }
  Future<void> fetchAndSaveQuote() async {
    // First, check if quote has already been fetched today
    bool fetchedToday = await isQuoteFetchedToday();

    if (!fetchedToday) {
      // Fetch new quote from API (you can replace this with your existing method to get a random quote)
      Map<String, dynamic>? newQuote = await getRandomQoute();

      // Save new quote to Firebase
      await saveQuoteToFirebase(newQuote!);
    } else {
      print('Quote already fetched today');
    }
  }

  Future<Map<String, dynamic>?>  getRandomQoute() async{
    try {
      var url = Uri.parse(api_url);

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          var filteredQuotes = data.where((quote) {
            var quoteText = quote['q'] as String?;
            return quoteText != null && quoteText.length <= 65;
          }).toList();

          if (filteredQuotes.isNotEmpty) {
            var randomIndex = Random().nextInt(filteredQuotes.length);

            // Return a map with the selected quote data
            return {
              'quoteText': filteredQuotes[randomIndex]['q'],
              'author': filteredQuotes[randomIndex]['a'],
            };
          }
        }
      } else {
        print("Failed to load quotes: ${response.statusCode}");
      }
    } catch (e) {
      print(e.toString());
    }

    // Return null if no quote was found
    return null;


  }


}