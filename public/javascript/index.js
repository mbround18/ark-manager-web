/**
 * Created by mbruno on 2/23/17.
 */
window.setInterval(function() {
    if ( $('input[name="AutoScrollServerChat"]').is(':checked') ) {
        var elem = document.getElementById('ServerChat');
        elem.scrollTop = elem.scrollHeight;
    }
}, 3000);

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
        if ( $('input[name="RunUpdateAndRebootSafely"]').is(':checked') ) {
            var dataForRunCMD = {"cmd": "run_upgrades_and_reboot", "run_reboot_and_update_safely": "true"};
        } else {
            var dataForRunCMD = {"cmd": "run_upgrades_and_reboot", "run_reboot_and_update_safely": "false"};
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