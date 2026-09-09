import 'package:flutter/material.dart';

/// Representation of a selectable category icon with domain-specific metadata.
class CategoryIconItem {
  final String name;
  final IconData icon;
  final String label;
  final String keywords;

  const CategoryIconItem({
    required this.name,
    required this.icon,
    required this.label,
    required this.keywords,
  });
}

/// Catalog of category icons tailored specifically for the
/// Home Appliances, Consumer Durables & Field Credit Sales business.
class CategoryIcons {
  CategoryIcons._();

  static const List<CategoryIconItem> availableIcons = [
    // 1. Kitchen & Cooking Appliances
    CategoryIconItem(
      name: 'blender',
      icon: Icons.blender,
      label: 'Mixer / Grinder',
      keywords: 'mixer grinder blender juicer wet grinder kitchen appliance',
    ),
    CategoryIconItem(
      name: 'gas-stove',
      icon: Icons.local_fire_department,
      label: 'Gas Stove / Cooktop',
      keywords: 'gas stove burner cooktop induction flame cooking',
    ),
    CategoryIconItem(
      name: 'frying-pan',
      icon: Icons.soup_kitchen,
      label: 'Cookware',
      keywords: 'cookware frying pan pot pressure cooker kitchen utensil',
    ),
    CategoryIconItem(
      name: 'refrigerator',
      icon: Icons.kitchen,
      label: 'Refrigerator',
      keywords: 'refrigerator fridge freezer double door kitchen',
    ),
    CategoryIconItem(
      name: 'microwave',
      icon: Icons.microwave,
      label: 'Microwave / Oven',
      keywords: 'microwave oven otg grill baking heating',
    ),
    CategoryIconItem(
      name: 'water-purifier',
      icon: Icons.water_drop,
      label: 'Water Purifier',
      keywords: 'water purifier ro uv filter dispenser drinking',
    ),
    CategoryIconItem(
      name: 'kettle',
      icon: Icons.coffee_maker,
      label: 'Electric Kettle',
      keywords: 'kettle electric tea coffee maker hot pot boiler',
    ),

    // 2. Cooling & Climate
    CategoryIconItem(
      name: 'wind',
      icon: Icons.air,
      label: 'Ceiling / Table Fan',
      keywords: 'fan ceiling fan table fan pedestal fan wind air cooling',
    ),
    CategoryIconItem(
      name: 'ac',
      icon: Icons.ac_unit,
      label: 'Air Conditioner',
      keywords: 'ac air conditioner split inverter cooling cold',
    ),
    CategoryIconItem(
      name: 'air-cooler',
      icon: Icons.mode_fan_off,
      label: 'Air Cooler',
      keywords: 'air cooler room cooler desert water air cooling',
    ),

    // 3. Laundry & Garment Care
    CategoryIconItem(
      name: 'washing-machine',
      icon: Icons.local_laundry_service,
      label: 'Washing Machine',
      keywords: 'washing machine laundry washer top load front load dryer',
    ),
    CategoryIconItem(
      name: 'iron',
      icon: Icons.iron,
      label: 'Iron Box',
      keywords: 'iron box steam dry garment press clothes cloth laundry',
    ),
    CategoryIconItem(
      name: 'sewing-machine',
      icon: Icons.precision_manufacturing,
      label: 'Sewing Machine',
      keywords: 'sewing machine tailoring tailor stitching cloth embroidery',
    ),
    CategoryIconItem(
      name: 'shirt',
      icon: Icons.checkroom,
      label: 'Textiles & Sarees',
      keywords: 'shirt clothes dress textiles sarees garments apparel checkroom hanger',
    ),

    // 4. Home Entertainment & Audio/Visual
    CategoryIconItem(
      name: 'tv',
      icon: Icons.tv,
      label: 'Smart / LED TV',
      keywords: 'tv television led smart tv display monitor screen entertainment',
    ),
    CategoryIconItem(
      name: 'speaker',
      icon: Icons.speaker,
      label: 'Audio & Speakers',
      keywords: 'speaker sound music audio soundbar home theatre bluetooth party',
    ),
    CategoryIconItem(
      name: 'radio',
      icon: Icons.radio,
      label: 'Radio / Transistor',
      keywords: 'radio fm transistor audio player tuner vintage',
    ),
    CategoryIconItem(
      name: 'headphones',
      icon: Icons.headphones,
      label: 'Headphones',
      keywords: 'headphones earphones earbuds tws audio music wireless',
    ),

    // 5. Home Utility & Lighting
    CategoryIconItem(
      name: 'lightbulb',
      icon: Icons.lightbulb,
      label: 'Lighting & LEDs',
      keywords: 'lightbulb light bulb electricity led tube lamp illumination idea',
    ),
    CategoryIconItem(
      name: 'torch',
      icon: Icons.flashlight_on,
      label: 'Emergency Lantern',
      keywords: 'torch flashlight emergency light solar lamp lantern rechargeable',
    ),
    CategoryIconItem(
      name: 'water-heater',
      icon: Icons.shower,
      label: 'Geyser / Water Heater',
      keywords: 'water heater geyser bath shower hot instant solar',
    ),
    CategoryIconItem(
      name: 'clock',
      icon: Icons.schedule,
      label: 'Wall Clock',
      keywords: 'clock wall clock timepiece time digital analog',
    ),
    CategoryIconItem(
      name: 'vacuum',
      icon: Icons.cleaning_services,
      label: 'Vacuum & Cleaning',
      keywords: 'vacuum cleaner floor cleaning clean home broom',
    ),
    CategoryIconItem(
      name: 'tools',
      icon: Icons.handyman,
      label: 'Power Tools & Hardware',
      keywords: 'tools drill machine repair handyman hardware power',
    ),

    // 6. Furniture & Bedding
    CategoryIconItem(
      name: 'chair',
      icon: Icons.chair,
      label: 'Chairs & Plastic Ware',
      keywords: 'chair furniture seat table plastic chair dining',
    ),
    CategoryIconItem(
      name: 'sofa',
      icon: Icons.weekend,
      label: 'Sofa & Living',
      keywords: 'sofa couch living room set furniture lounge',
    ),
    CategoryIconItem(
      name: 'bed',
      icon: Icons.bed,
      label: 'Cots & Beds',
      keywords: 'bed cot wooden steel cot bedroom furniture',
    ),
    CategoryIconItem(
      name: 'bedding',
      icon: Icons.king_bed,
      label: 'Mattresses & Bedding',
      keywords: 'mattress bedding bedsheet blanket pillow foam comforter',
    ),
    CategoryIconItem(
      name: 'cupboard',
      icon: Icons.door_sliding,
      label: 'Almirah & Wardrobe',
      keywords: 'cupboard almirah wardrobe steel bureau closet storage',
    ),
    CategoryIconItem(
      name: 'luggage',
      icon: Icons.luggage,
      label: 'Trolley & Luggage',
      keywords: 'luggage trolley bag suitcase travel backpack bag',
    ),

    // 7. Personal Electronics & General
    CategoryIconItem(
      name: 'phone',
      icon: Icons.phone_android,
      label: 'Mobile Phones',
      keywords: 'phone mobile android smartphone screen electronics 5g',
    ),
    CategoryIconItem(
      name: 'watch',
      icon: Icons.watch,
      label: 'Smart Watches',
      keywords: 'watch smart watch digital wrist wearable time',
    ),
    CategoryIconItem(
      name: 'laptop',
      icon: Icons.laptop,
      label: 'Laptops & Tablets',
      keywords: 'laptop computer macbook pc tablet screen office',
    ),
    CategoryIconItem(
      name: 'shopping-bag',
      icon: Icons.shopping_bag,
      label: 'Store Offers & Bundles',
      keywords: 'bag shopping purchase item store combo package bundle',
    ),
    CategoryIconItem(
      name: 'inventory',
      icon: Icons.inventory_2,
      label: 'General Products',
      keywords: 'inventory package box general miscellaneous item goods',
    ),
  ];

  static final Map<String, IconData> _iconMap = {
    for (final item in availableIcons) item.name: item.icon,
    // Aliases & legacy mappings for backward compatibility
    'kitchen': Icons.kitchen,
    'fan': Icons.air,
    'cooler': Icons.mode_fan_off,
    'washing': Icons.local_laundry_service,
    'sound': Icons.speaker,
    'audio': Icons.speaker,
    'lighting': Icons.lightbulb,
    'light': Icons.lightbulb,
    'emergency-light': Icons.flashlight_on,
    'geyser': Icons.shower,
    'mattress': Icons.king_bed,
    'almirah': Icons.door_sliding,
    'wardrobe': Icons.door_sliding,
    'mobile': Icons.phone_android,
    'smart-tv': Icons.tv,
    'grinder': Icons.blender,
    'mixer': Icons.blender,
    'apparel': Icons.checkroom,
    'clothes': Icons.checkroom,
    'book': Icons.book,
    'toy': Icons.toys,
  };

  /// Returns the corresponding [IconData] for a category icon name.
  /// Falls back to [Icons.inventory_2] if the icon name is not found.
  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.inventory_2;
    }
    return _iconMap[iconName] ?? Icons.inventory_2;
  }
}
