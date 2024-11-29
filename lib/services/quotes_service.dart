import 'package:strive_project/models/quote_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';



class QuotesService{
  final api_url ="https://zenquotes.io/api/quotes/";

  Future<Quote?> getRandomQoute() async{
    try{
      var url = Uri.parse(api_url);

      var response = await http.get(url);

      if(response.statusCode == 200){
        var data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          var filteredQuotes = data.where((quote) {
            var quoteText = quote['q'] as String?;
            return quoteText != null && quoteText.length <= 65;
          }).toList();

          if (filteredQuotes.isNotEmpty) {
            var randomIndex = Random().nextInt(filteredQuotes.length);

            return Quote.fromJson(filteredQuotes[randomIndex]);
          }
        }

      }
      else {
        print("Failed to load quotes: ${response.statusCode}");
      }


    }catch (e){
      print(e.toString());
    }
  }
}