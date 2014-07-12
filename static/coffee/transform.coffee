scale_step = 1.3

calculate_scale = ($scope, x, y, direction) ->
    $scope.scale = $scope.base_scale * Math.pow(scale_step, $scope.zoom_level)

    translation_factor = (Math.pow(scale_step,direction) - 1) / $scope.scale
    $scope.x_trans -= translation_factor * x
    $scope.y_trans -= translation_factor * y

    adjust_trans($scope)


adjust_trans = ($scope) ->
    max_x_trans = 0
    max_y_trans = 0
    scale_factor = ($scope.base_scale - $scope.scale) / ($scope.base_scale * $scope.scale)
    min_x_trans = $scope.mapWidth * scale_factor
    min_y_trans = $scope.mapHeight * scale_factor

    $scope.x_trans = Math.max(Math.min($scope.x_trans, max_x_trans), min_x_trans)
    $scope.y_trans = Math.max(Math.min($scope.y_trans, max_y_trans), min_y_trans)
