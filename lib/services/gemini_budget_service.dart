import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiBudgetService {
  final String apiKey = 'AIzaSyCd3mvMdoEx7_1KJ5AcCLyNQXRN4u9aWJc';
  late GenerativeModel _model;
  
  GeminiBudgetService() {
    // Initialize the model
    _model = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: apiKey,
    );
  }

  Future<String> estimateEventBudget({
    required String title,
    required String description, 
    required String locationType,
    required String locationDetails,
    required int attendees,
    required double fee,
    required int durationDays,
  }) async {
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
      // Create a content instance with the prompt text
      final content = [Content.text(prompt)];
      
      // Generate content using the model
      final response = await _model.generateContent(content);
      
      // Get the text from the response
      final responseText = response.text;
      
      if (responseText != null && responseText.isNotEmpty) {
        return responseText;
      } else {
        debugPrint('Empty response from Gemini API');
        return generateFallbackBudget(title, attendees, locationType, durationDays);
      }
    } catch (e) {
      debugPrint('Exception in budget estimation: $e');
      return generateFallbackBudget(title, attendees, locationType, durationDays);
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
  
  // Method to try generating budget with optional configurations
  Future<String> estimateEventBudgetWithConfig({
    required String title,
    required String description, 
    required String locationType,
    required String locationDetails,
    required int attendees,
    required double fee,
    required int durationDays,
    double temperature = 0.7,
    int? maxOutputTokens,
    double? topK,
    double? topP,
  }) async {
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
      // Create a content instance with the prompt text
      final content = [Content.text(prompt)];
      
      // Configure generation parameters
      final generationConfig = GenerationConfig(
        temperature: temperature,
        maxOutputTokens: maxOutputTokens,
        
      );
      
      // Create a configured model with the generation parameters
      final configuredModel = GenerativeModel(
        model: 'gemini-1.0-pro',
        apiKey: apiKey,
        generationConfig: generationConfig,
      );
      
      // Generate content using the configured model
      final response = await configuredModel.generateContent(content);
      
      // Get the text from the response
      final responseText = response.text;
      
      if (responseText != null && responseText.isNotEmpty) {
        return responseText;
      } else {
        debugPrint('Empty response from Gemini API with config');
        return generateFallbackBudget(title, attendees, locationType, durationDays);
      }
    } catch (e) {
      debugPrint('Exception in budget estimation with config: $e');
      return generateFallbackBudget(title, attendees, locationType, durationDays);
    }
  }
}