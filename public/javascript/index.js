/**
 * Created by mbruno on 2/23/17.
 */

// window.setInterval(function () {
    // buildAndAttachModList();
// }, 100000);

window.setInterval(function () {
    // clearAndSetServerStatus();
    setSchedulesStateFromCheckboxes();
}, 10000);

window.onload = function () {
    getInitialSchedulesCheckboxes();
    // clearAndSetServerStatus();
    // buildAndAttachModList();
};

function getInitialSchedulesCheckboxes() {
    var automatic_server_start = $('#automaticStartServer');
    var mod_update_check_schedule = $('#modUpdateCheckSchedule');
    var server_update_check_schedule = $('#serverUpdateCheckSchedule');
    $.getJSON("/api/schedule/states", function (data) {
        if (data['run_automatic_start'] !== automatic_server_start.is(':checked')) {
            automatic_server_start.prop("checked", data['run_automatic_start']);
        }
        if (data['mod_update_check_schedule'] !== mod_update_check_schedule.is(':checked')) {
            mod_update_check_schedule.prop("checked", data['mod_update_check_schedule']);
        }
        if (data['server_update_check_schedule'] !== server_update_check_schedule.is(':checked')) {
            server_update_check_schedule.prop("checked", data['server_update_check_schedule']);
        }
    })
}

function setSchedulesStateFromCheckboxes() {
    var automatic_server_start = $('#automaticStartServer');
    var mod_update_check_schedule = $('#modUpdateCheckSchedule');
    var server_update_check_schedule = $('#serverUpdateCheckSchedule');
    $.getJSON("/api/schedule/states", function (data) {
        if ((data['mod_update_check_schedule'] !== mod_update_check_schedule.is(':checked')) || (data['server_update_check_schedule'] !== server_update_check_schedule.is(':checked')) || (data['run_automatic_start'] !== automatic_server_start.is(':checked'))) {
            $.ajax({
                type: "POST",
                url: "/api/schedule/states",
                dataType: 'json',
                data: {
                    "run_automatic_start": automatic_server_start.is(':checked'),
                    "mod_update_check_schedule": mod_update_check_schedule.is(':checked'),
                    "server_update_check_schedule": server_update_check_schedule.is(':checked')
                },
                success: function () {
                    getInitialSchedulesCheckboxes();
                }
            });

            // $.post( "/api/schedule/states", { mod_update_check_schedule: mod_update_check_schedule.is(':checked'), server_update_check_schedule: server_update_check_schedule.is(':checked') } );
        }
    })
}

function run_reboot_and_update(data) {
    swal({
        title: 'Are you sure?',
        text: "You won't be able to revert this! And if there are people on the server it WILL kick them off!!!!",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, Reboot/Update it!',
        cancelButtonText: 'No, cancel!',
        confirmButtonClass: 'btn btn-success',
        cancelButtonClass: 'btn btn-danger',
        buttonsStyling: true
    }).then(function () {
        var dataForRunCMD = {
            "cmd": $(data).data('cmd'),
            "run_reboot_and_update_safely": $('#runUpdateAndRebootSafely').is(':checked')
        };
        $.ajax({
            url: '/api/run-command',
            type: 'post',
            dataType: 'json',
            data: dataForRunCMD,
            success: function (jqxhr) {
                swal('', jqxhr, 'success');
            },
            error: function (jqxhr) {
                swal('Uhh Ohh!', 'Your instruction was not sent!\n' + jqxhr.responseText, 'error');
            }
        });
    }, function (dismiss) {
        if (dismiss === 'cancel') {
            swal(
                'Cancelled',
                'A wise decision young padawan :)',
                'error'
            )
        }
    });
}


function run_command(data) {
    swal({
        title: 'Are you sure?',
        text: "Are you absolutely sure you would like to perform this action?",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes!',
        cancelButtonText: 'No!',
        confirmButtonClass: 'btn btn-success',
        cancelButtonClass: 'btn btn-danger',
        buttonsStyling: true
    }).then(function () {
        $.ajax({
            url: '/api/run-command',
            type: 'post',
            dataType: 'json',
            data: {"cmd": $(data).data('cmd')},
            success: function (jqxhr) {
                swal('', jqxhr, 'success');
            },
            error: function (jqxhr) {
                swal('Uhh Ohh!', 'Your instruction was not sent!\n' + jqxhr.responseText, 'error');
            }
        });
    }, function (dismiss) {
        if (dismiss === 'cancel') {
            swal(
                'Cancelled',
                'A wise decision young padawan :)',
                'error'
            )
        }
    });
}


// function truncate_string(str, length, ending) {
//     if (length == null) {
//         length = 100;
//     }
//     if (ending == null) {
//         ending = '...';
//     }
//     if (str.length > length) {
//         return str.substring(0, length - ending.length) + ending;
//     } else {
//         return str;
//     }
// };
//


var app = angular.module('arkManagerWeb', []);

app.controller('serverStatus', function ($scope, $interval, $http) {
    function loadServerStatus() {
        $http({
            method: "GET",
            url: "/api/status"
        }).then(function mySuccess(response) {
            console.log(response.data);
            $scope.status_info = response.data;
        }, function myError(response) {
            console.log(response.statusText);
        });
    }

    loadServerStatus();

    $interval(function () {
        loadServerStatus();
    }, 5000);
});

app.controller('modList', function ($scope, $interval, $http) {
    function loadModList() {
        $http({
            method: "GET",
            url: "/api/mods/status"
        }).then(function mySuccess(response) {
            $scope.mods = response.data;
        }, function myError(response) {
            console.log(response.statusText);
            // $scope.myWelcome = response.statusText;
        });
    }

    $scope.mods = [{
        id: '0000000',
        name: 'Loading...',
        version: 'Loading...',
        last_updated: 'Loading...'
    }];

    // Load mods initially
    loadModList();

    $interval(function () {
        loadModList()
    }, 5000);

});