app.directive 'hotkeys', (hotkeys) -> ($scope) ->
    add_direction = (key, dx, dy) ->
        hotkeys.add
            combo: key
            callback: (e) -> shift(e, dx, dy)

    add_direction(key, -1, 0) for key in ["left", "a", "h"]
    add_direction(key, 0, 1)  for key in ["down", "s", "j"]
    add_direction(key, 0, -1) for key in ["up", "w", "k"]
    add_direction(key, 1, 0)  for key in ["right", "l", "d"]
    add_direction(key, -10, 0) for key in ["shift+left", "A", "H"]
    add_direction(key, 0, 10) for key in ["shift+down", "S", "J"]
    add_direction(key, 0, -10) for key in ["shift+up", "W", "K"]
    add_direction(key, 10, 0) for key in ["shift+right", "L", "D"]
        
    hotkeys.add
        combo: "i"
        callback: (e) -> $scope.zoom(1)
    hotkeys.add
        combo: "o"
        callback: (e) -> $scope.zoom(-1)

    set_time_key = (key, dt) ->
        hotkeys.add
            combo: key
            callback: -> $scope.set_time($scope.time + dt)

    set_time_key("u", -1)
    set_time_key("p", +1)
    set_time_key("U", -12)
    set_time_key("P", +12)
    
    shift = (e, dx, dy) ->
        amount = 50
        $scope.translate(-dx*amount, -dy*amount)
        e.preventDefault()


