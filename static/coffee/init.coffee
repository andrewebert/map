flags = {}
NOW = "2013_10"

initialize = (times) ->
    countries = {}
    attrs = ["d", "name", "formal", "owner", "flag"]
    for y in [2013..1990]
        for m in [12..1]
            if !(y >= 2013 && m > 10)
                if m < 10
                    times.push("#{y}_0#{m}")
                else
                    times.push("#{y}_#{m}")

    countries[NOW] = initial_countries
    flag_urls = (initial_countries[code].flag for code in population \
        when initial_countries[code]?.flag?)
    prev = initial_countries
    last_date = NOW
    for date in times[1..]
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
            countries[date] = curr
            prev = curr
            last_date = date
        else
            countries[date] = countries[last_date]
    #load_flags(flag_urls)
    return countries


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


