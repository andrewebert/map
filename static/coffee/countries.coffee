app.directive 'countries', -> ($scope) ->
    replace_countries = (countries, replacements) ->
        for country, replacement_country of replacements
            countries[country] = countries[replacement_country]

    $scope.flags = {}

    attrs = ["d", "name", "formal", "owner", "flag", "link", "disputed",
        "fill", "is", "code"]

    last_time = $scope.times.length - 1
    countries = {}
    countries[last_time] = {}
    replacements = {}
    for country, data of initial_countries
        if data.d 
            countries[last_time][country] = data
        else if data.is
            replacements[country] = data.is
        else
            console.log "error", country, data
            #delete initial_countries[country]
    replace_countries(countries[last_time], replacements)

    flag_urls = (initial_countries[code].flag for code in population \
        when initial_countries[code]?.flag?)
    prev = countries[last_time]
    prev_replacement = replacements[last_time]
    for date, i in $scope.times[1..]
        time = $scope.times.length - i - 2
        if changes[date]?
            curr = {}
            replacements = {}
            for code, old of prev
                curr[code] = old
            #if changes[date].removed?
                #for code in changes[date].removed
                    #delete curr[code]
            for code, changed of changes[date]
                if changed.is?
                    replacements[code] = changed.is
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
            replace_countries(curr, replacements)
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


