app.directive 'time', ($timeout) -> ($scope) ->
    format_month = (m) -> (if m < 10 then "0" else "") + m.toString()

    START_YEAR = 1950
    START_MONTH = 1
    NOW_YEAR = 2018
    NOW_MONTH = 2
    NOW = "#{NOW_YEAR}_#{format_month(NOW_MONTH)}"

    times = []
    for y in [NOW_YEAR..START_YEAR]
        for m in [12..1]
            if !(y >= NOW_YEAR && m > NOW_MONTH)
                if m < 10
                    times.push("#{y}_0#{m}")
                else
                    times.push("#{y}_#{m}")


    $scope.times = times
    $scope.max_time = (NOW_YEAR - START_YEAR) * 12 + NOW_MONTH - START_MONTH
    $scope.time = $scope.max_time
    $scope.raw_time = $scope.time.toString()
    $scope.paused = true

    
    #$scope.date_format = (t) ->
      #return "#{Math.floor(t/12) + START_YEAR}_#{format_month(t%12 + 1)}"

    $scope.pretty_format = (t) ->
        time = parseInt(t)
        year = Math.floor(time/12) + START_YEAR
        month = time%12 + 1
        months = {1: "Jan", 2:"Feb", 3: "Mar", 4: "Apr",\
                  5: "May", 6: "Jun", 7: "Jul", 8: "Aug",\
                  9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"}
        return "#{months[month]} #{year}"

    $scope.$watch 'raw_time', (value) ->
        $scope.time = parseInt(value)

    $scope.set_time = (new_time) ->
        if new_time < 0
            $scope.raw_time = "0"
        else if new_time > $scope.max_time
            $scope.raw_time = $scope.max_time.toString()
        else
            $scope.raw_time = new_time.toString()
       
    $scope.play = ->
        $scope.paused = not $scope.paused
        if not $scope.paused
            if $scope.time == $scope.max_time
                $scope.raw_time = "0"
                $scope.time = 0
            $scope.tick()

    $scope.tick = ->
        if not $scope.paused
            if $scope.time < $scope.max_time
                $scope.raw_time = ($scope.time + 1).toString()
            else
                $scope.paused = true
            $timeout($scope.tick, 1000/12/2)

