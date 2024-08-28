class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String className;
  final double confidence;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.className,
    required this.confidence,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    var box = json['box'][0];
    return BoundingBox(
      x: box[0],
      y: box[1],
      width: box[2] - box[0],
      height: box[3] - box[1],
      className: json['class'],
      confidence: json['confidence'],
    );
  }
}
