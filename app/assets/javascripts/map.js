var BRAVURA = BRAVURA || {};

BRAVURA.clearDate = function clearDate(){
  $('#date').val('');
};

BRAVURA.defaultDate = function defaultDate(){
  $('#date').val($('#date').data('today'));
};

BRAVURA.checkAllCheked = function checkAllCheked(){
  var count_checked = $('input[class=bj-filter-map]:checkbox:checked').length == 2 ;
  if(count_checked){
    BRAVURA.toggleShowAll(true)
    BRAVURA.clearDate()
  }else{
    BRAVURA.toggleShowAll(false)
    BRAVURA.defaultDate()
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

BRAVURA.submitForm = function submitForm(){
  $('#form-map').submit()
};

// set the behavior on document ready
$(document).ready(function(){
  $('#show_all').on('click', function() {
    if($(this).is(':checked')){
      BRAVURA.clearDate()
      BRAVURA.toggleCheckTask(true)
      BRAVURA.toggleCheckJob(true)
    }else{
      BRAVURA.toggleCheckTask(false)
      BRAVURA.toggleCheckJob(false)
      BRAVURA.defaultDate()
    }
  });

  $('#show_tasks').on('click', function() { 
    BRAVURA.checkAllCheked()
  });

  $('#show_jobs').on('click', function() { 
    BRAVURA.checkAllCheked()
  });
});