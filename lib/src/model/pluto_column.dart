import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoColumnValueFormatter = String Function(dynamic value);

typedef PlutoColumnRenderer = Widget Function(
    PlutoColumnRendererContext rendererContext);

/// It dynamically determines whether the cells of the column are in the edit state.
///
/// Once the [readOnly] value is set,
/// whether the cell is editable cannot be changed during runtime,
/// but if this callback is implemented,
/// it can be determined whether the cell can be edited or not according to the state of the cell.
typedef PlutoColumnCheckReadOnly = bool Function(
  PlutoRow row,
  PlutoCell cell,
);

class PlutoColumn {
  /// A title to be displayed on the screen.
  /// If a titleSpan value is set, the title value is not displayed.
  String title;

  /// Specifies the field name of the row to be connected to the column.
  String field;

  /// Set the column type.
  ///
  /// Text, number, select, date, time, etc.
  /// ex) PlutoColumnType.text(), PlutoColumnType.number() ...
  PlutoColumnType type;

  bool readOnly;

  double width;

  double minWidth;

  /// Customisable title padding.
  /// It takes precedence over defaultColumnTitlePadding in PlutoGridConfiguration.
  EdgeInsets? titlePadding;

  /// Customize the column with TextSpan or WidgetSpan instead of the column's title string.
  ///
  /// ```
  /// titleSpan: const TextSpan(
  ///   children: [
  ///     WidgetSpan(
  ///       child: Text(
  ///         '* ',
  ///         style: TextStyle(color: Colors.red),
  ///       ),
  ///     ),
  ///     TextSpan(text: 'column title'),
  ///   ],
  /// ),
  /// ```
  InlineSpan? titleSpan;

  /// Customisable cell padding.
  /// It takes precedence over defaultCellPadding in PlutoGridConfiguration.
  EdgeInsets? cellPadding;

  /// Text alignment in Cell. (Left, Right, Center)
  PlutoColumnTextAlign textAlign;

  /// Text alignment in Title. (Left, Right, Center)
  PlutoColumnTextAlign titleTextAlign;

  /// Freeze the column to the left and right.
  PlutoColumnFrozen frozen;

  /// Set column sorting.
  PlutoColumnSort sort;

  /// Formatter for display of cell values.
  PlutoColumnValueFormatter? formatter;

  /// Apply the formatter in the editing state.
  /// However, it is applied only when the cell is readonly
  /// or the text cannot be directly modified, such as in the form of select popup.
  bool applyFormatterInEditing;

  Color? backgroundColor;

  /// Rendering for cell widget.
  PlutoColumnRenderer? renderer;

  /// Change the position of the column by dragging the column title.
  bool enableColumnDrag;

  /// Change the position of the row by dragging the icon in the cell.
  bool enableRowDrag;

  /// A checkbox appears in the cell of the column.
  bool enableRowChecked;

  /// Sort rows by tapping on the column heading.
  bool enableSorting;

  /// Displays the right icon of the column title.
  ///
  /// The [PlutoGridConfiguration.columnContextIcon] icon appears.
  /// Tap this icon to bring up the context menu.
  ///
  /// If [enableDropToResize] is also activated,
  /// you can adjust the column width by dragging this icon.
  bool enableContextMenu;

  /// Display the right icon for drop to resize the column
  ///
  /// The [PlutoGridConfiguration.columnResizeIcon] icon appears.
  /// By dragging this icon to the left or right, the width of the column can be adjusted.
  /// Can't narrow down to less than [minWidth].
  /// Also, if [frozen] is set,
  /// it can be expanded only within the limit of the width of the frozen column.
  ///
  /// If [enableContextMenu] is enabled, the contextMenu icon appears.
  /// In this case, dragging the context menu icon adjusts the column width.
  bool enableDropToResize;

  /// Displays filter-related menus in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableFilterMenuItem;

  /// Displays Hide column menu in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableHideColumnMenuItem;

  /// Displays Set columns menu in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableSetColumnsMenuItem;

  bool enableAutoEditing;

  /// Entering the Enter key or tapping the cell enters the Editing mode.
  bool? enableEditingMode;

  /// Hide the column.
  bool hide;

  PlutoColumn({
    required this.title,
    required this.field,
    required this.type,
    this.readOnly = false,
    PlutoColumnCheckReadOnly? checkReadOnly,
    this.width = PlutoGridSettings.columnWidth,
    this.minWidth = PlutoGridSettings.minColumnWidth,
    this.titlePadding,
    this.titleSpan,
    this.cellPadding,
    this.textAlign = PlutoColumnTextAlign.start,
    this.titleTextAlign = PlutoColumnTextAlign.start,
    this.frozen = PlutoColumnFrozen.none,
    this.sort = PlutoColumnSort.none,
    this.formatter,
    this.applyFormatterInEditing = false,
    this.backgroundColor,
    this.renderer,
    this.enableColumnDrag = true,
    this.enableRowDrag = false,
    this.enableRowChecked = false,
    this.enableSorting = true,
    this.enableContextMenu = true,
    this.enableDropToResize = true,
    this.enableFilterMenuItem = true,
    this.enableHideColumnMenuItem = true,
    this.enableSetColumnsMenuItem = true,
    this.enableAutoEditing = false,
    this.enableEditingMode = true,
    this.hide = false,
  })  : _key = UniqueKey(),
        _checkReadOnly = checkReadOnly;

  final Key _key;

  final PlutoColumnCheckReadOnly? _checkReadOnly;

  Key get key => _key;

  bool get hasRenderer => renderer != null;

  bool get hasCheckReadOnly => _checkReadOnly != null;

  FocusNode? _filterFocusNode;

  FocusNode? get filterFocusNode {
    return _filterFocusNode;
  }

  PlutoFilterType? _defaultFilter;

  PlutoFilterType get defaultFilter =>
      _defaultFilter ?? const PlutoFilterTypeContains();

  bool get isShowRightIcon =>
      enableContextMenu || enableDropToResize || !sort.isNone;

  PlutoColumnGroup? group;

  String get titleWithGroup {
    if (group == null) {
      return title;
    }

    List<String> titleList = [
      title,
    ];

    if (group!.expandedColumn != true) {
      titleList.add(group!.title);
    }

    for (final g in group!.parents.toList()) {
      titleList.add(g.title);
    }

    return titleList.reversed.join(' ');
  }

  /// [startPosition] is the position value for the position of the column from the left.
  ///
  /// Updated when the [PlutoGridStateManager.updateVisibilityLayout] method is called.
  ///
  /// [startPosition] is used to determine the position to scroll left and right when moving the keyboard
  /// or whether the columns in the center area are displayed in the screen area.
  double startPosition = 0;

  bool checkReadOnly(PlutoRow? row, PlutoCell? cell) {
    if (!hasCheckReadOnly || row == null || cell == null) {
      return readOnly;
    }

    return _checkReadOnly!(row, cell);
  }

  void setFilterFocusNode(FocusNode? node) {
    _filterFocusNode = node;
  }

  void setDefaultFilter(PlutoFilterType filter) {
    _defaultFilter = filter;
  }

  String formattedValueForType(dynamic value) {
    if (type.isNumber) {
      return type.number!.applyFormat(value);
    }

    return value.toString();
  }

  String formattedValueForDisplay(dynamic value) {
    if (formatter != null) {
      return formatter!(value).toString();
    }

    return formattedValueForType(value);
  }

  String formattedValueForDisplayInEditing(dynamic value) {
    if (formatter != null) {
      final bool allowFormatting =
          readOnly || type.isSelect || type.isTime || type.isDate;

      if (applyFormatterInEditing && allowFormatting) {
        return formatter!(value).toString();
      }
    }

    return value.toString();
  }
}

class PlutoColumnRendererContext {
  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final PlutoCell cell;

  final PlutoGridStateManager stateManager;

  PlutoColumnRendererContext({
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.cell,
    required this.stateManager,
  });
}

enum PlutoColumnTextAlign {
  start,
  left,
  center,
  right,
  end,
}

extension PlutoColumnTextAlignExtension on PlutoColumnTextAlign {
  TextAlign get value {
    switch (this) {
      case PlutoColumnTextAlign.start:
        return TextAlign.start;
      case PlutoColumnTextAlign.left:
        return TextAlign.left;
      case PlutoColumnTextAlign.center:
        return TextAlign.center;
      case PlutoColumnTextAlign.right:
        return TextAlign.right;
      case PlutoColumnTextAlign.end:
        return TextAlign.end;
    }
  }

  AlignmentGeometry get alignmentValue {
    switch (this) {
      case PlutoColumnTextAlign.start:
        return AlignmentDirectional.centerStart;
      case PlutoColumnTextAlign.left:
        return Alignment.centerLeft;
      case PlutoColumnTextAlign.center:
        return Alignment.center;
      case PlutoColumnTextAlign.right:
        return Alignment.centerRight;
      case PlutoColumnTextAlign.end:
        return AlignmentDirectional.centerEnd;
    }
  }

  bool get isStart => this == PlutoColumnTextAlign.start;

  bool get isLeft => this == PlutoColumnTextAlign.left;

  bool get isCenter => this == PlutoColumnTextAlign.center;

  bool get isRight => this == PlutoColumnTextAlign.right;

  bool get isEnd => this == PlutoColumnTextAlign.end;
}

enum PlutoColumnFrozen {
  none,
  left,
  right,
}

extension PlutoColumnFrozenExtension on PlutoColumnFrozen {
  bool get isNone {
    return this == PlutoColumnFrozen.none;
  }

  bool get isLeft {
    return this == PlutoColumnFrozen.left;
  }

  bool get isRight {
    return this == PlutoColumnFrozen.right;
  }

  bool get isFrozen {
    return this == PlutoColumnFrozen.left || this == PlutoColumnFrozen.right;
  }
}

enum PlutoColumnSort {
  none,
  ascending,
  descending,
}

extension PlutoColumnSortExtension on PlutoColumnSort {
  bool get isNone {
    return this == PlutoColumnSort.none;
  }

  bool get isAscending {
    return this == PlutoColumnSort.ascending;
  }

  bool get isDescending {
    return this == PlutoColumnSort.descending;
  }

  String toShortString() {
    return toString().split('.').last;
  }

  PlutoColumnSort fromString(String value) {
    if (value == PlutoColumnSort.ascending.toShortString()) {
      return PlutoColumnSort.ascending;
    } else if (value == PlutoColumnSort.descending.toShortString()) {
      return PlutoColumnSort.descending;
    } else {
      return PlutoColumnSort.none;
    }
  }
}
