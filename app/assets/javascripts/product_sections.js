var BRAVURA = BRAVURA || {};

BRAVURA.materialWidth = function materialWidth(id){
  if($("#product_section_size_a_"+id).length){
    return parseInt(document.getElementById("product_section_size_a_"+id).value) || 200
  }
}
BRAVURA.materialHeight = function materialHeight(id){
  if($("#product_section_size_b_"+id).length){
    return parseInt(document.getElementById("product_section_size_b_"+id).value) || 200
  }
}

BRAVURA.resetCanvas = function resetCanvas(id){
  var number1 = BRAVURA.materialWidth(id) ;
  var number2 = BRAVURA.materialHeight(id);
  size = $('#product_section_size_type_'+id).val();
  max = number1 > number2 ? number1 : number2
  more_200 = max >= 200 ? false : true
  if(size ==''||size=='box'){
    $("#wrapper-canvas-"+id).html('')
    $("#wrapper-canvas-"+id).html('<canvas id="canvas-'+id+'" width="'+number1/max*200+'" height="'+number2/max*200+'"><img src="https://user-images.githubusercontent.com/116856/33920682-36c309e8-dffa-11e7-8979-7da6f97df992.jpg"/></canvas>')
  }else if(size=='oval'){
    $("#wrapper-canvas-"+id).html('')
    $("#wrapper-canvas-"+id).html('<canvas id="canvas-'+id+'" width="'+number1/max*200+'" height="'+number2/max*200+'"><img src="https://user-images.githubusercontent.com/5506768/34172350-53625e12-e524-11e7-9dec-71be74dfb9b2.png"/></canvas>')
  }
}

BRAVURA.draw = function draw(id){
  if($('#canvas-'+id).length){
    size = $('#product_section_size_type_'+id).val();
    var number1 = BRAVURA.materialWidth(id) ;
    var number2 = BRAVURA.materialHeight(id);
    max = number1 > number2 ? number1 : number2
    more_200 = max >= 200 ? false : true
    var c = document.getElementById("canvas-"+id);
    var ctx = c.getContext("2d");

    if(size ==''||size=='box'){
      ctx.clearRect(0, 0, c.width, c.height);
      ctx.strokeStyle = BRAVURA.randomColor;
      ctx.lineWidth = 4;
      ctx.strokeRect(0, 0, number1/max*200, number2/max*200);
    }else if(size == 'oval'){
      ctx.setLineDash([])
      ctx.beginPath();
      ctx.ellipse((number1/max*100), (number2/max*100), number1/max*100/2, number2/max*100/2, 0, 0,  2* Math.PI);
      ctx.lineWidth = 2;
      ctx.stroke();
    }

  }
};


BRAVURA.setPlAll = function setPlAll(id){
  if($('#set_pl_'+id).prop('checked')){
    $('.e_product_section_id_'+id).each(function(e){
      $(this).select2("val", $('#set_pl_'+id).val()); 
    })
  }else{
    $('.e_product_section_id_'+id).each(function(e){
      $(this).select2("val", ' '); 
    })
  }

}

BRAVURA.changeSizeType = function changeSizeType(id){
  size = $('#product_section_size_type_'+id).val();
  seam_id = $('#seam_id').val()

  if(size == ''){
    $('#product_section_edge_type_a_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_a_id_'+id).attr("required", true)
    if($('#product_section_edge_type_a_id_'+id).val() == null){$('#product_section_edge_type_a_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_b_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_b_id_'+id).attr("required", true)
    if($('#product_section_edge_type_b_id_'+id).val() == null){$('#product_section_edge_type_b_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_c_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_c_id_'+id).attr("required", true)
    if($('#product_section_edge_type_c_id_'+id).val() == null){$('#product_section_edge_type_c_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_d_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_d_id_'+id).attr("required", true)
    if($('#product_section_edge_type_d_id_'+id).val() == null){$('#product_section_edge_type_d_id_'+id).select2('val',seam_id);}
  }else if(size == 'box'){
    $('#product_section_edge_type_a_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_a_id_'+id).attr("required", true)
    if($('#product_section_edge_type_a_id_'+id).val() == null){$('#product_section_edge_type_a_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_b_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_b_id_'+id).attr("required", true)
    if($('#product_section_edge_type_b_id_'+id).val() == null){$('#product_section_edge_type_b_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_c_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_c_id_'+id).attr("required", true)
    if($('#product_section_edge_type_c_id_'+id).val() == null){$('#product_section_edge_type_c_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_d_id_'+id).parent().removeClass('hidden')
    $('#product_section_edge_type_d_id_'+id).attr("required", true)
    if($('#product_section_edge_type_d_id_'+id).val() == null){$('#product_section_edge_type_d_id_'+id).select2('val',seam_id);}
  }else if(size == 'oval'){
    if($('#product_section_edge_type_a_id_'+id).val() == null){$('#product_section_edge_type_a_id_'+id).select2('val',seam_id);}
    $('#product_section_edge_type_b_id_'+id).select2("val", ' '); 
    $('#product_section_edge_type_b_id_'+id).attr('required', false)
    $('#product_section_edge_type_b_id_'+id).parent().addClass('hidden')
    $('#product_section_edge_type_c_id_'+id).select2("val", ' '); 
    $('#product_section_edge_type_c_id_'+id).attr('required', false)
    $('#product_section_edge_type_c_id_'+id).parent().addClass('hidden')
    $('#product_section_edge_type_d_id_'+id).select2("val", ' '); 
    $('#product_section_edge_type_d_id_'+id).attr('required', false)
    $('#product_section_edge_type_d_id_'+id).parent().addClass('hidden')
  }
}

BRAVURA.initSizeType = function initSizeType(id){
  size = $('#product_section_size_type_'+id).val();
  if(size == 'oval'){
    if($('#product_section_edge_type_b_id_'+id).val() == null){$('#product_section_edge_type_b_id_'+id).select2('val',seam_id)}
    $('#product_section_edge_type_b_id_'+id).attr('required', false)
    $('#product_section_edge_type_b_id_'+id).parent().addClass('hidden')
    if($('#product_section_edge_type_c_id_'+id).val() == null){$('#product_section_edge_type_c_id_'+id).select2('val',seam_id)}
    $('#product_section_edge_type_c_id_'+id).attr('required', false)
    $('#product_section_edge_type_c_id_'+id).parent().addClass('hidden')
    if($('#product_section_edge_type_d_id_'+id).val() == null){$('#product_section_edge_type_d_id_'+id).select2('val',seam_id)}
    $('#product_section_edge_type_d_id_'+id).attr('required', false)
    $('#product_section_edge_type_d_id_'+id).parent().addClass('hidden')
  }
}

// set the behavior on document ready
$(document).ready(function(){

  if($('.product_section_id').length){


    $('.product_section_id').each(function(e){
      id = $(this).val();
      BRAVURA.resetCanvas(id)
      BRAVURA.draw(id);
      BRAVURA.initSizeType(id);
      
      if ($('#product_section_edge_type_a_id_'+id).val() == $('#set_pl_'+id).val() &&
          $('#product_section_edge_type_b_id_'+id).val() == $('#set_pl_'+id).val() &&
          $('#product_section_edge_type_c_id_'+id).val() == $('#set_pl_'+id).val() && 
          $('#product_section_edge_type_d_id_'+id).val() == $('#set_pl_'+id).val()){
        $('#set_pl_'+id).prop('checked',true);
      }else{
        $('#set_pl_'+id).prop('checked',false);
      }

    })

  }

  $('input[id^=set_pl_]').on('change', function(){
    id = $(this).data('id');
    BRAVURA.setPlAll(id)
  })

  $('.change-size').on('blur', function(){
    id = $(this).data('id')
    BRAVURA.resetCanvas(id)
    BRAVURA.draw(id);
  })

  $('select[id^=product_section_size_type_]').on('select2:select', function (e) {
    id = $(this).data('id')
    BRAVURA.changeSizeType(id)
    BRAVURA.resetCanvas(id)
    BRAVURA.draw(id);
  });
})