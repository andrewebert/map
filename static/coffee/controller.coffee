MapCtrl = ($scope, $timeout) ->
    Color = net.brehaut.Color

    $scope.selected = undefined
    $scope.formal = ""
    $scope.flag = undefined
    $scope.loading = false

    $scope.label = {x: 0, y: 0, visible: false}

    $scope.get_d = (country) ->
        if country.d?
            return country.d
        else
            console.log("Missing d")
            console.log(country)
            console.log($scope.time)
            return ""

    $scope.country = (code) ->
        countries = $scope.countries[$scope.time]
        if countries? and countries[code]?
            return countries[code]
        console.log("invalid country #{$scope.time} (#{typeof $scope.time}) #{code}")

    selected = () -> 
        code = $scope.hard_selected ? $scope.soft_selected
        if code
            return $scope.country(code).code

    $scope.formal = () ->
        if selected()?
            country = $scope.country(selected())
            if country?.formal?
                return country.formal
        return ""

    $scope.owner = () ->
        if selected()?
            country = $scope.country(selected())
            owners = country?.owner
            if owners
                owners = country.owner.split(" ")
                owners = ($scope.country(o).name for o in owners)
                owners = owners.join(" and ")
                return "(#{owners})"
        return ""

    $scope.link = () ->
        if selected()
            return $scope.country(selected())?.link ? ""
        else
            return ""

    $scope.disputed = () ->
        if selected()?
            disputed = $scope.country(selected())?.disputed
            if disputed
                return disputed
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
        if (flag is "") or (flag of $scope.flags)
            return flag
        else if not $scope.loading or not ($scope.loading is flag)
            $scope.loading = flag
            $scope.load_image(flag, (src, image) ->
                $scope.loading = false
                $scope.flags[src] = image
                #console.log("loaded " + flag)
                $scope.$apply()
            )
            return ""


    MIN_DRAG_THRESHOLD = 10
    $scope.hard_select = (code, e) ->
        if $scope.drag_amount < MIN_DRAG_THRESHOLD
            console.log("hard selected", code)
            if $scope.hard_selected == code
                $scope.hard_selected = undefined
            else
                $scope.hard_selected = code
                $scope.select(code, true)
            e.stopPropagation()

    $scope.soft_select = (code, e) ->
        if not $scope.dragging
            $scope.label.visible = true
            $scope.soft_selected = code
            $scope.select(code, false)

    $scope.select = (code, hard=false) ->
        if hard or !$scope.hard_selected?
            $scope.selected = code
        
    $scope.move_label = (e) ->
        $scope.label.x = e.clientX
        $scope.label.y = e.clientY

    $scope.deselect = () ->
        if not $scope.dragging
            $scope.label.visible = false
            $scope.soft_selected = undefined
            $scope.select(undefined, false)

    $scope.label_text = () ->
        if $scope.soft_selected?
            $scope.country($scope.soft_selected).name
        else
            ""
