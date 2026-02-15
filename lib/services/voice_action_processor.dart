// Voice Action Processor - Process backend AI actions

import 'voice_form_extractors.dart';

class VoiceActionProcessor {
  // Process transport booking action
  static Map<String, dynamic> processTransportAction(String text, String currentScreen) {
    final locations = VoiceFormExtractors.extractPickupDrop(text);
    final vehicle = VoiceFormExtractors.extractVehicleType(text);
    final date = VoiceFormExtractors.extractDate(text);
    
    final fields = <String, dynamic>{};
    
    if (vehicle != null) fields['vehicle_type'] = vehicle;
    if (locations['pickup'] != null) fields['pickup_location'] = locations['pickup'];
    if (locations['drop'] != null) fields['drop_location'] = locations['drop'];
    if (date != null) fields['date'] = date.toString().split(' ')[0];
    
    return {
      'type': fields.isEmpty ? 'navigate' : 'fill_form',
      'route': '/transport',
      'fields': fields.isEmpty ? null : fields,
    };
  }
  
  // Process buy product action
  static Map<String, dynamic> processBuyProductAction(String text) {
    final product = VoiceFormExtractors.extractProductName(text);
    final category = VoiceFormExtractors.extractCategory(text);
    final quantity = VoiceFormExtractors.extractQuantity(text);
    
    final fields = <String, dynamic>{};
    
    if (product != null) fields['search_query'] = product;
    if (category != null) fields['category'] = category;
    if (quantity != null) fields['quantity'] = quantity.toString();
    
    return {
      'type': fields.isEmpty ? 'navigate' : 'fill_form',
      'route': '/buy-product',
      'fields': fields.isEmpty ? null : fields,
    };
  }
  
  // Process sell product action
  static Map<String, dynamic> processSellProductAction(String text) {
    final product = VoiceFormExtractors.extractProductName(text);
    final category = VoiceFormExtractors.extractCategory(text);
    final price = VoiceFormExtractors.extractPrice(text);
    final quantity = VoiceFormExtractors.extractQuantity(text);
    
    final fields = <String, dynamic>{};
    
    if (product != null) fields['product_name'] = product;
    if (category != null) fields['category'] = category;
    if (price != null) fields['price'] = price.toString();
    if (quantity != null) fields['quantity'] = quantity.toString();
    
    return {
      'type': fields.isEmpty ? 'navigate' : 'fill_form',
      'route': '/sell-product',
      'fields': fields.isEmpty ? null : fields,
    };
  }
  
  // Process labour hiring action
  static Map<String, dynamic> processLabourAction(String text) {
    final skill = VoiceFormExtractors.extractSkill(text);
    final count = VoiceFormExtractors.extractLabourCount(text);
    final location = VoiceFormExtractors.extractLocation(text);
    final date = VoiceFormExtractors.extractDate(text);
    
    final fields = <String, dynamic>{};
    
    if (skill != null) fields['skill'] = skill;
    if (count != null) fields['labour_count'] = count.toString();
    if (location != null) fields['location'] = location;
    if (date != null) fields['date'] = date.toString().split(' ')[0];
    
    return {
      'type': fields.isEmpty ? 'navigate' : 'fill_form',
      'route': '/labour',
      'fields': fields.isEmpty ? null : fields,
    };
  }
  
  // Main processor - routes to specific handlers
  static Map<String, dynamic>? processVoiceAction(String intent, String text, String currentScreen) {
    switch (intent) {
      case 'navigate_transport':
      case 'book_transport':
        return processTransportAction(text, currentScreen);
        
      case 'navigate_buy':
      case 'buy_product':
        return processBuyProductAction(text);
        
      case 'navigate_sell':
      case 'sell_product':
        return processSellProductAction(text);
        
      case 'navigate_labour':
      case 'hire_labour':
        return processLabourAction(text);
        
      default:
        return null;
    }
  }
}
