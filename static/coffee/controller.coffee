MIN_DRAG_THRESHOLD = 10

MapCtrl = ($scope, $timeout) ->
    Color = net.brehaut.Color

    drag_data = {drag_amount: 0}

    $scope.max_raw_time = 285

    $scope.raw_time = 0
    $scope.countries = {}
    $scope.times = []
    $scope.x_trans = 0
    $scope.y_trans = 0
    $scope.paused = true

    $scope.scale = base_scale
    $scope.width = base_scale * base_width
    $scope.height = base_scale * base_height

    $scope.label = {x: 0, y: 0, visible: false}

    #count = 0

    $scope.countries = initialize($scope.times)

    #$scope.get_d = (code, country) ->
        #count += 1
        #document.getElementById("count").innerHTML = count
        #if country.d?
            #return country.d
        #else
            #console.log("Missing d")
            #console.log(code)
            #console.log(country)
            #console.log($scope.time())
            #return ""

    $scope.date_format = (t) ->
      return "#{Math.floor(t/12) + 1990}_#{if t%12+1<10 then "0" else ""}#{(t%12) + 1}"

    $scope.time = () -> $scope.date_format($scope.raw_time)

    $scope.play_button = () ->
        if $scope.paused then "../static/img/play.png" else "../static/img/pause.png" 

    $scope.play = () ->
        $scope.paused = not $scope.paused
        if not $scope.paused
            if parseInt($scope.raw_time) == $scope.max_raw_time
                $scope.raw_time = 0
            $scope.tick()


    $scope.pretty_format = (t) ->
        year = Math.floor(t/12) + 1990
        month = t%12 + 1
        #months = {1: "January", 2:"February", 3: "March", 4: "April",\
                  #5: "May", 6: "June", 7: "July", 8: "August",\
                  #9: "September", 10: "October", 11: "November", 12: "December"}
        return "#{if month<10 then "0" else ""}#{month}-#{year}"

    $scope.country = (code) ->
        return $scope.countries[$scope.time()][code]

    $scope.formal = () ->
        if $scope.selected()?
            country = $scope.country($scope.selected())
            if country?.formal?
                if country.owner
                    return "#{country.formal} (#{$scope.country(country.owner).name})"
                else
                    return country.formal
        return ""

    $scope.flag = () ->
        if $scope.selected()?
            country = $scope.country($scope.selected())
            if country?
                if country.flag
                    return country.flag
                else if country.owner
                    owner = $scope.country(country.owner)
                    if owner?.flag
                        return owner.flag
        return ""


    $scope.hard_select = (code, e) ->
        if drag_data.drag_amount < MIN_DRAG_THRESHOLD
            console.log("hard selected", code)
            if $scope.hard_selected == code
                $scope.hard_selected = undefined
            else
                $scope.hard_selected = code
            e.stopPropagation()

    $scope.selected = () -> $scope.hard_selected ? $scope.soft_selected

    $scope.select = (code, e) ->
        $scope.label.visible = true
        $scope.soft_selected = code
        $scope.move_label(e)

    $scope.move_label = (e) ->
        $scope.label.x = e.clientX
        $scope.label.y = e.clientY

    $scope.deselect = () ->
        $scope.label.visible = false
        $scope.soft_selected = undefined

    $scope.label_text = () ->
        if $scope.soft_selected?
            $scope.country($scope.soft_selected).name
        else
            ""

    $scope.fill = (code) ->
        if $scope.country(code)?.owner
            color = fills[$scope.country(code).owner]
        else
            color = fills[code]
        if $scope.selected() == code
            color = Color(color)
            saturation = color.getSaturation() 
            if saturation > 0
                color = color.setSaturation(Math.min(saturation + 0.4, 1))
            color = color.setLightness(Math.max(color.getLightness() - 0.25, 0))
            return color.toCSS()
        else
            return color

    $scope.grab = (e) ->
        drag_data.grab_x = e.pageX
        drag_data.grab_y = e.pageY
        drag_data.last_x = e.pageX
        drag_data.last_y = e.pageY

    $scope.drag = (e) ->
        drag_data.drag_amount = 0
        if drag_data.last_x? and drag_data.last_y?
            x = e.pageX
            y = e.pageY
            x_trans = $scope.x_trans + (x - drag_data.last_x)/$scope.scale
            y_trans = $scope.y_trans + (y - drag_data.last_y)/$scope.scale
            [$scope.x_trans, $scope.y_trans] = adjust_trans(x_trans, y_trans,
                $scope.width, $scope.height, $scope.scale)
            drag_data.last_x = x
            drag_data.last_y = y

    $scope.release = () ->
        drag_data.drag_amount = Math.max(
            Math.abs(drag_data.last_x - drag_data.grab_x),
            Math.abs(drag_data.last_y - drag_data.grab_y))
        drag_data.last_x = undefined
        drag_data.last_y = undefined

    $scope.zoom = (e, d, dx, dy) ->
        x = e.layerX ? e.originalEvent.layerX
        y = e.layerY ? e.originalEvent.layerY
        direction = dy

        [$scope.x_trans, $scope.y_trans, $scope.scale] = calculate_scale(x, y,
            direction, $scope.width, $scope.height,
            $scope.x_trans, $scope.y_trans, $scope.scale)

        e.preventDefault()

    $scope.tick = () ->
        if not $scope.paused
            if $scope.raw_time < $scope.max_raw_time
                $scope.raw_time = parseInt($scope.raw_time) + 1
            else
                $scope.paused = true
            $timeout($scope.tick, 1000/12/2)
