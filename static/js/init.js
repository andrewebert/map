// Generated by CoffeeScript 1.7.1
var NOW, NOW_MONTH, NOW_YEAR, flags, initialize, load_flags, load_image;

flags = {};

NOW_YEAR = "2014";

NOW_MONTH = "07";

NOW = "" + NOW_YEAR + "_" + NOW_MONTH;

initialize = function() {
  var attr, attrs, changed, code, countries, curr, date, flag_urls, i, last_time, m, old, prev, time, times, y, _i, _j, _k, _l, _len, _len1, _len2, _m, _ref, _ref1, _ref2, _ref3, _ref4;
  countries = {};
  times = [];
  attrs = ["d", "name", "formal", "owner", "flag"];
  for (y = _i = NOW_YEAR; NOW_YEAR <= 1990 ? _i <= 1990 : _i >= 1990; y = NOW_YEAR <= 1990 ? ++_i : --_i) {
    for (m = _j = 12; _j >= 1; m = --_j) {
      if (!(y >= NOW_YEAR && m > NOW_MONTH)) {
        if (m < 10) {
          times.push("" + y + "_0" + m);
        } else {
          times.push("" + y + "_" + m);
        }
      }
    }
  }
  last_time = times.length - 1;
  countries[last_time] = initial_countries;
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
  _ref = times.slice(1);
  for (i = _k = 0, _len = _ref.length; _k < _len; i = ++_k) {
    date = _ref[i];
    time = times.length - i - 2;
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
      countries[time] = curr;
      prev = curr;
      last_time = time;
    } else {
      countries[time] = countries[last_time];
    }
  }
  return [countries, times];
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
