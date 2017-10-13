var BRAVURA = BRAVURA || {};

BRAVURA.showCustomerPanel = function showCustomerPanel(){
  $('#customerInfoPanel').toggleClass('hide');
};

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
    .done(function (response) {
      // if a new customer was created
      if (response.id) {
        var name = response.contact_firstname + ' ' + response.contact_lastname + ' - ' + response.company_name;
        $('#job_customer_id').append('<option selected="true" value='+response.id+'>'+name+'</option>');
        $('#createCustomerModal').modal('hide');
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
    console.log(response.responseText);
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


// set the behavior on document ready
$(document).ready(function(){
  BRAVURA.onFocusStatus();
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

  $('.job-detail-element').on('click', function (element) {
    BRAVURA.showJobDetails(element);
  });

  $('.filter-button').on('change', function () {
    jQuery('#filter-form').submit();
  });

  $('a.filter-button').on('click', function () {
    jQuery('#filter-form').submit();
  });

  $("#fileInput").change(function () {
    BRAVURA.readURL(this);
  });

  BRAVURA.bindDeleteImagesEvent();

});
