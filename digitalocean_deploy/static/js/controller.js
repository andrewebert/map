// Generated by CoffeeScript 1.7.1
var MIN_DRAG_THRESHOLD, MapCtrl;

MIN_DRAG_THRESHOLD = 10;

MapCtrl = function($scope, $timeout) {
  var Color, drag_data, selected, _ref;
  Color = net.brehaut.Color;
  drag_data = {
    drag_amount: 0,
    dragging: false
  };
  $scope.max_time = 285;
  $scope.time = $scope.max_time;
  $scope.raw_time = $scope.time.toString();
  $scope.countries = {};
  $scope.times = [];
  $scope.x_trans = 0;
  $scope.y_trans = 0;
  $scope.paused = true;
  $scope.selected = void 0;
  $scope.formal = "";
  $scope.flag = void 0;
  $scope.loading = false;
  $scope.zoom_level = 0;
  $scope.label = {
    x: 0,
    y: 0,
    visible: false
  };
  $scope.fills = fills;
  _ref = initialize($scope.times), $scope.countries = _ref[0], $scope.times = _ref[1];
  $scope.date_format = function(t) {
    return "" + (Math.floor(t / 12) + 1990) + "_" + (t % 12 + 1 < 10 ? "0" : "") + ((t % 12) + 1);
  };
  $scope.$watch('raw_time', function(value) {
    return $scope.time = parseInt(value);
  });
  $scope.play = function() {
    $scope.paused = !$scope.paused;
    if (!$scope.paused) {
      if ($scope.time === $scope.max_time) {
        $scope.raw_time = "0";
        $scope.time = 0;
      }
      return $scope.tick();
    }
  };
  $scope.pretty_format = function(t) {
    var month, months, time, year;
    time = parseInt(t);
    year = Math.floor(time / 12) + 1990;
    month = time % 12 + 1;
    months = {
      1: "Jan",
      2: "Feb",
      3: "Mar",
      4: "Apr",
      5: "May",
      6: "Jun",
      7: "Jul",
      8: "Aug",
      9: "Sep",
      10: "Oct",
      11: "Nov",
      12: "Dec"
    };
    return "" + months[month] + " " + year;
  };
  $scope.country = function(code) {
    if (($scope.countries[$scope.time] != null) && ($scope.countries[$scope.time][code] != null)) {
      return $scope.countries[$scope.time][code];
    } else {
      return console.log("invalid country " + $scope.time + " (" + (typeof $scope.time) + ") " + code);
    }
  };
  selected = function() {
    var _ref1;
    return (_ref1 = $scope.hard_selected) != null ? _ref1 : $scope.soft_selected;
  };
  $scope.formal = function() {
    var country;
    if (selected() != null) {
      country = $scope.country(selected());
      if ((country != null ? country.formal : void 0) != null) {
        if (country.owner) {
          return "" + country.formal + " (" + ($scope.country(country.owner).name) + ")";
        } else {
          return country.formal;
        }
      }
    }
    return "";
  };
  $scope.flag = function() {
    var country, flag, owner;
    flag = "";
    if (selected() != null) {
      country = $scope.country(selected());
      if (country != null) {
        if (country.flag) {
          flag = country.flag;
        } else if (country.owner) {
          owner = $scope.country(country.owner);
          if (owner != null ? owner.flag : void 0) {
            flag = owner.flag;
          }
        }
      }
    }
    if ((flag === "") || (flag in flags)) {
      return flag;
    } else if (!$scope.loading || !($scope.loading === flag)) {
      $scope.loading = flag;
      load_image(flag, function(src, image) {
        $scope.loading = false;
        flags[src] = image;
        console.log("loaded " + flag);
        return $scope.$apply();
      });
      return "";
    }
  };
  $scope.hard_select = function(code, e) {
    if (drag_data.drag_amount < MIN_DRAG_THRESHOLD) {
      console.log("hard selected", code);
      if ($scope.hard_selected === code) {
        $scope.hard_selected = void 0;
      } else {
        $scope.hard_selected = code;
        $scope.select(code, true);
      }
      return e.stopPropagation();
    }
  };
  $scope.soft_select = function(code, e) {
    if (!drag_data.dragging) {
      $scope.label.visible = true;
      $scope.soft_selected = code;
      return $scope.select(code, false);
    }
  };
  $scope.select = function(code, hard) {
    if (hard == null) {
      hard = false;
    }
    if (hard || ($scope.hard_selected == null)) {
      return $scope.selected = code;
    }
  };
  $scope.move_label = function(e) {
    $scope.label.x = e.clientX;
    return $scope.label.y = e.clientY;
  };
  $scope.deselect = function() {
    if (!drag_data.dragging) {
      $scope.label.visible = false;
      $scope.soft_selected = void 0;
      return $scope.select(void 0, false);
    }
  };
  $scope.label_text = function() {
    if ($scope.soft_selected != null) {
      return $scope.country($scope.soft_selected).name;
    } else {
      return "";
    }
  };
  $scope.fill = function(code) {
    var color, saturation, _ref1;
    if ((_ref1 = $scope.country(code)) != null ? _ref1.owner : void 0) {
      color = fills[$scope.country(code).owner];
    } else {
      color = fills[code];
    }
    if (selected() === code) {
      color = Color(color);
      saturation = color.getSaturation();
      if (saturation > 0) {
        color = color.setSaturation(Math.min(saturation + 0.4, 1));
      }
      color = color.setLightness(Math.max(color.getLightness() - 0.25, 0));
      return color.toCSS();
    } else {
      return color;
    }
  };
  $scope.grab = function(e) {
    drag_data.dragging = true;
    drag_data.grab_x = e.pageX;
    drag_data.grab_y = e.pageY;
    drag_data.last_x = e.pageX;
    return drag_data.last_y = e.pageY;
  };
  $scope.drag = function(e) {
    var x, y;
    drag_data.drag_amount = 0;
    if ((drag_data.last_x != null) && (drag_data.last_y != null)) {
      x = e.pageX;
      y = e.pageY;
      $scope.x_trans += (x - drag_data.last_x) / $scope.scale;
      $scope.y_trans += (y - drag_data.last_y) / $scope.scale;
      adjust_trans($scope);
      drag_data.last_x = x;
      return drag_data.last_y = y;
    }
  };
  $scope.release = function() {
    drag_data.dragging = false;
    drag_data.drag_amount = Math.max(Math.abs(drag_data.last_x - drag_data.grab_x), Math.abs(drag_data.last_y - drag_data.grab_y));
    drag_data.last_x = void 0;
    return drag_data.last_y = void 0;
  };
  $scope.mousewheel = function(e, d, dx, dy) {
    var direction, x, y, _ref1, _ref2;
    x = (_ref1 = e.layerX) != null ? _ref1 : e.originalEvent.layerX;
    y = (_ref2 = e.layerY) != null ? _ref2 : e.originalEvent.layerY;
    direction = dy;
    $scope.zoom(x, y, direction);
    return e.preventDefault();
  };
  $scope.zoom = function(x, y, direction) {
    var new_zoom;
    new_zoom = $scope.zoom_level + direction;
    if (new_zoom >= 0 && new_zoom <= 8) {
      $scope.zoom_level = new_zoom;
      return calculate_scale($scope, x, y, direction);
    }
  };
  return $scope.tick = function() {
    if (!$scope.paused) {
      if ($scope.time < $scope.max_time) {
        $scope.raw_time = ($scope.time + 1).toString();
      } else {
        $scope.paused = true;
      }
      return $timeout($scope.tick, 1000 / 12 / 2);
    }
  };
};