// Generated by CoffeeScript 1.7.1
app.directive('hotkeys', function(hotkeys) {
  return function($scope) {
    var add_direction, key, set_time_key, shift, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _len7, _m, _n, _o, _p, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
    add_direction = function(key, dx, dy) {
      return hotkeys.add({
        combo: key,
        callback: function(e) {
          return shift(e, dx, dy);
        }
      });
    };
    _ref = ["left", "a", "h"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      key = _ref[_i];
      add_direction(key, -1, 0);
    }
    _ref1 = ["down", "s", "j"];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      key = _ref1[_j];
      add_direction(key, 0, 1);
    }
    _ref2 = ["up", "w", "k"];
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      key = _ref2[_k];
      add_direction(key, 0, -1);
    }
    _ref3 = ["right", "l", "d"];
    for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
      key = _ref3[_l];
      add_direction(key, 1, 0);
    }
    _ref4 = ["shift+left", "A", "H"];
    for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
      key = _ref4[_m];
      add_direction(key, -10, 0);
    }
    _ref5 = ["shift+down", "S", "J"];
    for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
      key = _ref5[_n];
      add_direction(key, 0, 10);
    }
    _ref6 = ["shift+up", "W", "K"];
    for (_o = 0, _len6 = _ref6.length; _o < _len6; _o++) {
      key = _ref6[_o];
      add_direction(key, 0, -10);
    }
    _ref7 = ["shift+right", "L", "D"];
    for (_p = 0, _len7 = _ref7.length; _p < _len7; _p++) {
      key = _ref7[_p];
      add_direction(key, 10, 0);
    }
    hotkeys.add({
      combo: "i",
      callback: function(e) {
        return $scope.zoom(1);
      }
    });
    hotkeys.add({
      combo: "o",
      callback: function(e) {
        return $scope.zoom(-1);
      }
    });
    set_time_key = function(key, dt) {
      return hotkeys.add({
        combo: key,
        callback: function() {
          return $scope.set_time($scope.time + dt);
        }
      });
    };
    set_time_key("u", -1);
    set_time_key("p", +1);
    set_time_key("U", -12);
    set_time_key("P", +12);
    return shift = function(e, dx, dy) {
      var amount;
      amount = 50;
      $scope.translate(-dx * amount, -dy * amount);
      return e.preventDefault();
    };
  };
});
