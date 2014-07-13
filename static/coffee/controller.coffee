MIN_DRAG_THRESHOLD = 10
MAX_ZOOM = 12

MapCtrl = ($scope, $timeout) ->
    Color = net.brehaut.Color

    drag_data = {drag_amount: 0, dragging: false}

    #$scope.max_time = 294
    $scope.max_time = (parseInt(NOW_YEAR) - parseInt(START_YEAR)) * 12 +
        parseInt(NOW_MONTH) - parseInt(START_MONTH)

    $scope.time = $scope.max_time
    $scope.raw_time = $scope.time.toString()
    $scope.countries = {}
    $scope.times = []
    $scope.x_trans = 0
    $scope.y_trans = 0
    $scope.paused = true

    $scope.selected = undefined
    $scope.formal = ""
    $scope.flag = undefined
    $scope.loading = false

    $scope.zoom_level = 0
    #$scope.scale = base_scale
    #$scope.width = base_scale * base_width
    #$scope.height = base_scale * base_height

    $scope.label = {x: 0, y: 0, visible: false}
    $scope.fills = fills

    #count = 0

    [$scope.countries, $scope.times] = initialize($scope.times)

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
      return "#{Math.floor(t/12) + START_YEAR}_#{if t%12+1<10 then "0" else ""}#{(t%12) + 1}"

    $scope.$watch 'raw_time', (value) ->
        $scope.time = parseInt(value)
    
    $scope.play = () ->
        $scope.paused = not $scope.paused
        if not $scope.paused
            if $scope.time == $scope.max_time
                $scope.raw_time = "0"
                $scope.time = 0
            $scope.tick()

    $scope.pretty_format = (t) ->
        time = parseInt(t)
        year = Math.floor(time/12) + parseInt(START_YEAR)
        month = time%12 + 1
        months = {1: "Jan", 2:"Feb", 3: "Mar", 4: "Apr",\
                  5: "May", 6: "Jun", 7: "Jul", 8: "Aug",\
                  9: "Sep", 10: "Oct", 11: "Nov", 12: "Dec"}
        #return "#{if month<10 then "0" else ""}#{month}-#{year}"
        return "#{months[month]} #{year}"

    $scope.country = (code) ->
        if $scope.countries[$scope.time]? and $scope.countries[$scope.time][code]?
            return $scope.countries[$scope.time][code]
        else
            console.log("invalid country #{$scope.time} (#{typeof $scope.time}) #{code}")

    selected = () -> $scope.hard_selected ? $scope.soft_selected

    $scope.formal = () ->
        if selected()?
            country = $scope.country(selected())
            if country?.formal?
                if country.owner
                    return "#{country.formal} (#{$scope.country(country.owner).name})"
                else
                    return country.formal
        return ""

    $scope.flag = () ->
        flag = ""
        if selected()?
            country = $scope.country(selected())
            if country?
                if country.flag
                    flag = country.flag
                else if country.owner
                    owner = $scope.country(country.owner)
                    if owner?.flag
                        flag = owner.flag
        if (flag is "") or (flag of flags)
            return flag
        else if not $scope.loading or not ($scope.loading is flag)
            $scope.loading = flag
            load_image(flag, (src, image) ->
                $scope.loading = false
                flags[src] = image
                console.log("loaded " + flag)
                $scope.$apply()
            )
            return ""


    $scope.hard_select = (code, e) ->
        if drag_data.drag_amount < MIN_DRAG_THRESHOLD
            console.log("hard selected", code)
            if $scope.hard_selected == code
                $scope.hard_selected = undefined
            else
                $scope.hard_selected = code
                $scope.select(code, true)
            e.stopPropagation()

    $scope.soft_select = (code, e) ->
        if not drag_data.dragging
            $scope.label.visible = true
            $scope.soft_selected = code
            $scope.select(code, false)

    $scope.select = (code, hard=false) ->
        if hard or !$scope.hard_selected?
            $scope.selected = code
        #if code != undefined
            #country = $scope.country(code)
            #if country?
                #if country.flag
                    #$scope.flag = country.flag
                #else if country.owner
                    #owner = $scope.country(country.owner)
                    #if owner?.flag
                        #$scope.flag = owner.flag
            #if country?.formal?
                #if country.owner
                    #$scope.formal = "#{country.formal} (#{$scope.country(country.owner).name})"
                #else
                    #$scope.formal = country.formal

        #else
            #$scope.flag = undefined
            #$scope.formal = ""

    $scope.move_label = (e) ->
        $scope.label.x = e.clientX
        $scope.label.y = e.clientY

    $scope.deselect = () ->
        if not drag_data.dragging
            $scope.label.visible = false
            $scope.soft_selected = undefined
            $scope.select(undefined, false)

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
        if selected() == code
            color = Color(color)
            saturation = color.getSaturation() 
            if saturation > 0
                color = color.setSaturation(Math.min(saturation + 0.4, 1))
            color = color.setLightness(Math.max(color.getLightness() - 0.25, 0))
            return color.toCSS()
        else
            return color

    $scope.grab = (e) ->
        drag_data.dragging = true
        drag_data.grab_x = e.pageX
        drag_data.grab_y = e.pageY
        drag_data.last_x = e.pageX
        drag_data.last_y = e.pageY

    $scope.drag = (e) ->
        drag_data.drag_amount = 0
        if drag_data.last_x? and drag_data.last_y?
            x = e.pageX
            y = e.pageY
            $scope.x_trans += (x - drag_data.last_x)/$scope.scale
            $scope.y_trans += (y - drag_data.last_y)/$scope.scale
            adjust_trans($scope)
            drag_data.last_x = x
            drag_data.last_y = y

    $scope.release = () ->
        drag_data.dragging =false
        drag_data.drag_amount = Math.max(
            Math.abs(drag_data.last_x - drag_data.grab_x),
            Math.abs(drag_data.last_y - drag_data.grab_y))
        drag_data.last_x = undefined
        drag_data.last_y = undefined

    $scope.mousewheel = (e, d, dx, dy) ->
        x = e.layerX ? e.originalEvent.layerX
        y = e.layerY ? e.originalEvent.layerY
        direction = dy
        $scope.zoom(x, y, direction)

        #[$scope.x_trans, $scope.y_trans, $scope.scale] = calculate_scale(x, y,
            #direction, $scope.width, $scope.height,
            #$scope.x_trans, $scope.y_trans, $scope.scale)

        e.preventDefault()

    $scope.zoom = (x, y, direction) ->
        new_zoom = $scope.zoom_level + direction
        if new_zoom >= 0 and new_zoom <= MAX_ZOOM
            $scope.zoom_level = new_zoom
            calculate_scale($scope, x, y, direction)

    $scope.tick = () ->
        if not $scope.paused
            if $scope.time < $scope.max_time
                $scope.raw_time = ($scope.time + 1).toString()
            else
                $scope.paused = true
            $timeout($scope.tick, 1000/12/2)
