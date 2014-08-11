// Generated by CoffeeScript 1.7.1
var MapCtrl;

MapCtrl = function($scope) {
  var Color, MIN_DRAG_THRESHOLD, curr;
  Color = net.brehaut.Color;
  $scope.formal = "";
  $scope.flag = void 0;
  $scope.loading = false;
  $scope.label = {
    x: 0,
    y: 0,
    visible: false,
    flip: "noflip"
  };
  $scope.get_d = function(country) {
    if ((country != null ? country.d : void 0) != null) {
      return country.d;
    } else if (!(country != null ? country.removed : void 0)) {
      console.log("Missing d");
      console.log($scope.time, country);
      return "";
    }
  };
  $scope.$watch('time', function(time) {
    var country, _;
    $scope.countries = $scope.data[time];
    return $scope.visible_countries = (function() {
      var _ref, _results;
      _ref = $scope.countries;
      _results = [];
      for (_ in _ref) {
        country = _ref[_];
        if (!country.removed) {
          _results.push(country);
        }
      }
      return _results;
    })();
  });
  $scope.curr_code = function() {
    var _ref;
    return (_ref = $scope.hard_selected) != null ? _ref : $scope.soft_selected;
  };
  curr = function() {
    if ($scope.countries) {
      return $scope.countries[$scope.curr_code()];
    }
  };
  $scope.selected = function(country) {
    var _ref;
    if (country.code === ((_ref = curr()) != null ? _ref.code : void 0)) {
      return " selected";
    } else {
      return "";
    }
  };
  $scope.formal = function() {
    var _ref;
    return (_ref = curr()) != null ? _ref.formal : void 0;
  };
  $scope.link = function() {
    var _ref;
    return (_ref = curr()) != null ? _ref.link : void 0;
  };
  $scope.description = function() {
    var _ref;
    return (_ref = curr()) != null ? _ref.description : void 0;
  };
  $scope.flag = function() {
    return $scope.get_flag(curr());
  };
  $scope.get_flag = function(country) {
    var flag;
    flag = country != null ? country.flag : void 0;
    if ((!flag) || (flag in $scope.flags)) {
      return flag;
    } else if (!$scope.loading || !($scope.loading === flag)) {
      $scope.loading = flag;
      $scope.load_image(flag, function(src, image) {
        $scope.loading = false;
        $scope.flags[src] = image;
        return $scope.$apply();
      });
      return "";
    }
  };
  MIN_DRAG_THRESHOLD = 10;
  $scope.hard_select = function(code, e) {
    if ($scope.drag_amount < MIN_DRAG_THRESHOLD) {
      console.log("hard selected", code);
      if ($scope.hard_selected === code) {
        $scope.hard_selected = void 0;
      } else {
        $scope.hard_selected = code;
      }
      return e.stopPropagation();
    }
  };
  $scope.soft_select = function(code, e) {
    if (!$scope.dragging) {
      $scope.label.visible = true;
      return $scope.soft_selected = code;
    }
  };
  $scope.deselect = function() {
    if (!$scope.dragging) {
      $scope.label.visible = false;
      return $scope.soft_selected = void 0;
    }
  };
  return $scope.label.text = function() {
    var _ref;
    if ($scope.soft_selected != null) {
      return (_ref = $scope.countries[$scope.soft_selected]) != null ? _ref.name : void 0;
    } else {
      return "";
    }
  };
};
