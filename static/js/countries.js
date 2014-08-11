// Generated by CoffeeScript 1.7.1
app.directive('countries', function() {
  return function($scope) {
    var attr, attrs, changed, code, countries, country, curr, data, date, flag_urls, i, last_time, load_flags, old, prev, time, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
    $scope.flags = {};
    attrs = ["d", "name", "formal", "flag", "link", "description", "fill", "removed", "code"];
    last_time = $scope.times.length - 1;
    countries = {};
    countries[last_time] = {};
    for (country in initial_countries) {
      data = initial_countries[country];
      countries[last_time][country] = data;
    }
    flag_urls = (function() {
      var _i, _len, _ref, _results;
      _results = [];
      for (_i = 0, _len = population.length; _i < _len; _i++) {
        code = population[_i];
        if (((_ref = initial_countries[code]) != null ? _ref.flag : void 0) != null) {
          _results.push(initial_countries[code].flag);
        }
      }
      return _results;
    })();
    prev = countries[last_time];
    _ref = $scope.times.slice(1);
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      date = _ref[i];
      time = $scope.times.length - i - 2;
      if (changes[date] != null) {
        curr = {};
        for (code in prev) {
          old = prev[code];
          curr[code] = old;
        }
        _ref1 = changes[date];
        for (code in _ref1) {
          changed = _ref1[code];
          if (curr[code] != null) {
            curr[code] = {};
            for (_j = 0, _len1 = attrs.length; _j < _len1; _j++) {
              attr = attrs[_j];
              curr[code][attr] = (_ref2 = (_ref3 = changed[attr]) != null ? _ref3 : prev[code][attr]) != null ? _ref2 : "";
              if (curr[code][attr] === "-") {
                curr[code][attr] = "";
              }
            }
          } else {
            curr[code] = changed;
          }
        }
        countries[time] = curr;
        prev = curr;
        last_time = time;
      } else {
        countries[time] = countries[last_time];
      }
    }
    $scope.data = countries;
    $scope.load_image = function(src, on_load) {
      var image;
      if (src == null) {
        console.log("image load error");
        return;
      }
      image = new Image();
      image.src = src;
      image.onload = function() {
        return on_load(src, image);
      };
      return image.onerror = function() {
        return on_load(src, image);
      };
    };
    return load_flags = function(flag_urls) {
      var src, store, _k, _len2, _results;
      store = function(src, image) {
        console.log(src);
        return $scope.flags[src] = image;
      };
      _results = [];
      for (_k = 0, _len2 = flag_urls.length; _k < _len2; _k++) {
        src = flag_urls[_k];
        _results.push($scope.load_image(src, store));
      }
      return _results;
    };
  };
});