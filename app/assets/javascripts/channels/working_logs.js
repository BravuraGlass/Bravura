App.working_logs = App.cable.subscriptions.create("WorkingLogsChannel", {
  connected: function() {},
  disconnected: function() {},
  received: function(data) {

    console.log(data)

    var uid = data['user_id']
    $('#status-color-'+uid).attr('class', data['status']+'-color');
    $('#checkin-time-'+uid).html(data['checkin_time'])
    $('#checkout-time-'+uid).html(data['checkout_time'])
  }
});

// ---
// generated by coffee-script 1.9.2