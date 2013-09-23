// Generated by CoffeeScript 1.6.3
var MapCtrl, flags, initialize, load_flags, load_image;

flags = {};

initialize = function(countries, times) {
  var attr, attrs, changed, code, curr, date, flag_urls, last_date, m, old, prev, y, _i, _j, _k, _l, _len, _len1, _len2, _m, _ref, _ref1, _ref2, _ref3, _ref4;
  attrs = ["d", "name", "formal", "owner", "flag"];
  for (y = _i = 2013; _i >= 1990; y = --_i) {
    for (m = _j = 12; _j >= 1; m = --_j) {
      if (!(y >= 2013 && m >= 2)) {
        if (m < 10) {
          times.push("" + y + "_0" + m);
        } else {
          times.push("" + y + "_" + m);
        }
      }
    }
  }
  countries["2013_01"] = initial_countries;
  flag_urls = (function() {
    var _k, _len, _ref, _results;
    _results = [];
    for (_k = 0, _len = population.length; _k < _len; _k++) {
      code = population[_k];
      if (((_ref = initial_countries[code]) != null ? _ref.flag : void 0) != null) {
        _results.push(initial_countries[code].flag);
      }
    }
    return _results;
  })();
  prev = initial_countries;
  last_date = "2013_01";
  _ref = times.slice(1);
  for (_k = 0, _len = _ref.length; _k < _len; _k++) {
    date = _ref[_k];
    if (changes[date] != null) {
      curr = {};
      for (code in prev) {
        old = prev[code];
        curr[code] = old;
      }
      if (changes[date].removed != null) {
        _ref1 = changes[date].removed;
        for (_l = 0, _len1 = _ref1.length; _l < _len1; _l++) {
          code = _ref1[_l];
          delete curr[code];
        }
      }
      if (changes[date].changed != null) {
        _ref2 = changes[date].changed;
        for (code in _ref2) {
          changed = _ref2[code];
          if (changed.flag != null) {
            flag_urls.push(changed.flag);
          }
          if (curr[code] != null) {
            curr[code] = {};
            for (_m = 0, _len2 = attrs.length; _m < _len2; _m++) {
              attr = attrs[_m];
              curr[code][attr] = (_ref3 = (_ref4 = changed[attr]) != null ? _ref4 : prev[code][attr]) != null ? _ref3 : "";
            }
          } else {
            curr[code] = changed;
          }
        }
      }
      countries[date] = curr;
      prev = curr;
      last_date = date;
    } else {
      countries[date] = countries[last_date];
    }
  }
  return load_flags(flag_urls);
};

load_image = function(src, on_load) {
  var image;
  image = new Image();
  image.src = src;
  image.onload = function() {
    return on_load(src, image);
  };
  return image.onerror = function() {
    return on_load(src, image);
  };
};

load_flags = function(flag_urls) {
  var src, store, _i, _len, _results;
  store = function(src, image) {
    console.log(src);
    return flags[src] = image;
  };
  _results = [];
  for (_i = 0, _len = flag_urls.length; _i < _len; _i++) {
    src = flag_urls[_i];
    _results.push(load_image(src, store));
  }
  return _results;
};

MapCtrl = function($scope, $timeout) {
  var Color;
  Color = net.brehaut.Color;
  $scope.max_raw_time = 276;
  $scope.raw_time = 0;
  $scope.countries = {};
  $scope.times = [];
  $scope.x_trans = 0;
  $scope.y_trans = 0;
  $scope.paused = true;
  $scope.scale = base_scale;
  $scope.width = base_scale * base_width;
  $scope.height = base_scale * base_height;
  $scope.label = {
    x: 0,
    y: 0,
    visible: false
  };
  initialize($scope.countries, $scope.times);
  $scope.get_d = function(code, country) {
    if (country.d != null) {
      return country.d;
    } else {
      console.log("Missing d");
      console.log(code);
      console.log(country);
      console.log($scope.time());
      return "";
    }
  };
  $scope.date_format = function(t) {
    return "" + (Math.floor(t / 12) + 1990) + "_" + (t % 12 + 1 < 10 ? "0" : "") + ((t % 12) + 1);
  };
  $scope.time = function() {
    return $scope.date_format($scope.raw_time);
  };
  $scope.play_button = function() {
    if ($scope.paused) {
      return "../static/img/play.png";
    } else {
      return "../static/img/pause.png";
    }
  };
  $scope.play = function() {
    $scope.paused = !$scope.paused;
    if (!$scope.paused) {
      if (parseInt($scope.raw_time) === $scope.max_raw_time) {
        $scope.raw_time = 0;
      }
      return $scope.tick();
    }
  };
  $scope.pretty_format = function(t) {
    var month, months, year;
    year = Math.floor(t / 12) + 1990;
    month = t % 12 + 1;
    months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December"
    };
    return "" + (month < 10 ? "0" : "") + month + "-" + year;
  };
  $scope.country = function(code) {
    return $scope.countries[$scope.time()][code];
  };
  $scope.formal = function() {
    var country;
    if ($scope.selected() != null) {
      country = $scope.country($scope.selected());
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
    var country, owner;
    if ($scope.selected() != null) {
      country = $scope.country($scope.selected());
      if (country != null) {
        if (country.flag) {
          return country.flag;
        } else if (country.owner) {
          owner = $scope.country(country.owner);
          if (owner != null ? owner.flag : void 0) {
            return owner.flag;
          }
        }
      }
    }
    return "";
  };
  $scope.hard_select = function(code, e) {
    console.log("hard selected", code);
    if ($scope.hard_selected === code) {
      $scope.hard_selected = void 0;
    } else {
      $scope.hard_selected = code;
    }
    return e.stopPropagation();
  };
  $scope.selected = function() {
    var _ref;
    return (_ref = $scope.hard_selected) != null ? _ref : $scope.soft_selected;
  };
  $scope.select = function(code, e) {
    $scope.label.visible = true;
    $scope.soft_selected = code;
    return $scope.move_label(e);
  };
  $scope.move_label = function(e) {
    $scope.label.x = e.clientX;
    return $scope.label.y = e.clientY;
  };
  $scope.deselect = function() {
    $scope.label.visible = false;
    return $scope.soft_selected = void 0;
  };
  $scope.label_text = function() {
    if ($scope.soft_selected != null) {
      return $scope.country($scope.soft_selected).name;
    } else {
      return "";
    }
  };
  $scope.fill = function(code) {
    var color;
    color = fills[code];
    if ($scope.selected() === code) {
      color = Color(color);
      color = color.setSaturation(Math.min(color.getSaturation() + 0.4, 1));
      color = color.setLightness(Math.max(color.getLightness() - 0.25, 0));
      return color.toCSS();
    } else {
      return color;
    }
  };
  $scope.grab = function(e) {
    $scope.last_x = e.layerX;
    return $scope.last_y = e.layerY;
  };
  $scope.drag = function(e) {
    var x, x_trans, y, y_trans, _ref;
    x = e.layerX;
    y = e.layerY;
    if (($scope.last_x != null) && ($scope.last_y != null)) {
      x_trans = $scope.x_trans + (x - $scope.last_x) / $scope.scale;
      y_trans = $scope.y_trans + (y - $scope.last_y) / $scope.scale;
      _ref = adjust_trans(x_trans, y_trans, $scope.width, $scope.height, $scope.scale), $scope.x_trans = _ref[0], $scope.y_trans = _ref[1];
      $scope.last_x = x;
      return $scope.last_y = y;
    }
  };
  $scope.release = function() {
    $scope.last_x = void 0;
    return $scope.last_y = void 0;
  };
  $scope.zoom = function(e, d, dx, dy) {
    var direction, x, y, _ref, _ref1, _ref2;
    x = (_ref = e.layerX) != null ? _ref : e.originalEvent.layerX;
    y = (_ref1 = e.layerY) != null ? _ref1 : e.originalEvent.layerY;
    direction = dy;
    _ref2 = calculate_scale(x, y, direction, $scope.width, $scope.height, $scope.x_trans, $scope.y_trans, $scope.scale), $scope.x_trans = _ref2[0], $scope.y_trans = _ref2[1], $scope.scale = _ref2[2];
    return e.preventDefault();
  };
  return $scope.tick = function() {
    if (!$scope.paused) {
      if ($scope.raw_time < $scope.max_raw_time) {
        $scope.raw_time = parseInt($scope.raw_time) + 1;
      } else {
        $scope.paused = true;
      }
      return $timeout($scope.tick, 1000 / 12 / 2);
    }
  };
};

/*
//@ sourceMappingURL=controller.map
*/
