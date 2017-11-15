$(document).ready(function(){
  $('.section_detail_select').on('change', function() {
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
  
  $('.forder_detail_select').on('change', function() {
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
  
  $('.job_detail_select').on('change', function() {
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
});