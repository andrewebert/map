changes = {}
MapCtrl = ($scope) ->
  $scope.time = "1900_01"
  $scope.countries = {"1900_01": (v for k, v of initial_countries)}

  prev = $scope.countries["1900_01"]
  times = ["2011_07"]
  for time in times
    curr = {}
    for k, v of prev
      curr[k] = v
    for r in changes[time].removed
      delete curr[k][r]
    for k, v of changes[time].added
      curr[k] = v
    $scope.countries[time] = curr
    prev = curr

