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
});