app.directive 'countries', -> ($scope) ->
    $scope.flags = {}

    attrs = ["d", "name", "formal", "flag", "link", "description",
        "fill", "removed", "code"]

    last_time = $scope.times.length - 1
    countries = {}
    countries[last_time] = {}
    for country, data of initial_countries
        countries[last_time][country] = data

    #flag_urls = (initial_countries[code].flag for code in population \
        #when initial_countries[code]?.flag?)
    prev = countries[last_time]
    for date, i in $scope.times[1..]
        time = $scope.times.length - i - 2
        if changes[date]?
            curr = {}
            for code, old of prev
                curr[code] = old
            for code, changed of changes[date]
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

    $scope.data = countries

    $scope.load_image = (src, on_load) ->
        if not src?
            console.log("image load error")
            return
        image = new Image()
        image.src = src
        image.onload = -> on_load(src, image)
        image.onerror = -> on_load(src, image)

    #load_flags = (flag_urls) ->
        #store = (src, image) -> 
            #console.log(src)
            #$scope.flags[src] = image
        #for src in flag_urls
            #$scope.load_image(src, store)


