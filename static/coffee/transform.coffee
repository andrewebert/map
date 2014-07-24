app.directive 'transformable', ($window) -> ($scope) ->
    scale_step = 1.3
    MAX_ZOOM = 12

    $scope.drag_amount = 0
    $scope.dragging = false
    $scope.x_trans = 0
    $scope.y_trans = 0
    $scope.zoom_level = 0
    
    $scope.initializeWindowSize = ->
        MARGIN_LEFT = 10
        MARGIN_RIGHT = 10
        MARGIN_TOP = 10
        MARGIN_BOTTOM = 10
        BASE_WIDTH = 1000
        BASE_HEIGHT = 506

        width = window.innerWidth - MARGIN_LEFT - MARGIN_RIGHT
        height = window.innerHeight - MARGIN_TOP - MARGIN_BOTTOM
        $scope.base_scale = Math.max(
            Math.min(width/BASE_WIDTH, height/BASE_HEIGHT), 1)
        $scope.mapWidth = BASE_WIDTH * $scope.base_scale
        $scope.mapHeight = BASE_HEIGHT * $scope.base_scale 
        $scope.calculate_scale(0, 0, 0)

    angular.element($window).bind 'resize', ->
        $scope.initializeWindowSize()
        $scope.$apply()

    $scope.calculate_scale = (x, y, direction) ->
        $scope.scale = $scope.base_scale * Math.pow(scale_step, $scope.zoom_level)

        translation_factor = 1 - Math.pow(scale_step,direction)
        $scope.translate(translation_factor * x, translation_factor * y)

    $scope.translate = (dx, dy) ->
        $scope.x_trans += dx/$scope.scale
        $scope.y_trans += dy/$scope.scale
        max_x_trans = 0
        max_y_trans = 0
        scale_factor = 1/$scope.scale - 1/$scope.base_scale
        min_x_trans = $scope.mapWidth * scale_factor
        min_y_trans = $scope.mapHeight * scale_factor

        $scope.x_trans = Math.max(Math.min($scope.x_trans, max_x_trans), min_x_trans)
        $scope.y_trans = Math.max(Math.min($scope.y_trans, max_y_trans), min_y_trans)

    $scope.zoom = (direction, x = $scope.mapWidth/2, y = $scope.mapHeight/2) ->
        new_zoom = $scope.zoom_level + direction
        if new_zoom >= 0 and new_zoom <= MAX_ZOOM
            $scope.zoom_level = new_zoom
            $scope.calculate_scale(x, y, direction)

    $scope.mousewheel = (e, d, dx, dy) ->
        x = e.layerX ? e.originalEvent.layerX
        y = e.layerY ? e.originalEvent.layerY
        direction = dy
        $scope.zoom(direction, x, y)

        e.preventDefault()

    $scope.grab = (e) ->
        $scope.dragging = true
        $scope.grab_x = e.pageX
        $scope.grab_y = e.pageY
        $scope.last_x = e.pageX
        $scope.last_y = e.pageY

    $scope.drag = (e) ->
        $scope.drag_amount = 0
        if $scope.last_x? and $scope.last_y?
            x = e.pageX
            y = e.pageY
            $scope.translate(x - $scope.last_x, y - $scope.last_y)
            $scope.last_x = x
            $scope.last_y = y

    $scope.release = () ->
        $scope.dragging =false
        $scope.drag_amount = Math.max(
            Math.abs($scope.last_x - $scope.grab_x),
            Math.abs($scope.last_y - $scope.grab_y))
        $scope.last_x = undefined
        $scope.last_y = undefined

    $scope.initializeWindowSize()
