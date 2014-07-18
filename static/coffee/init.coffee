flags = {}
START_YEAR = 1960
START_MONTH = 1
NOW_YEAR = 2014
NOW_MONTH = 7

format_month = (m) -> (if m < 10 then "0" else "") + m.toString()

NOW = "#{NOW_YEAR}_#{format_month(NOW_MONTH)}"

initialize = ->
    countries = {}
    times = []
    attrs = ["d", "name", "formal", "owner", "flag", "link", "disputed"]
    for y in [NOW_YEAR..START_YEAR]
        for m in [12..1]
            if !(y >= NOW_YEAR && m > NOW_MONTH)
                if m < 10
                    times.push("#{y}_0#{m}")
                else
                    times.push("#{y}_#{m}")

    for country, data of initial_countries
        if not data.d
            console.log "error", country, data

    last_time = times.length - 1
    countries[last_time] = initial_countries
    flag_urls = (initial_countries[code].flag for code in population \
        when initial_countries[code]?.flag?)
    prev = initial_countries
    for date, i in times[1..]
        time = times.length - i - 2
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
                    else
                        curr[code] = changed
            #curr[code]["fill"] =
                #if curr[code].disputed and curr[code].disputed != "-"
                    #"color13"
                #else if curr[code].owner
                    #fills[curr[code].owner.split(" ")[0]]
                #else
                    #fills[code]
            countries[time] = curr
            prev = curr
            last_time = time
        else
            countries[time] = countries[last_time]
    #load_flags(flag_urls)
    return [countries, times]


load_image = (src, on_load) ->
    image = new Image()
    image.src = src
    image.onload = -> on_load(src, image)
    image.onerror = -> on_load(src, image)


load_flags = (flag_urls) ->
    store = (src, image) -> 
        console.log(src)
        flags[src] = image
    for src in flag_urls
        load_image(src, store)


