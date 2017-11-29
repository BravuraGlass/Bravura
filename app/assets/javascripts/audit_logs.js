$(document).ready(function(){
  $('.filter-button').on('change', function () {
    if ($(this).attr("id") == 'filter-all') {
      $("#date").val(null);
    } else if ($(this).attr("id") == 'filter-today') {
      $("#date").val($("#today_str").val());
    } else if  ($(this).attr("id") == 'filter-yesterday') {
      $("#date").val($("#yesterday_str").val());
    }  
      
    jQuery('#filter-form').submit();
  });

  $('a.filter-button').on('click', function () {
    jQuery('#filter-form').submit();
  });
  
  $('select#user').on('change', function() { 
    jQuery('#filter-form').submit();
  });
  
  $('select#address').on('change', function() { 
    jQuery('#filter-form').submit();
  });
})
