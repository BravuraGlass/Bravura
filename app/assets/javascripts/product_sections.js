var BRAVURA = BRAVURA || {};

BRAVURA.materialWidth = function materialWidth(){
  return parseInt(document.getElementById("product_section_size_a").value) || 200
}
BRAVURA.materialHeight = function materialHeight(){
  return parseInt(document.getElementById("product_section_size_b").value) || 200
}

BRAVURA.resetCanvas = function resetCanvas(){
  var number1 = BRAVURA.materialWidth() ;
  var number2 = BRAVURA.materialHeight();
  max = number1 > number2 ? number1 : number2
  more_200 = max >= 200 ? false : true
  $("#canvas-wrapper").html('')
  $("#canvas-wrapper").html('<canvas id="canvas" width="'+number1/max*200+'" height="'+number2/max*200+'"><img src="https://user-images.githubusercontent.com/116856/33920682-36c309e8-dffa-11e7-8979-7da6f97df992.jpg"/></canvas>')
}

BRAVURA.draw = function draw(){
  var number1 = BRAVURA.materialWidth() ;
  var number2 = BRAVURA.materialHeight();
  max = number1 > number2 ? number1 : number2
  more_200 = max >= 200 ? false : true
  var c = document.getElementById("canvas");
  var ctx = c.getContext("2d");
  ctx.clearRect(0, 0, c.width, c.height);
  ctx.strokeStyle = BRAVURA.randomColor;
  ctx.lineWidth = 4;
  ctx.strokeRect(0, 0, number1/max*200, number2/max*200);
};

// set the behavior on document ready
$(document).ready(function(){

  BRAVURA.resetCanvas()
  BRAVURA.draw();

 $('.change-size').on('blur', function(){
    BRAVURA.resetCanvas()
    BRAVURA.draw();
 })


})