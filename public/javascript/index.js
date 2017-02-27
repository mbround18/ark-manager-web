/**
 * Created by mbruno on 2/23/17.
 */
window.setInterval(function() {
    if ( $('input[name="AutoScrollServerChat"]').is(':checked') ) {
        var elem = document.getElementById('ServerChat');
        elem.scrollTop = elem.scrollHeight;
    }
}, 3000);

window.setInterval(function() {
    clearAndSetServerStatus()
}, 10000);

function clearAndSetServerStatus(){
    var serverStatusJSON;
    $.getJSON( "/api/status", function( data ) {
        $('.server-status-info').empty();
        if(data.hasOwnProperty('server_running')){
            data['server_running'].match(/on/i) ?
                attachAlertToServerStatus('uk-alert-success', 'Your Server is currently: Running!') :
                attachAlertToServerStatus('uk-alert-danger', 'Your Server is currently: Not Running!');
        } else {
            attachAlertToServerStatus('uk-alert-warning', 'The Sever is in an unknown running state!');
        }
        if(data.hasOwnProperty('server_listening')){
            data['server_listening'].match(/on/i) ?
                attachAlertToServerStatus('uk-alert-success', 'Your Server is currently: Listening!') :
                attachAlertToServerStatus('uk-alert-danger', 'Your Server is currently: Not Listening!');
        } else {
            attachAlertToServerStatus('uk-alert-warning', 'The Sever is in an unknown listening state!');
        }
        if(data.hasOwnProperty('server_online')){
            data['server_online'].match(/on/i) ?
                attachAlertToServerStatus('uk-alert-success', 'Your Server is currently: Online!') :
                attachAlertToServerStatus('uk-alert-danger', 'Your Server is currently: Not Online!');
        } else {
            attachAlertToServerStatus('uk-alert-warning', 'The server is completely offline maybe try clicking start?');
        }
    });
}

function attachAlertToServerStatus(ukAlertType, AlertText) {
    $( ".server-status-info" ).append(
        "<div class='uk-alert " + ukAlertType + "'><p>" + AlertText + "</p></div>"
    );
    // var statusAlert = document.createElement('div');
    // var statusAlertP = document.createElement("p");
    // var statusAlertText = document.createTextNode(AlertText);
    // statusAlert.setAttribute("class", "uk-alert " + ukAlertType);
    // statusAlert.appendChild(statusAlertText);
    // // statusAlertP.appendChild(statusAlertText);
    // $('.server-status-info').appendChild(statusAlert);
}

function run_reboot_and_update() {
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
        var dataForRunCMD;
        if ( $('input[name="RunUpdateAndRebootSafely"]').is(':checked') ) {
            dataForRunCMD = {"cmd": "run_upgrades_and_reboot", "run_reboot_and_update_safely": true};
        } else {
            dataForRunCMD = {"cmd": "run_upgrades_and_reboot", "run_reboot_and_update_safely": false};
        }
        $.ajax({
            url:'/api/run-command',
            type:'post',
            dataType: 'json',
            data: dataForRunCMD,
            success:function(){
                swal('', 'Instruction Sent! Server Should be Restarted/Updated shortly', 'success');
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