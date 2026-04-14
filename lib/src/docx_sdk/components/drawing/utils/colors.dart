import '../../../../../docx.dart' show Color;

class Colors {
  static final Color black = Color(0x000000);
  static final Color white = Color(0xFFFFFF);
  static final Color red = Color(0xFF0000);
  static final Color green = Color(0x00FF00);
  static final Color blue = Color(0x0000FF);
  static final Color yellow = Color(0xFFFF00);
  static final Color cyan = Color(0x00FFFF);
  static final Color magenta = Color(0xFF00FF);
  
  static final Color gray = Color(0x808080);
  static final Color darkGray = Color(0x404040);
  static final Color lightGray = Color(0xC0C0C0);
  static final Color veryLightGray = Color(0xE0E0E0);
  static final Color veryDarkGray = Color(0x202020);
  
  static final Color darkRed = Color(0x8B0000);
  static final Color darkGreen = Color(0x006400);
  static final Color darkBlue = Color(0x00008B);
  static final Color lightRed = Color(0xFF6B6B);
  static final Color lightGreen = Color(0x90EE90);
  static final Color lightBlue = Color(0xADD8E6);
  
  static final Color orange = Color(0xFFA500);
  static final Color purple = Color(0x800080);
  static final Color pink = Color(0xFFC0CB);
  static final Color brown = Color(0xA52A2A);
  static final Color lime = Color(0x32CD32);
  static final Color olive = Color(0x808000);
  static final Color teal = Color(0x008080);
  static final Color aqua = Color(0x00FFFF);
  static final Color coral = Color(0xFF7F50);
  static final Color crimson = Color(0xDC143C);
  static final Color gold = Color(0xFFD700);
  static final Color indigo = Color(0x4B0082);
  static final Color ivory = Color(0xFFFFF0);
  static final Color lavender = Color(0xE6E6FA);
  static final Color silver = Color(0xC0C0C0);
  static final Color tan = Color(0xD2B48C);
  static final Color violet = Color(0xEE82EE);
  static final Color wheat = Color(0xF5DEB3);
  
  static final Color tomato = Color(0xFF6347);
  static final Color orangeRed = Color(0xFF4500);
  static final Color goldenRod = Color(0xDAA520);
  static final Color orchid = Color(0xDA70D6);
  static final Color salmon = Color(0xFA8072);
  static final Color sienna = Color(0xA0522D);
  static final Color peru = Color(0xCD853F);
  static final Color turquoise = Color(0x40E0D0);
  static final Color skyBlue = Color(0x87CEEB);
  static final Color steelBlue = Color(0x4682B4);
  static final Color royalBlue = Color(0x4169E1);
  static final Color midnightBlue = Color(0x191970);
  static final Color navy = Color(0x000080);
  static final Color forestGreen = Color(0x228B22);
  static final Color seaGreen = Color(0x2E8B57);
  static final Color chartreuse = Color(0x7FFF00);
  
  static final Color pastelRed = Color(0xFFB3B3);
  static final Color pastelGreen = Color(0xB3FFB3);
  static final Color pastelBlue = Color(0xB3B3FF);
  static final Color pastelYellow = Color(0xFFFFB3);
  static final Color pastelPink = Color(0xFFB3E6);
  static final Color pastelPurple = Color(0xE6B3FF);
  static final Color pastelOrange = Color(0xFFD9B3);
  
  static final Color facebookBlue = Color(0x1877F2);
  static final Color twitterBlue = Color(0x1DA1F2);
  static final Color instagramPurple = Color(0xE4405F);
  static final Color whatsAppGreen = Color(0x25D366);
  static final Color youtubeRed = Color(0xFF0000);
  static final Color linkedInBlue = Color(0x0077B5);
  
  static final Color transparent = Color(0x00000000);
  static final Color semiTransparent = Color(0xAA000000);

  static final Map<String, Color> mapColors = Map<String, Color>.unmodifiable(<String, Color>{
      'black': black,
      'white': white,
      'red': red,
      'green': green,
      'blue': blue,
      'yellow': yellow,
      'cyan': cyan,
      'magenta': magenta,
      'gray': gray,
      'darkgray': darkGray,
      'lightgray': lightGray,
      'darkred': darkRed,
      'darkgreen': darkGreen,
      'darkblue': darkBlue,
      'orange': orange,
      'purple': purple,
      'pink': pink,
      'brown': brown,
      'lime': lime,
      'olive': olive,
      'teal': teal,
      'aqua': aqua,
      'coral': coral,
      'crimson': crimson,
      'gold': gold,
      'indigo': indigo,
      'ivory': ivory,
      'lavender': lavender,
      'silver': silver,
      'tan': tan,
      'violet': violet,
      'wheat': wheat,
      'tomato': tomato,
      'transparent': transparent,
    });
  
  static Color? fromName(String name) {
    final String lowerName = name.toLowerCase();
    
    return mapColors[lowerName];
  }
}
