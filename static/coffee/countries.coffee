app.directive 'countries', -> ($scope) ->
    $scope.flags = {}

    attrs = ["d", "name", "formal", "owner", "flag", "link", "disputed", "fill"]

    countries = {}
    for country, data of initial_countries
        if not data.d or data.d == ""
            console.log "error", country, data
            delete initial_countries[country]

    last_time = $scope.times.length - 1
    countries[last_time] = initial_countries
    flag_urls = (initial_countries[code].flag for code in population \
        when initial_countries[code]?.flag?)
    prev = initial_countries
    for date, i in $scope.times[1..]
        time = $scope.times.length - i - 2
        if changes[date]?
            curr = {}
            for code, old of prev
                curr[code] = old
            if changes[date].removed?
                for code in changes[date].removed
                    delete curr[code]
            if changes[date].changed?
                for code, changed of changes[date].changed
                    if changed.flag?
                        flag_urls.push(changed.flag)
                    if curr[code]?
                        curr[code] = {}
                        for attr in attrs
                            curr[code][attr] = changed[attr] ? prev[code][attr] ? ""
                            if curr[code][attr] == "-"
                                curr[code][attr] = ""
                    else
                        curr[code] = changed
            countries[time] = curr
            prev = curr
            last_time = time
        else
            countries[time] = countries[last_time]
    #load_flags(flag_urls)

    $scope.countries = countries

    $scope.load_image = (src, on_load) ->
        image = new Image()
        image.src = src
        image.onload = -> on_load(src, image)
        image.onerror = -> on_load(src, image)

    load_flags = (flag_urls) ->
        store = (src, image) -> 
            console.log(src)
            $scope.flags[src] = image
        for src in flag_urls
            $scope.load_image(src, store)


