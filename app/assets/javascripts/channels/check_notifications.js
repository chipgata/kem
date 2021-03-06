App.cable.subscriptions.create(
  { channel: "CheckNotificationsChannel"},

  {
    connected: function() {
      //console.log("connected");
    },

    disconnected: function() {
      //console.log("disconnected");
    },

    rejected: function() {
      //console.log("rejected");
    },

    received: function(data) {
      var rows = '';
      var html = '';
      if(data.endpoints.length != 0) {
        data.endpoints.forEach(function(endpoint) {
          var check_info = data.checks_info[endpoint.id]
          var color = 'success';
          if(check_info['check_status'] == 'CRITICAL')
            color = 'danger'
          else if(check_info['check_status'] == 'WARNING')
            color = 'warning'
          else if(check_info['check_status'] == 'UNKNOWN')
            color = 'primary'

          rows += '<tr>'+
                    '<td class="text-center">'+ endpoint.name +'</td>'+
                    '<td class="text-center">'+ endpoint.path +'</td>'+
                    '<td class="text-center">'+ endpoint.port +'</td>'+
                    '<td class="text-center">'+
                    '   <span class="badge badge-'+ color +'">'+ check_info['check_status'] +'</span>'+
                    '</td>'+
                    '<td class="text-center">' + check_info['last_msg'] + '</td>'+
                    '<td class="text-center">' + check_info['last_check'] + '</td>'+
                    '<td class="text-center">' + check_info['next_check'] + '</td>'+ 
                '</tr>';
        });
        
        html = '<table class="table table-responsive-sm table-hover table-outline mb-0" id="dashboard-endpoint">'+
                      '<thead class="thead-light">'+
                      '<tr>'+
                          '<th class="text-center">Name</th>'+
                          '<th class="text-center">Path</th>'+
                          '<th class="text-center">Port</th>'+
                          '<th class="text-center">Check Status</th>'+
                          '<th class="text-center">Last Msg</th>'+
                          '<th class="text-center">Last Check</th>'+
                          '<th class="text-center">Next Check</th>'+
                      '</tr>'+
                      '</thead>'+
                      '<tbody>'+
                        
                        rows +
                      
                      '</tbody>'
                  '</table>';
    } else {
      html = '<strong>Don\'t have any issue endpoints</strong>';
    }
      $('#dashboard-endpoint-table').html(html);
    }
  }
);