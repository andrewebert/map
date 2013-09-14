changes = {}
MapCtrl = ($scope) ->
    $scope.raw_time = 0
    $scope.times = []
    $scope.countries = {"2013_01": initial_countries}

    $scope.date_format = (t) ->
      return "#{Math.floor(t/12) + 1990}_#{if t%12+1<10 then "0" else ""}#{(t%12) + 1}"
    $scope.time = () -> $scope.date_format($scope.raw_time)

    $scope.pretty_format = (t) ->
        year = Math.floor(t/12) + 1990
        month = t%12 + 1
        months = {1: "January", 2:"February", 3: "March", 4: "April",\
                  5: "May", 6: "June", 7: "July", 8: "August",\
                  9: "September", 10: "October", 11: "November", 12: "December"}
        return "#{if month<10 then "0" else ""}#{month}-#{year}"
        #return "#{months[month]} #{year}"
        


    $scope.fill = fills

    for y in [2013..1990]
        for m in [12..1]
            if !(y >= 2013 && m >= 2)
                if m < 10
                    $scope.times.push("#{y}_0#{m}")
                else
                    $scope.times.push("#{y}_#{m}")


    prev = initial_countries
    last_date = "2013_01"
    for date in $scope.times[1..]
        if changes[date]?
            curr = {}
            for k, v of prev
                curr[k] = v
            for k in changes[date].removed
                delete curr[k]
            for k, v of changes[date].added
                curr[k] = v
            for k, v of changes[date].changed
                curr[k] = v
            $scope.countries[date] = curr
            prev = curr
            last_date = date
        else
            $scope.countries[date] = $scope.countries[last_date]
    return

