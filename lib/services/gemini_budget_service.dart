import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiBudgetService {
  final String apiKey = 'AIzaSyCd3mvMdoEx7_1KJ5AcCLyNQXRN4u9aWJc';

  Future<String> estimateEventBudget({
    required String title,
    required String description, 
    required String locationType,
    required String locationDetails,
    required int attendees,
    required double fee,
    required int durationDays,
  }) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey');
        
    final String prompt = '''
      I need an estimated budget for a college event with the following details:
      - Event title: $title
      - Description: $description
      - Location: $locationType - $locationDetails
      - Duration: $durationDays day(s)
      - Expected attendees: $attendees people
      - Fees charged per person: ${fee > 0 ? '$fee INR' : 'No fee (In-College event)'}
      
      Please provide a detailed budget breakdown including estimated costs for:
      1. Venue (if outside college)
      2. Food and beverages
      3. Equipment rental
      4. Decorations
      5. Marketing materials
      6. Transportation (if applicable)
      7. Miscellaneous expenses
      
      Also provide a total estimated cost and any suggestions to optimize the budget.
      Format your response in a clear, readable way with line breaks and a markdown format.
      ''';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('API Error: ${response.body}');
        throw Exception('Failed to estimate budget. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in budget estimation: $e');
      throw Exception('Failed to connect to budget service: $e');
    }
  }
  
  // Helper method to handle network errors or fallback to a basic budget template
  String generateFallbackBudget(String title, int attendees, String locationType, int durationDays) {
    int venueCost = locationType == 'Outside College' ? attendees * 200 : 0;
    int foodCost = attendees * 150;
    int equipmentCost = 2000 + (attendees * 20);
    int decorationCost = 1000 + (attendees * 15);
    int marketingCost = durationDays > 1 ? 1500 : 800;
    int transportationCost = locationType == 'Outside College' ? attendees * 100 : 0;
    int miscCost = attendees * 50;
    
    int totalCost = venueCost + foodCost + equipmentCost + decorationCost + 
           marketingCost + transportationCost + miscCost;
    
    return '''
      ## Event Budget Estimate for "$title"
      
      ### Budget Breakdown:
      
      1. **${locationType == 'Outside College' ? 'Venue: ₹' + venueCost.toString() : 'Venue: ₹0 (Using college facilities)'}**
      2. **Food and Beverages: ₹$foodCost**
         - Snacks and refreshments: ₹${attendees * 100}
         - Water and beverages: ₹${attendees * 50}
      3. **Equipment: ₹$equipmentCost**
         - Sound system: ₹1500
         - Projector/screen: ₹500
         - Miscellaneous: ₹${attendees * 20}
      4. **Decorations: ₹$decorationCost**
      5. **Marketing Materials: ₹$marketingCost**
         - Posters and banners: ₹500
         - Digital marketing: ₹${durationDays > 1 ? 1000 : 300}
      6. **${locationType == 'Outside College' ? 'Transportation: ₹' + transportationCost.toString() : 'Transportation: ₹0 (Not required)'}**
      7. **Miscellaneous: ₹$miscCost** (emergency funds, unexpected expenses)
      
      ### Total Estimated Budget: ₹$totalCost
      
      ### Recommendations:
      - Consider seeking sponsorships to offset costs
      - Look into bulk catering discounts for food
      - Utilize student volunteers to reduce staffing costs
      - ${durationDays > 1 ? 'For multi-day events, negotiate package deals with vendors' : 'Keep the event focused to minimize costs'}
    ''';
  }
}