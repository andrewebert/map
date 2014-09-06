app.directive 'history', -> ($scope) ->
    history = -> history_data[$scope.year()]

    $scope.history_text = -> history()?.text

    $scope.highlighted = (country) ->
        highlighted = history()?.highlighted?.split(" ")
        if highlighted and (country.code in highlighted) then " highlighted" else ""

