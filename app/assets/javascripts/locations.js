var BRAVURA = BRAVURA || {};

BRAVURA.checkAllCheked = function checkAllCheked(){
  var count_checked = $('input[class=bj-filter-map]:checkbox:checked').length == 3 ;
  if(count_checked){
    BRAVURA.toggleShowAll(true)
  }else{
    BRAVURA.toggleShowAll(false)
  }
};

BRAVURA.toggleShowAll = function toggleShowAll(value){
  $('#show_all').prop('checked', value);
};

BRAVURA.toggleCheckWorkers = function toggleCheckWorkers(value){
  $('#show_workers').prop('checked', value);
};

BRAVURA.toggleCheckWorker = function toggleCheckWorker(value){
  $('.bj-filter-map-worker').each(function(){
    $(this).prop('checked', value);
  });
};

BRAVURA.checkWorkerCheked = function checkWorkerCheked(){
  var count = $('input[class=bj-filter-map-worker]:checkbox').length;
  var count_checked = $('input[class=bj-filter-map-worker]:checkbox:checked').length ;
  if(count_checked == 0){
    BRAVURA.toggleCheckWorkers(false)
  }else{
    BRAVURA.toggleCheckWorkers(true)
  }
};


// set the behavior on document ready
$(document).ready(function(){
  
  $('#show_workers').on('click', function() { 
    BRAVURA.checkAllCheked()
    if($('#show_workers').is(':checked')){
      BRAVURA.toggleCheckWorker(true)
    }else{
      BRAVURA.toggleCheckWorker(false)
    }
  });

  $('.bj-filter-map-worker').each(function(){
    $(this).on('click', function(){
      BRAVURA.checkWorkerCheked()
    })
  });

});