app.directive 'resizeable', ($window) ->
    ($scope) ->
        $scope.initializeWindowSize = ->
            MARGIN_LEFT = 10
            MARGIN_RIGHT = 10
            MARGIN_TOP = 10
            MARGIN_BOTTOM = 10
            BASE_WIDTH = 1000
            BASE_HEIGHT = 506

            width = window.innerWidth - MARGIN_LEFT - MARGIN_RIGHT
            height = window.innerHeight - MARGIN_TOP - MARGIN_BOTTOM
            $scope.base_scale = Math.min(width/BASE_WIDTH, height/BASE_HEIGHT)
            $scope.mapWidth = BASE_WIDTH * $scope.base_scale
            $scope.mapHeight = BASE_HEIGHT * $scope.base_scale 
            calculate_scale($scope, 0, 0, 0)

        $scope.initializeWindowSize()

        angular.element($window).bind 'resize', ->
            $scope.initializeWindowSize()
            $scope.$apply()
