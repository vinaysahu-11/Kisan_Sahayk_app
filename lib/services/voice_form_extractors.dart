// Voice Form Extractors - Extract entities from natural speech

class VoiceFormExtractors {
  // Extract location from text
  static String? extractLocation(String text) {
    final patterns = [
      RegExp(r'(?:se|from)\s+(\w+)', caseSensitive: false),
      RegExp(r'(\w+)\s+(?:se|from)', caseSensitive: false),
      RegExp(r'(?:ko|to)\s+(\w+)', caseSensitive: false),
      RegExp(r'(\w+)\s+(?:ko|to)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    
    return null;
  }
  
  // Extract pickup and drop locations
  static Map<String, String?> extractPickupDrop(String text) {
    final fromMatch = RegExp(r'(?:se|from)\s+(\w+)', caseSensitive: false).firstMatch(text);
    final toMatch = RegExp(r'(?:ko|to|tak)\s+(\w+)', caseSensitive: false).firstMatch(text);
    
    return {
      'pickup': fromMatch?.group(1),
      'drop': toMatch?.group(1),
    };
  }
  
  // Extract vehicle type
  static String? extractVehicleType(String text) {
    final vehicles = {
      'mini truck': 'mini_truck',
      'mini': 'mini_truck',
      'tractor': 'tractor',
      'tempo': 'tempo',
      'pickup': 'pickup',
      'chhota truck': 'mini_truck',
      'bada truck': 'large_truck',
    };
    
    for (var entry in vehicles.entries) {
      if (text.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  // Extract product/crop name
  static String? extractProductName(String text) {
    final patterns = [
      RegExp(r'(\w+)\s+(?:kharidna|bechna|chahiye)', caseSensitive: false),
      RegExp(r'(?:kharidna|bechna)\s+(?:hai)?\s*(\w+)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1);
    }
    
    return null;
  }
  
  // Extract price/amount
  static double? extractPrice(String text) {
    final patterns = [
      RegExp(r'(?:rs|rupay|rupee|₹)\s*(\d+)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:rs|rupay|rupee|₹)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    
    return null;
  }
  
  // Extract quantity
  static int? extractQuantity(String text) {
    final patterns = [
      RegExp(r'(\d+)\s*(?:kg|kilo|quintal|ton)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:quantity|matra)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    
    return null;
  }
  
  // Extract date
  static DateTime? extractDate(String text) {
    final today = DateTime.now();
    
    if (text.contains('aaj') || text.contains('today')) {
      return today;
    }
    
    if (text.contains('kal') || text.contains('tomorrow')) {
      return today.add(const Duration(days: 1));
    }
    
    if (text.contains('parso')) {
      return today.add(const Duration(days: 2));
    }
    
    // Extract specific date pattern
    final datePattern = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      var year = int.tryParse(match.group(3)!);
      
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }
    }
    
    return null;
  }
  
  // Extract skill for labour
  static String? extractSkill(String text) {
    final skills = {
      'harvesting': 'harvesting',
      'katai': 'harvesting',
      'planting': 'planting',
      'ropna': 'planting',
      'beej daalna': 'planting',
      'weeding': 'weeding',
      'nikaai': 'weeding',
      'spraying': 'spraying',
      'chhidkav': 'spraying',
      'irrigation': 'irrigation',
      'sinchai': 'irrigation',
    };
    
    for (var entry in skills.entries) {
      if (text.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
  
  // Extract number of labours
  static int? extractLabourCount(String text) {
    final patterns = [
      RegExp(r'(\d+)\s*(?:log|labour|majdoor|worker)', caseSensitive: false),
      RegExp(r'(?:log|labour|majdoor|worker)\s*(\d+)', caseSensitive: false),
    ];
    
    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    
    return null;
  }
  
  // Extract category
  static String? extractCategory(String text) {
    final categories = {
      'beej': 'seeds',
      'seed': 'seeds',
      'khaad': 'fertilizer',
      'fertilizer': 'fertilizer',
      'keetnaashak': 'pesticide',
      'pesticide': 'pesticide',
      'auzeaar': 'tools',
      'tool': 'tools',
      'fasal': 'crops',
      'crop': 'crops',
      'sabzi': 'vegetables',
      'vegetable': 'vegetables',
    };
    
    for (var entry in categories.entries) {
      if (text.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    return null;
  }
}
