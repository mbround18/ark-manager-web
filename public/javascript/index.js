var app = angular.module('arkManagerWeb', []);

app.controller('serverActions', function ($scope, $interval, $http) {
    $scope.safely = true;
    $scope.startServer = function () {
        $http({
            method: "POST",
            async: true,
            url: "/api/server/start"
        }).then(function mySuccess(response) {
            swal('', response.data.message, response.data.status);
        }, function myError(response) {
            console.log(response.statusText);
        });
    };
    $scope.stopServer = function () {
        $http({
            method: "POST",
            async: true,
            url: "/api/server/stop"
        }).then(function mySuccess(response) {
            swal('', response.data.message, response.data.status);
        }, function myError(response) {
            console.log(response.statusText);
        });
    };
    $scope.restartServer = function () {
        $http({
            method: "POST",
            async: true,
            url: "/api/server/restart"
        }).then(function mySuccess(response) {
            swal('', response.data.message, response.data.status);
        }, function myError(response) {
            console.log(response.statusText);
        });
    };
    $scope.upgradeServer = function () {
        $http({
            method: "POST",
            async: true,
            url: "/api/server/upgrade",
            data: {safely: $scope.safely}
        }).then(function mySuccess(response) {
            swal('', response.data.message, response.data.status);
        }, function myError(response) {
            console.log(response);
            console.log(response.statusText);
        });
    }
});

app.controller('serverStatus', function ($scope, $interval, $http) {
    $scope.players = {
        active_players: "0",
        arkservers_link: null,
        build_id: null,
        listening: false,
        name: null,
        online: false,
        pid: null,
        players: null,
        running: false,
        version: null
    };

    function loadServerStatus() {
        $http({
            method: "GET",
            async: true,
            cached: false,
            url: "/api/status"
        }).then(function mySuccess(response) {
            if ($scope.status_info !== response.data) {
                $scope.status_info = response.data;
            }
        }, function myError(response) {
            console.log(response.statusText);
        });
    }

    loadServerStatus();

    $interval(function () {
        loadServerStatus();
    }, 10000);
});


app.controller('scheduleStates', function ($scope, $interval, $http) {

    function loadSchedules() {
        $http({
            method: "GET",
            async: true,
            cached: false,
            url: "/api/schedule/states"
        }).then(function mySuccess(response) {
            $scope.automated_start = response.data.automated_start;
            $scope.mod_update_check_schedule = response.data.mod_update_check_schedule;
            $scope.server_update_check_schedule = response.data.server_update_check_schedule;
        }, function myError(response) {
            console.log(response.statusText);
        });
    }

    loadSchedules();

    $scope.updateSchedules = function () {
        $http({
            method: "POST",
            async: true,
            cached: false,
            url: "/api/schedule/states",
            data: {
                automated_start: $scope.automated_start,
                mod_update_check_schedule: $scope.mod_update_check_schedule,
                server_update_check_schedule: $scope.server_update_check_schedule
            }
        }).then(function mySuccess(response) {
            UIkit.notification({message: 'Setting updated...', status: 'success'});
            loadSchedules();
        }, function myError(response) {
            console.log(response.statusText);
        });
    };

    $interval(function () {
        loadSchedules();
    }, 10000);
});

app.controller('playerList', function ($scope, $interval, $http) {
    $scope.players = [{
        name: 'Loading...',
        steam_id: 'Loading...',
        player_id: 'Loading...'
    }];

    function loadPlayerList() {
        $http({
            method: "GET",
            async: true,
            cached: false,
            url: "/api/players/list"
        }).then(function mySuccess(response) {
            if ($scope.players !== response.data) {
                $scope.players = response.data;
            }
        }, function myError(response) {
            console.log(response.statusText);
        });
    }

    // Load mods initially
    loadPlayerList();

    $interval(function () {
        loadPlayerList();
    }, 50000);
});

app.controller('modList', function ($scope, $interval, $http) {
    $scope.mods = [{
        id: '0000000',
        name: 'Loading...',
        version: 'Loading...',
        last_updated: 'Loading...'
    }];

    function loadModList() {
        $http({
            method: "GET",
            async: true,
            cached: false,
            url: "/api/mods/status"
        }).then(function mySuccess(response) {
            if ($scope.mods !== response.data) {
                $scope.mods = response.data;
            }
        }, function myError(response) {
            console.log(response.statusText);
        });
    }

    // Load mods initially
    loadModList();

    $interval(function () {
        loadModList()
    }, 50000);

    $scope.installMod = function () {
        UIkit.notification({message: 'Mod installation in progress.. It may take a minute...', status: 'primary'});
        $http({
            method: "POST",
            url: "/api/mods/install",
            data: {id: $scope.mod_id}
        }).then(function mySuccess(response) {
            swal('', response.data.message, response.data.status);
        }, function myError(response) {
            console.log(response.statusText);
            // $scope.myWelcome = response.statusText;
        });
    }
});


app.directive('numbersOnly', function () {
    return {
        require: 'ngModel',
        link: function (scope, element, attr, ngModelCtrl) {
            function fromUser(text) {
                if (text) {
                    var transformedInput = text.replace(/[^0-9]/g, '');

                    if (transformedInput !== text) {
                        ngModelCtrl.$setViewValue(transformedInput);
                        ngModelCtrl.$render();
                    }
                    return transformedInput;
                }
                return undefined;
            }

            ngModelCtrl.$parsers.push(fromUser);
        }
    };
});

// app.directive('numberMask', function () {
//     return {
//         restrict: 'A',
//         link: function (scope, element, attrs) {
//             $(element).numeric();
//         }
//     }
// });