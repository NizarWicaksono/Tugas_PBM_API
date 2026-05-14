class Product {
  final int id;
  final String name;
  final num price; 
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tanpa Nama',
      price: json['price'] != null ? num.tryParse(json['price'].toString()) ?? 0 : 0,
      description: json['description'] ?? 'Tidak ada deskripsi',
    );
  }
}