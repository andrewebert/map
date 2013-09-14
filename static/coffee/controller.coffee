changes = {}

initialize = (countries, times) ->
    for y in [2013..1990]
        for m in [12..1]
            if !(y >= 2013 && m >= 2)
                if m < 10
                    times.push("#{y}_0#{m}")
                else
                    times.push("#{y}_#{m}")

    countries["2013_01"] = initial_countries
    prev = initial_countries
    last_date = "2013_01"
    for date in times[1..]
        if changes[date]?
            curr = {}
            for k, v of prev
                curr[k] = v
            for k in changes[date].removed
                delete curr[k]
            for k, v of changes[date].added
                curr[k] = v
            for k, v of changes[date].changed
                curr[k] = v
            countries[date] = curr
            prev = curr
            last_date = date
        else
            countries[date] = countries[last_date]

MapCtrl = ($scope) ->
    $scope.raw_time = 0
    $scope.countries = {}
    $scope.times = []
    $scope.fill = fills
    $scope.x_trans = 0
    $scope.y_trans = 0

    $scope.scale = base_scale
    $scope.width = base_scale * base_width
    $scope.height = base_scale * base_height

    initialize($scope.countries, $scope.times)

    $scope.date_format = (t) ->
      return "#{Math.floor(t/12) + 1990}_#{if t%12+1<10 then "0" else ""}#{(t%12) + 1}"
    $scope.time = () -> $scope.date_format($scope.raw_time)

    $scope.pretty_format = (t) ->
        year = Math.floor(t/12) + 1990
        month = t%12 + 1
        months = {1: "January", 2:"February", 3: "March", 4: "April",\
                  5: "May", 6: "June", 7: "July", 8: "August",\
                  9: "September", 10: "October", 11: "November", 12: "December"}
        return "#{if month<10 then "0" else ""}#{month}-#{year}"
        #return "#{months[month]} #{year}"

    $scope.grab = (e) ->
        $scope.last_x = e.offsetX
        $scope.last_y = e.offsetY

    $scope.drag = (e) ->
        x = e.offsetX
        y = e.offsetY
        if $scope.last_x? and $scope.last_y?
            x_trans = $scope.x_trans + (x - $scope.last_x)/$scope.scale
            y_trans = $scope.y_trans + (y - $scope.last_y)/$scope.scale
            [$scope.x_trans, $scope.y_trans] = adjust_trans(x_trans, y_trans,
                $scope.width, $scope.height, $scope.scale)
            $scope.last_x = x
            $scope.last_y = y


    $scope.release = () ->
        $scope.last_x = undefined
        $scope.last_y = undefined

    $scope.zoom = (e, d, dx, dy) ->
        x = e.originalEvent.offsetX
        y = e.originalEvent.offsetY
        direction = dy

        [$scope.x_trans, $scope.y_trans, $scope.scale] = calculate_scale(x, y,
            direction, $scope.width, $scope.height,
            $scope.x_trans, $scope.y_trans, $scope.scale)

        e.preventDefault()
