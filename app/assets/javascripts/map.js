var BRAVURA = BRAVURA || {};

BRAVURA.clearDate = function clearDate(){
  $('#date').val('');
};

BRAVURA.defaultDate = function defaultDate(){
  $('#date').val($('#date').data('today'));
};

BRAVURA.checkAllCheked = function checkAllCheked(){
  var count_checked = $('input[class=bj-filter-map]:checkbox:checked').length == 3 ;
  if(count_checked){
    BRAVURA.toggleShowAll(true)
    BRAVURA.clearDate()
  }else{
    BRAVURA.toggleShowAll(false)
    BRAVURA.defaultDate()
  }
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

BRAVURA.toggleShowAll = function toggleShowAll(value){
  $('#show_all').prop('checked', value);
};

BRAVURA.toggleCheckTask = function toggleCheckTask(value){
  $('#show_tasks').prop('checked', value);
};

BRAVURA.toggleCheckJob = function toggleCheckJob(value){
  $('#show_jobs').prop('checked', value);
};


BRAVURA.toggleCheckWorkers = function toggleCheckWorkers(value){
  $('#show_workers').prop('checked', value);
};

BRAVURA.submitForm = function submitForm(){
  $('#form-map').submit()
};

BRAVURA.toggleCheckWorker = function toggleCheckWorker(value){
  $('.bj-filter-map-worker').each(function(){
    $(this).prop('checked', value);
  });
};

// set the behavior on document ready
$(document).ready(function(){
  $('#show_all').on('click', function() {
    if($(this).is(':checked')){
      BRAVURA.clearDate()
      BRAVURA.toggleCheckTask(true)
      BRAVURA.toggleCheckJob(true)
      BRAVURA.toggleCheckWorkers(true)
      $('.bj-filter-map-worker').each(function(){
        BRAVURA.toggleCheckWorker(true)
      });
    }else{
      BRAVURA.toggleCheckTask(false)
      BRAVURA.toggleCheckJob(false)
      BRAVURA.toggleCheckWorkers(false)
      BRAVURA.defaultDate()
      $('.bj-filter-map-worker').each(function(){
        BRAVURA.toggleCheckWorker(false)
      });
    }
  });

  $('#show_tasks').on('click', function() { 
    BRAVURA.checkAllCheked()
  });

  $('#show_jobs').on('click', function() { 
    BRAVURA.checkAllCheked()
  });

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