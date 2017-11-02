$(document).ready(function(){
  $('#week').on('change', function() {
    window.location.href = "/working_logs/report/?week="+$('#week').val()
  })  
});