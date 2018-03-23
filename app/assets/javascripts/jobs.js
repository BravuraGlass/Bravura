var BRAVURA = BRAVURA || {};

BRAVURA.showCustomerPanel = function showCustomerPanel(){
  $('#customerInfoPanel').toggleClass('hide');
};

BRAVURA.pickAddress = function pickAddress() {
  var address = $('#pick_address').data('address');
  var latitude = $('#pick_address').data('latitude');
  var longitude = $('#pick_address').data('longitude');
  $('#address').val(address);
  $('#latitude').val(latitude);
  $('#longitude').val(longitude);
}

BRAVURA.pickCustomerAddress = function pickCustomerAddress() {
  var address = $('#pick_customer_address').data('address');
  var address2 = $('#pick_customer_address').data('address2');

  $('#address').val(address);
  $('#address2').val(address2);

}
BRAVURA.onFocusStatus = function onFocusStatus() {
  BRAVURA.previousStatus = $('select#job_status').find(':selected').val();
};

BRAVURA.onStatusChange = function onJobStatusChange(element) {
  var selectedStatus = $(element).find(':selected').val();
  var hasOptions = false;
  if (BRAVURA.previousStatus != selectedStatus ) {
    //clean existing options
    $('#statusChangeModalBody').html('');
    //generate set of options based on the selected new status
    this.statusOptions.forEach(function(option) {
      // check if the option is associated
      if(option.status.name == selectedStatus){
        hasOptions = true;
        var optionTemplate = "<div class=\"checkbox\"><label> <input onchange=\"BRAVURA.validateChecklist();\" type=\"checkbox\" value=\"\">"
          +option.title+ "</label></div>"
        $('#statusChangeModalBody').append(optionTemplate);
      }
    }, this);

    // show the modal
    if(hasOptions){
      $('#statusChangeModal').modal({
          show: true,
          keyboard: false
      });

      $("#statusChangeModal").on('hidden.bs.modal', function () {
        if (!BRAVURA.statusChangeValid) {
          BRAVURA.restoreJobStatus();
        }
      });

      $('#statusChangeModalSaveButton').prop('disabled', true);
    }
  }
};

BRAVURA.validateChecklist = function validateChecklist(){
  // check if the number of checked inputs is equals to the number of existing inputs
  if ($('#statusChangeModalBody').find('input:checked').length === $('#statusChangeModalBody').find('input').length) {
    $('#statusChangeModalSaveButton').prop('disabled', false);
  } else {
    $('#statusChangeModalSaveButton').prop('disabled', true);
  }
};

BRAVURA.restoreJobStatus = function restoreJobStatus(){
  $('select#job_status').val(BRAVURA.previousStatus);
  $('select#job_status').trigger('change');
};

BRAVURA.closeStatusChangeModal = function closeStatusChangeModal() {
  BRAVURA.restoreJobStatus();
  BRAVURA.statusChangeValid = false;
  $('#statusChangeModal').modal('hide');
};

BRAVURA.saveStatusChangeModal = function saveStatusChange(){
  BRAVURA.statusChangeValid = true;
  $('#statusChangeModal').modal('hide');
};

BRAVURA.calculateBalance = function calculateBalance(){
  var deposit = $('input#job_deposit').val();
  var price = $('input#job_price').val();
  $('input#job_balance').val(price - deposit);
};

BRAVURA.filterActiveJob = function filterActiveJob(inactive){
  window.location.href = "?active="+inactive;
};


BRAVURA.showCreateCustomerModal = function showCreateCustomerModal() {
  $('#createCustomerModal').modal({
    show: true,
    keyboard: false
  });
};

BRAVURA.showJobDetails = function showJobDetails(element) {
  element.stopPropagation();
  var product_details = jQuery(element.target).data();

  BRAVURA.generateProductDetailsTable(product_details);

  $('#producDetail').modal({
    show: true,
    keyboard: false
  });
};


BRAVURA.generateProductDetailsTable = function generateProductDetailsTable(product) {
  var table = jQuery('#product-details-table');
  var statusesHtml = "";
  var currentProductIndex = -1;
  var currentRoom = "";
  var firstTime = true;

  // build the sections status
  for (var i in product.jobDetails) {
    section = product.jobDetails[i];
    var statusClass = section.status.toLowerCase().replace(" ", "-");
    if (firstTime) {
      currentRoom = section.product.room.name;
      currentProductIndex = section.product.product_index;
      statusesHtml += "<table class=\"table table-bordered table-hover table-striped responsive center\"><tr><td><div class=\"cell room\"><br/>" + section.product.room.name + "</div>";
      firstTime = false;
      statusesHtml += "<div class=\"cell\"> <span class=\"product-name\">" + section.product.name + "<br/></span>" + section.name + "<br/><span class=\"" + statusClass + "\">" + section.status + "</span></div>";
      continue;
    }


    // if its a new room
    if (currentRoom != section.product.room.name) {
      statusesHtml += "</td><tr/></table>";
      currentRoom = section.product.room.name;
      currentProductIndex = section.product.product_index;
      statusesHtml += "<table class=\"table table-bordered table-hover table-striped responsive center\"><tr><td><div class=\"cell room\"><br/>" + section.product.room.name + "</div>";
      statusesHtml += "<div class=\"cell\"> <span class=\"product-name\">" + section.product.name + "<br/></span>" + section.name + "<br/><span class=\"" + statusClass + "\">" + section.status + "</span></div>";
    } else {
      // if its a new product
      if (currentProductIndex != section.product.product_index ) {
        statusesHtml += "<div class=\"cell\"> <span class=\"product-name\">" + section.product.name + "<br/></span>" + section.name + "<br/><span class=\"" + statusClass + "\">" + section.status + "</span></div>";
        currentProductIndex = section.product.product_index;
      } else {
        statusesHtml += "<div class=\"cell\"><br/>" + section.name + "<br/><span class=\"" + statusClass+"\">" + section.status + "</span></div>";
      }
    }
  }
  statusesHtml += "</td></tr></table>";


  table.html("");
  table.append(statusesHtml);
};


BRAVURA.saveAndAssignCustomerToJob = function saveAndAssignCustomerToJob() {
  // do the save
  var customer = {
    contact_firstname: $("#customer_contact_firstname").val(),
    contact_lastname: $("#customer_contact_lastname").val(),
    company_name: $("#customer_company_name").val(),
    phone_number: $("#customer_phone_number").val(),
    phone_number2: $("#customer_phone_number2").val(),
    address: $("#customer_address").val(),
    address2: $("#customer_address2").val(),
    email: $("#customer_email").val(),
    email2: $("#customer_email2").val(),
    fax: $("#customer_fax").val(),
    notes: $("#customer_notes").val()
  };

  $.ajax({
    method: "POST",
    url: "/customers.json",
    data: { "customer": customer }
  })
    .done(function (cust) {
      // if a new customer was created
      if (cust.id) {
        var name = cust.contact_firstname + ' ' + cust.contact_lastname + ' - ' + cust.company_name;
        $('#job_customer_id').append('<option selected="true" value='+cust.id+'>'+name+'</option>');
        $('#createCustomerModal').modal('hide');
        
        var thelabel = "Customer address: "+cust.address+", Apt#: "+cust.address2;    
        $('#cust_address_label').text(thelabel);
        $('#pick_customer_address').data('address',cust.address);
        $('#pick_customer_address').data('address2',cust.address2);
        $('#cust_address_title').show();
      } else {
        alert('There was an error creating a new customer');
      }
    })
    .fail(function (response) {
      alert('There was an error creating a new customer');
    });

};

BRAVURA.closeJobDetailPanel = function closeJobDetailPanel() {
  $('#jobDetailPanel').hide();
  $('#jobListPanel').addClass('col-lg-12');
};


BRAVURA.uploadJobPictures = function uploadJobPictures(job_id) {
  $.ajax({
    method: "POST",
    url: "/jobs/"+job_id+"/image.json",
    data: new FormData(document.getElementById('image-form')),
    cache: false,
    contentType: false,
    processData: false
  })
  .done(function (response) {
    // if a new customer was created
    picture = response;
    imageHtml = "<div class=\"image-container\" id=\"job_picture_container_"+picture.id+"\">";
    imageHtml += "<a href=\""+ picture.image.url +"\" target=\"_blank\"> <img src=\""+picture.image.thumb.url+"\", class=\"job-image\"/></a>";
    imageHtml += "<a href=\"/jobs/"+job_id+"/image/"+picture.id+"\" class=\"btn trash delete_image\" data-confirm=\"Are you sure you want to delete this Image\" data-method=\"delete\" data-remote=\"true\" data-id=\""+picture.id+"\" >";
    imageHtml += "<i class=\"fa fa-trash-o\" aria-hidden=\"true\"></i> </a>";
    imageHtml += "</div>";
    $('#imageList').append(imageHtml);
    BRAVURA.bindDeleteImagesEvent();
    $('#picture_preview').hide();
  })
  .fail(function (response) {
    alert('There was an error uploading a new image');
  });
};

BRAVURA.bindDeleteImagesEvent = function bindDeleteImagesEvent(){
  $("a.delete_image").on("ajax:success", function (e, data, status, xhr) {
    if (status == "nocontent") {
      picture_id = $(this).data().id;
      $('#job_picture_container_' + picture_id).remove();
    } else {
      console.log('There was an error deleting picture:', data, status);
    }
  });
};

BRAVURA.readURL = function readURL(input) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (e) {
      $('#picture_preview').attr('src', e.target.result);
    }

    reader.readAsDataURL(input.files[0]);
    $('#picture_preview').show();
  } else {
    $('#picture_preview').hide();
  }
};

BRAVURA.checkStatus = function checkStatus(){
  $("form[id^=product_detail_job_]").submit()
}

BRAVURA.newDatatable = function newDatatable(){
  var dataTableAdvancedSettings = {
    searchHighlight: true,
    'paging':   true,  // Table pagination
    'ordering': true,  // Column ordering
    'info':     true,  // Bottom left status text
    'pageLength': 50,

    // Text translation options
    // Note the required keywords between underscores (e.g _MENU_)
    oLanguage: {
        sSearch:      'Search :',
        sLengthMenu:  '_MENU_ records per page',
        info:         'Showing page _PAGE_ of _PAGES_',
        zeroRecords:  'Nothing found - sorry',
        infoEmpty:    'No records available',
        infoFiltered: '(filtered from _MAX_ total records)'
    },
    // Datatable Buttons setup
    dom: '<"html5buttons"B>lTfgitp',
    buttons: [
        {extend: 'copy',  className: 'btn-sm' },
        {extend: 'csv',   className: 'btn-sm' },
        {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
        {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
        {extend: 'print', className: 'btn-sm' },
        {
            text: 'New',
            className: 'btn-sm btn btn-primary',
            action: function ( e, dt, node, conf ) {
              window.location.href = '/jobs/new';
            }
        }
    ],
    columnDefs: [
      { targets  : 'no-sort', orderable: false },
      { visible: false, targets: 'hide' }
    ],
    order: []
  };
  var table = $('#jobs_datatable').DataTable(dataTableAdvancedSettings);
  // table.on( 'draw', function () {
  //   var body = $( table.table().body() );
  //   body.unhighlight();
  //   body.highlight( table.search() );   
  // } );
}

// set the behavior on document ready
$(document).ready(function(){
  
  BRAVURA.onFocusStatus();
  BRAVURA.newDatatable();
  BRAVURA.statusChangeValid = false;
  $('#statusChangeModalCancelButton').on('click', function() { BRAVURA.closeStatusChangeModal(); });
  $('#statusChangeModalSaveButton').on('click', function() { BRAVURA.saveStatusChangeModal(); });
  $('select#job_status').on('change', function() { BRAVURA.onStatusChange(this); });
  $('select#job_status').on('focus', function() {  });
  $('input#job_price').on('keyup', function () {
    BRAVURA.calculateBalance();
  });
  $('input#job_deposit').on('keyup', function () {
    BRAVURA.calculateBalance();
  });
  $('input#show_active').on('change', function () {
    BRAVURA.filterActiveJob(this.checked);
  });
  $('#create_customer_button').on('click', function () {
    BRAVURA.showCreateCustomerModal();
  });
  $('#createCustomerSaveButton').on('click', function () { BRAVURA.saveAndAssignCustomerToJob(); });
  $('#closePanelButton').on('click', function () { BRAVURA.closeJobDetailPanel(); });

  $('.check_status').on('change', function(){ BRAVURA.checkStatus();});

  $('.job-detail-element').on('click', function (element) {
    // BRAVURA.showJobDetails(element);
  
    event.preventDefault();
    event.stopPropagation();
    
    var idval = $(this).attr("id").split("job-detail-")[1];
    window.location.href = "/jobs/"+idval+"/product_detail";
    
  });

  $('.filter-button').on('change', function () {
    jQuery('#filter-form').submit();
  });
  
  $('#job_customer_id').on('change', function () {
    $.ajax({
      method: "GET",
      url: "/customers/"+$('#job_customer_id').val()+".json"
    })
      .done(function (cust) {
        if (cust.id) {
          var thelabel = "Customer address: "+cust.address+", Apt#: "+cust.address2;    
          $('#cust_address_label').text(thelabel);
          $('#pick_customer_address').data('address',cust.address);
          $('#pick_customer_address').data('address2',cust.address2);
          $('#cust_address_title').show();
        } else {
          alert('There was an error loading customer');
        }
      })
      .fail(function (response) {
        alert('There was an error loading a new customer');
      });  
  });

  $('a.filter-button').on('click', function () {
    jQuery('#filter-form').submit();
  });

  $("#fileInput").change(function () {
    BRAVURA.readURL(this);
  });

  BRAVURA.bindDeleteImagesEvent();
  
  $('#appointment_today').on('click', function() { 
    $('#appointment_date').val(formatDate(todayServer()));
    setAppointment();
  });

  $('#appointment_tomorrow').on('click', function() { 
    $('#appointment_date').val(formatDatePlusOne(todayServer()));
    setAppointment();
  });

  $('#appointment_date').on('change', function() { setAppointment(); });

  $('#appointment_time').on('change', function() { setAppointment(); });

  $('#pick_address').on('click', function() { BRAVURA.pickAddress(); })
  $('#pick_customer_address').on('click', function() { BRAVURA.pickCustomerAddress(); })
  
  $('select#level').on('change', function() {
    jQuery('#level-form').submit();
  });
  
  $('.nextPrevLink').on('click', function () {
    var job_id = $(this).attr("id").split("job-id-")[1];
    
    $('#redirect_id').val(job_id);
    $('#job-form').submit();
  });
  
  $('.assign_to').on('change', function () {
    var job_id = $(this).attr("id").split("assign_to_job_")[1];
    
    $.ajax({
      method: "POST",
      url: "/jobs/"+job_id+"/assign.json",
      data: {user_id: $(this).val()},
      dataType: "json"
    })
    .done(function (response) {
      var msg = "Job #"+response.id+" no longer assigned to anybody"; 
      
      if (response.full_name != null) {
        msg = "Job #"+response.id+" was successfully assigned to "+response.full_name
      }  
      
      $('.errors_panel').html("<div class='notice'>"+msg+"</div>");
    }) 
    .fail(function (response) {
      alert('There was an error assigning a job, please try again');
    });
  });
    
  $('.set-appointment').on('click', function () {  
    var job_id = $(this).attr("id").split("-")[3];
    var mode = $(this).attr("id").split("-")[2];
    
    $.ajax({
      method: "POST",
      url: "/jobs/"+job_id+"/appointment.json",
      data: {mode: mode},
      dataType: "json"
    })
    .done(function (response) {
      var msg = "Appointment for job #"+ response.id +" was successfully updated"
      
      $('#dtime-'+response.id).html(response.dtime);
      $('.errors_panel').html("<div class='notice'>"+msg+"</div>");
    }) 
    .fail(function (response) {
      alert('There was an error updating appointment, please try again');
    }); 
  });
  
  $('.specify-appointment').on('click', function() {
    var job_id = $(this).attr("id").split("-")[2];
    var thedate = $("#dtime-"+job_id).text().split(" ")[0];
    var thetime = $("#dtime-"+job_id).text().split(" ")[1];
    
    $('#job_id').val(job_id);
    $('#date_appointment').val(thedate);
    $('#time_appointment').val(thetime);
    
    $('.modal-title').html("Specify Appointment for Job #"+job_id)
    $('#appointmentMasterModal').modal({
      show: true,
      keyboard: false
    });
  }); 
  
  $('#appointmentModalSaveButton').on('click', function() {
    var mode = "specify"
    var thedate = $("#date_appointment").val();
    var thetime = $("#time_appointment").val();

    $.ajax({
      method: "POST",
      url: "/jobs/"+$('#job_id').val()+"/appointment.json",
      data: {mode: mode, date: thedate, time: thetime},
      dataType: "json"
    })
    .done(function (response) {
      $('#appointmentMasterModal').modal('hide');
      var msg = "Appointment for job #"+ response.id +" was successfully updated"
      
      $('#dtime-'+response.id).text(response.dtime);
      $('.errors_panel').html("<div class='notice'>"+msg+"</div>");
    }) 
    .fail(function (response) {
      $('#appointmentMasterModal').modal('hide');
      alert('There was an error updating appointment, please try again');
    }); 
  });  
  
  function formatDate(date) {
    var day = date.getDate();
    var monthIndex = date.getMonth() + 1;
    var year = date.getFullYear();
    
    if (monthIndex.toString().length == 1) {
      monthIndex = "0" + monthIndex.toString()
    }
    
    return year + '-' + monthIndex + '-' + (day < 10 ? '0' + day : day);
  }

  function formatDatePlusOne(date) {
    var day = date.getDate() + 1;
    var monthIndex = date.getMonth() + 1;
    var year = date.getFullYear();
    
    if (monthIndex.toString().length == 1) {
      monthIndex = "0" + monthIndex.toString()
    }
  
    return year + '-' + monthIndex + '-' + (day < 10 ? '0' + day : day);
  }

  function todayServer() {
    var offset = $('#appointment').data('offset');
    var date = new Date();
    var n = date.getTimezoneOffset() / 60;
    var utcDate = new Date(date.toUTCString());
    utcDate.setHours(utcDate.getHours() + offset + n);
    var usDate = new Date(utcDate);

    return usDate;
  }

  function setAppointment() {
    var time = $('#appointment_time').val();
    var date = $('#appointment_date').val();
    datetime = date + 'T' + time;
    $('#appointment').val(datetime);
  }

});
