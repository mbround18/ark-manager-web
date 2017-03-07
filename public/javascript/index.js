/**
 * Created by mbruno on 2/23/17.
 */
// window.setInterval(function() {
//     if ( $('input[name="AutoScrollServerChat"]').is(':checked') ) {
//         var elem = document.getElementById('ServerChat');
//         elem.scrollTop = elem.scrollHeight;
//     }
// }, 3000);

window.setInterval(function() {
    buildAndAttachModList();
}, 100000);

window.setInterval(function() {
    clearAndSetServerStatus();
    setSchedulesStateFromCheckboxes();
}, 10000);

window.onload = function() {
    getInitialSchedulesCheckboxes();
    clearAndSetServerStatus();
    buildAndAttachModList();
};

// $(document).ready(getInitialSchedulesCheckboxes());
// $(document).ready(clearAndSetServerStatus());
// $(document).ready(buildAndAttachModList());

function getInitialSchedulesCheckboxes() {
    $.getJSON( "/api/schedule/states", function( data ) {
        if (data['run_automatic_start'] != $('#automaticStartServer').is(':checked')) {
            $("#automaticStartServer").prop("checked", data['run_automatic_start']);
        }
        if (data['mod_update_check_schedule'] != $('#modUpdateCheckSchedule').is(':checked')) {
           $("#modUpdateCheckSchedule").prop("checked", data['mod_update_check_schedule']);
        }
        if (data['server_update_check_schedule'] != $('#serverUpdateCheckSchedule').is(':checked')) {
            $("#serverUpdateCheckSchedule").prop("checked", data['server_update_check_schedule']);
        }
    })
}

function setSchedulesStateFromCheckboxes() {
    $.getJSON( "/api/schedule/states", function( data ) {
        if ((data['mod_update_check_schedule'] != $('#modUpdateCheckSchedule').is(':checked')) || (data['server_update_check_schedule'] != $('#serverUpdateCheckSchedule').is(':checked')) || (data['run_automatic_start'] != $('#automaticStartServer').is(':checked'))) {
            $.ajax({
                type: "POST",
                url: "/api/schedule/states",
                dataType: 'json',
                data: { "run_automatic_start" :$('#automaticStartServer').is(':checked'), "mod_update_check_schedule": $('#modUpdateCheckSchedule').is(':checked'), "server_update_check_schedule" : $('#serverUpdateCheckSchedule').is(':checked')},
                success: function () {
                    getInitialSchedulesCheckboxes();
                }
            });

            // $.post( "/api/schedule/states", { mod_update_check_schedule: $('#modUpdateCheckSchedule').is(':checked'), server_update_check_schedule: $('#serverUpdateCheckSchedule').is(':checked') } );
        }
    })
}

function clearAndSetServerStatus(){
    var serverStatusJSON;
    $.getJSON( "/api/status", function( data ) {
        $('.server-status-info').empty();
        if(data.hasOwnProperty('server_running')){
            data['server_running'].match(/yes/i) ?
                attachAlertToServerStatus('uk-alert-success', 'Your Server is currently: Running!') :
                attachAlertToServerStatus('uk-alert-danger', 'Your Server is currently: Not Running!');
        } else {
            attachAlertToServerStatus('uk-alert-warning', 'The Sever is in an unknown running state!');
        }
        if(data.hasOwnProperty('server_listening')){
            data['server_listening'].match(/yes/i) ?
                attachAlertToServerStatus('uk-alert-success', 'Your Server is currently: Listening!') :
                attachAlertToServerStatus('uk-alert-danger', 'Your Server is currently: Not Listening!');
        } else {
            attachAlertToServerStatus('uk-alert-warning', 'The Sever is in an unknown listening state!');
        }
        if(data.hasOwnProperty('server_online')){
            if(data['server_online'].match(/yes/i)){
                attachAlertToServerStatus('uk-alert-success', 'Your Server is currently: Online!')
            } else {
                if (data.hasOwnProperty('server_running').match(/yes/i)) {
                    attachAlertToServerStatus('uk-alert-warning', 'Your Server is currently in a boot process! Please Wait...')
                } else {
                    attachAlertToServerStatus('uk-alert-danger', 'Your Server is currently: Not Online!');
                }
            }
        } else {
            attachAlertToServerStatus('uk-alert-warning', 'The server is completely offline maybe try clicking start?');
        }
    });
}

function attachAlertToServerStatus(ukAlertType, AlertText) {
    $( ".server-status-info" ).append(
        "<div class='uk-alert " + ukAlertType + "'><p>" + AlertText + "</p></div>"
    );
}

function buildAndAttachModList() {
    // $('.server-mod-list').empty();

    $('.server-mod-list').empty().append(
        '<table id="serverModList" class="uk-table uk-table-striped uk-table-small"><thead><tr><th class="uk-text-left">Mod ID</th><th class="uk-text-left">Mod Version</th><th class="uk-text-left">Last Updated</th></tr></thead><tbody></tbody></table>'
    );

    $.getJSON( "/api/mods/status", function( data ) {
        $.each(data, function (mod_id, mod_info) {
            $('#serverModList').find("tbody").append("<tr class='uk-text-left'><td ><a target='_blank' href='https://steamcommunity.com/sharedfiles/filedetails/?id=" + mod_id + "'>" + mod_id + "</td><td >" + mod_info['version'] + "</td><td>" + mod_info['last_updated'] + "</td></tr>");
        });
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
        var dataForRunCMD = {"cmd": $(data).data('cmd'), "run_reboot_and_update_safely":  $('#runUpdateAndRebootSafely').is(':checked')};
        $.ajax({
            url:'/api/run-command',
            type:'post',
            dataType: 'json',
            data: dataForRunCMD,
            success:function(jqxhr){
                swal('', jqxhr, 'success');
            },
            error:function(jqxhr){
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
    $.ajax({
        url:'/api/run-command',
        type:'post',
        dataType: 'json',
        data: {"cmd": $(data).data('cmd')},
        success:function(jqxhr){
            swal('', jqxhr, 'success');
        },
        error:function(jqxhr){
            swal('Uhh Ohh!', 'Your instruction was not sent!\n' + jqxhr.responseText, 'error');
        }
    });
}