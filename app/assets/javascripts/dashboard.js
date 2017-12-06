$(document).ready(function(){
  $('.section_detail_select_none').on('change', function() {
    var theid = $(this).attr("id").split("_")[2]
    
    $.ajax({
      method: "PUT",
      url: "/product_sections/"+theid,
      data: {product_section: {status: $(this).val()}},
      dataType: "json"
    })
    .done(function(data){
      location.href =  "/dashboard/sections_detail?status="+$('#section_detail_'+theid+' :selected').text();
    })
    .fail(function(response){
      alert('There was an error saving the product');
    });
  })  
  
  $('.forder_detail_select_none').on('change', function() {
    var theid = $(this).attr("id").split("_")[2]
    
    $.ajax({
      method: "PUT",
      url: "/fabrication_orders/"+theid,
      data: {fabrication_order: {status: $(this).val()}},
      dataType: "json"
    })
    .done(function(data){
      location.href =  "/dashboard/forders_detail?status="+$('#forder_detail_'+theid+' :selected').text();
    })
    .fail(function(response){
      alert('There was an error saving the product');
    });
  })  
  
  $('.job_detail_select_none').on('change', function() {
    var theid = $(this).attr("id").split("_")[2]
    
    $.ajax({
      method: "PUT",
      url: "/jobs/"+theid,
      data: {job: {status: $(this).val()}},
      dataType: "json"
    })
    .done(function(data){
      location.href =  "/dashboard/jobs_detail?status="+$('#job_detail_'+theid+' :selected').text();
    })
    .fail(function(response){
      alert('There was an error saving the product');
    });
  })  
  
  $('#change_all_section').on('change', function() {
    $(".section_detail_select option[value='"+$(this).val()+"'").prop('selected', true) 
  })

  $(document).on('change','.on_change_submit',function(){
    $('#form_on_change_submit').submit();
  })
  
  
  $('#change_all_job').on('change', function() {
    $(".job_detail_select option[value='"+$(this).val()+"'").prop('selected', true) 
  })

  $('#change_all_room').on('change', function() {
    $(".room_detail_select option[value='"+$(this).val()+"'").prop('selected', true) 
  })

  $('#change_all_product').on('change', function() {
    $(".product_detail_select option[value='"+$(this).val()+"'").prop('selected', true) 
  })  
  
  $('#change_all_forder').on('change', function() {
    $(".forder_detail_select option[value='"+$(this).val()+"'").prop('selected', true) 
  })
});