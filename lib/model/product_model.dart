// lib/model/product_model.dart

// ── Piece variant (e.g. 250g / 500g / 1kg options) ───────────────────────────
class ProductPiece {
  final String id;
  final String label;          // e.g. "250g", "500g"
  final double price;          // MRP / original price
  final double effectivePrice; // selling price (after discount)
  final int    discountPct;    // 0 if no discount

  const ProductPiece({
    required this.id,
    required this.label,
    required this.price,
    required this.effectivePrice,
    this.discountPct = 0,
  });

  bool get hasDiscount => discountPct > 0 && effectivePrice < price;

  /// Unique cart key that combines the parent product id and this piece id
  String cartId(String productId) => '${productId}_piece_$id';

  factory ProductPiece.fromJson(Map<String, dynamic> json) {
    final price          = (json['price']          ?? 0).toDouble();
    final effectivePrice = (json['effectivePrice'] ?? json['effective_price'] ?? price).toDouble();
    return ProductPiece(
      id:            json['id']?.toString()    ?? '',
      label:         json['label']?.toString() ?? '',
      price:         price,
      effectivePrice: effectivePrice,
      discountPct:   (json['discountPct'] ?? json['discount_pct'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'label':          label,
    'price':          price,
    'effectivePrice': effectivePrice,
    'discountPct':    discountPct,
  };
}

// ── Main Product model ────────────────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final double price;          // selling price
  final double originalPrice;  // MRP (before discount)
  final String image;          // relative path  e.g. "catalog/products/abc.jpg"
  final String imageUrl;       // absolute URL   e.g. "https://…/abc.jpg"
  final String category;
  final String weight;         // raw weight string e.g. "500g", "1kg"
  final String sku;
  final double discountPercentage;
  final int    quantity;       // stock quantity
  final int    posQuantity;    // POS / physical stock quantity
  final List<ProductPiece> pieces; // variant pieces (empty = single product)

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.imageUrl,
    required this.category,
    required this.weight,
    required this.sku,
    required this.discountPercentage,
    required this.quantity,
    required this.posQuantity,
    this.pieces = const [],
  });

  // ── Computed helpers ───────────────────────────────────────────────────────

  /// True when there is stock available
  bool get isInStock => quantity > 0 || posQuantity > 0;

  /// Rounded discount percentage for display (uses field value or calculates)
  int get computedDiscount {
    if (discountPercentage > 0) return discountPercentage.round();
    if (originalPrice > price && price > 0) {
      return (((originalPrice - price) / originalPrice) * 100).round();
    }
    return 0;
  }

  /// Formatted weight label shown on card (empty = hide)
  String get displayWeight => weight.trim();

  // ── JSON serialization ─────────────────────────────────────────────────────
  factory Product.fromJson(Map<String, dynamic> json) {
    final price         = (json['price']          ?? 0).toDouble();
    final originalPrice = (json['originalPrice']  ??
        json['original_price'] ??
        json['mrp']            ?? price).toDouble();

    final rawPieces = json['pieces'] as List<dynamic>? ?? [];

    return Product(
      id:                 json['id']?.toString()       ?? '',
      name:               json['name']?.toString()     ?? '',
      price:              price,
      originalPrice:      originalPrice,
      image:              json['image']?.toString()    ?? '',
      imageUrl:           json['imageUrl']?.toString() ??
          json['image_url']?.toString() ?? '',
      category:           json['category']?.toString() ?? '',
      weight:             json['weight']?.toString()   ?? '',
      sku:                json['sku']?.toString()      ?? '',
      discountPercentage: (json['discountPercentage'] ??
          json['discount_percentage'] ?? 0).toDouble(),
      quantity:           (json['quantity']    ?? 0).toInt(),
      posQuantity:        (json['posQuantity'] ??
          json['pos_quantity'] ?? 0).toInt(),
      pieces: rawPieces
          .map((p) => ProductPiece.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'name':               name,
    'price':              price,
    'originalPrice':      originalPrice,
    'image':              image,
    'imageUrl':           imageUrl,
    'category':           category,
    'weight':             weight,
    'sku':                sku,
    'discountPercentage': discountPercentage,
    'quantity':           quantity,
    'posQuantity':        posQuantity,
    'pieces':             pieces.map((p) => p.toJson()).toList(),
  };

  /// Creates a copy with overridden fields (useful for piece variants in cart)
  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? image,
    String? imageUrl,
    String? category,
    String? weight,
    String? sku,
    double? discountPercentage,
    int?    quantity,
    int?    posQuantity,
    List<ProductPiece>? pieces,
  }) {
    return Product(
      id:                 id                 ?? this.id,
      name:               name               ?? this.name,
      price:              price              ?? this.price,
      originalPrice:      originalPrice      ?? this.originalPrice,
      image:              image              ?? this.image,
      imageUrl:           imageUrl           ?? this.imageUrl,
      category:           category           ?? this.category,
      weight:             weight             ?? this.weight,
      sku:                sku                ?? this.sku,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      quantity:           quantity           ?? this.quantity,
      posQuantity:        posQuantity        ?? this.posQuantity,
      pieces:             pieces             ?? this.pieces,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}