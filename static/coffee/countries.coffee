app.directive 'countries', -> ($scope) ->
    $scope.flags = {}

    attrs = ["d", "name", "formal", "owner", "flag", "link", "disputed", "fill", "is"]

    last_time = $scope.times.length - 1
    countries = {}
    countries[last_time] = {}
    replacements = {}
    replacements[last_time] = {}
    for country, data of initial_countries
        if data.d 
            countries[last_time][country] = data
        else if data.is
            replacements[last_time][country] = data.is
        else
            console.log "error", country, data
            #delete initial_countries[country]

    flag_urls = (initial_countries[code].flag for code in population \
        when initial_countries[code]?.flag?)
    prev = countries[last_time]
    prev_replacement = replacements[last_time]
    for date, i in $scope.times[1..]
        time = $scope.times.length - i - 2
        if changes[date]?
            curr = {}
            curr_replacement = {}
            for code, old of prev
                curr[code] = old
            for code, old of prev_replacement
                curr_replacement[code] = old
            #if changes[date].removed?
                #for code in changes[date].removed
                    #delete curr[code]
            for code, changed of changes[date]
                if changed.is?
                    curr_replacement[code] = changed.is
                    delete curr[code]
                else
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
                    delete curr_replacement[code]
            countries[time] = curr
            replacements[time] = curr_replacement
            prev = curr
            prev_replacement = curr_replacement
            last_time = time
        else
            countries[time] = countries[last_time]
            replacements[time] = replacements[last_time]
    #load_flags(flag_urls)

    $scope.countries = countries
    $scope.replacements = replacements

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


