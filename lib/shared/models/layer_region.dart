class LayerRegion {
  const LayerRegion({
    this.x = 0.0,
    this.y = 0.0,
    this.width = 1.0,
    this.height = 1.0,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  static const full = LayerRegion();

  @override
  bool operator ==(Object other) =>
      other is LayerRegion &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}
