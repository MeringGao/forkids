import 'dart:math';

List<double> distancePoint(beginX, beginY, endX, endY, distance) {
  if (beginX == endX) {
    if (beginY >= endY) {
      return [beginX, beginY - distance];
    }
    return [beginX, beginY + distance];
  }
  if (beginY == endY) {
    if (beginX >= endX) {
      return [beginX + distance, beginY];
    }
    return [beginX - distance, beginY];
  }

  double slope = (endY - beginY) / (endX - beginX);
  double verticalHeight = endY - slope * endX;
//      (x-x1)**2+(y-y1)**2=d**2
//      x**2 -2*x*x1+x1**2 +y**2+y1**2-2*y*y1=d**2
//      x**2 -2*x*x1+x1**2 + (s*x+v)**2+y1**2-2*(s*x+v)*y1=d**2
//      x**2 -2*x*x1 + x1**2 + s**2*x**2+v**2+2*s*v*x - 2*y1*s*x -2*y1*s*v =d**2
  double a = 1 + pow(slope, 2);
  double c = pow(beginX, 2) +
      pow(verticalHeight, 2) +
      pow(beginY, 2) -
      2 * beginY * verticalHeight -
      pow(distance, 2);
  double b = -2 * beginX + 2 * slope * verticalHeight - 2 * beginY * slope;
  double x1 = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
  double y1 = slope * x1 + verticalHeight;
  double x2 = (-b - sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
  double y2 = slope * x2 + verticalHeight;
  if (endX >= beginX) {
    if (x1 > beginX && x1 <= endX) {
      return [x1, y1];
    } else {
      return [x2, y2];
    }
  }
  if (x1 >= endX && x1 < beginX) {
    return [x1, y1];
  }
  return [x2, y2];
}
