/// How many columns fit at [availableWidth] if each card should be roughly
/// [targetCardWidth] wide, clamped to [minColumns]..[maxColumns].
///
/// Every grid in this app was designed with a fixed column count sized for a
/// ~400px-wide phone. Left as-is on a wider window that either leaves a lot
/// of empty space or, worse, stretches those same few cards to fill it —
/// which is what turns a card whose height was tied to its width (via
/// childAspectRatio) into a mostly-empty box. Deriving the column count from
/// the actual space available instead gives a desktop browser more, evenly
/// sized columns rather than the same couple of cards stretched wide.
///
/// Pair this with a fixed `mainAxisExtent` (not `childAspectRatio`) on the
/// grid delegate so a card's height never depends on how wide the window is.
int responsiveGridColumns(
  double availableWidth, {
  required double targetCardWidth,
  int minColumns = 2,
  int maxColumns = 6,
}) {
  if (availableWidth <= 0) return minColumns;

  final columns = (availableWidth / targetCardWidth).floor();
  return columns.clamp(minColumns, maxColumns);
}
