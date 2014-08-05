MapCtrl = ($scope) ->
    Color = net.brehaut.Color

    $scope.formal = ""
    $scope.flag = undefined
    $scope.loading = false

    $scope.label = {x: 0, y: 0, visible: false, flip: "noflip"}

    $scope.get_d = (country) ->
        if country?.d?
            return country.d
        else if not country?.removed
            console.log("Missing d")
            console.log($scope.time, country)
            return ""

    $scope.$watch 'time', (time) ->
        $scope.countries = $scope.data[time]
        $scope.visible_countries = (country for _, country of $scope.countries \
            when not country.removed)

    #$scope.country = (code) ->
        #countries = $scope.countries[$scope.time]
        #if countries?
            #return countries[code]
        #countries = $scope.countries[$scope.time]
        #if countries? and countries[code]?
            #return countries[code]
        #console.log("invalid country #{$scope.time} (#{typeof $scope.time}) #{code}")


    $scope.selected = ->
        code = $scope.hard_selected ? $scope.soft_selected
        if code
            return $scope.countries[code]?.code

    $scope.curr = ->
        selected = $scope.selected()
        if selected
            return $scope.countries[selected]

    $scope.formal = -> $scope.curr()?.formal

    #$scope.owner = ->
        #owners = $scope.get_owners($scope.curr())
        #if owners
            ##for o in owners
                ##if not $scope.country(o)
                    ##console.log("invalid owner", o, "of", $scope.curr().code)
            #owners = ($scope.country(o)?.name for o in owners)
            #if owners.length > 1
                #owners = owners[0..-2].join(", ") + " and " + owners[owners.length-1]
            #else
                #owners = owners[0]
            #return "(#{owners})"

    #$scope.get_owners = (country) ->
        #owner = country?.owner
        #if owner
            #return owner.split(" ")

    $scope.link = -> $scope.curr()?.link

    $scope.description = -> $scope.curr()?.description

    $scope.flag = -> $scope.get_flag($scope.curr())

    $scope.get_flag = (country) ->
        flag = country?.flag
        #if flag == ""
            #owners = $scope.get_owners(country)
            #if owners
                #return $scope.get_flag($scope.country(owners[0]))
        if (not flag) or (flag of $scope.flags)
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
            e.stopPropagation()

    $scope.soft_select = (code, e) ->
        if not $scope.dragging
            $scope.label.visible = true
            $scope.soft_selected = code

    $scope.deselect = ->
        if not $scope.dragging
            $scope.label.visible = false
            $scope.soft_selected = undefined

    $scope.label.text = ->
        if $scope.soft_selected?
            $scope.countries[$scope.soft_selected]?.name
        else
            ""
