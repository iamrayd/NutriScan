class ScannedItems {
  final String barcode;
  final String product;
  final String date;
  final String price;
  final bool isSafe;

  ScannedItems({
    required this.barcode,
    required this.product,
    required this.date,
    required this.price,
    required this.isSafe,
  });
}

final List<ScannedItems> scanItems = [
  ScannedItems(
    barcode: '123-456-789',
    product: 'Nuts',
    date: 'Dec 9',
    price: 'P100',
    isSafe: true,
  ),
  ScannedItems(
    barcode: '987-654-321',
    product: 'Chips',
    date: 'Dec 10',
    price: 'P50',
    isSafe: true,
  ),
  ScannedItems(
    barcode: '555-666-777',
    product: 'Cookies',
    date: 'Dec 11',
    price: 'P75',
    isSafe: false,
  ),
];

