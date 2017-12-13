var BRAVURA = BRAVURA || {};

BRAVURA.submitFormFilter = function submitFormFilter(){
  jQuery('#filter-form').submit();
};

BRAVURA.getQueryString =  function getQueryString( field, url ) {
  var href = url ? url : window.location.href;
  var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
  var string = reg.exec(href);
  return string ? string[1] : null;
};

BRAVURA.getCategory = function getCategory() {
  if (typeof BRAVURA.getQueryString('category') != 'undefined' && 
             BRAVURA.getQueryString('category') != null){
    return BRAVURA.getQueryString('category')
  }else{
    return ''
  }
}

BRAVURA.getRemoteAddress = function getRemoteAddress() {
  BRAVURA.getQueryString('category');
}

BRAVURA.selectAddress = function selectAddress() {
  text = $("#address option:selected").text();
  val = $("#address option:selected").val();
  if(text != 'All'){
    formated_text = text.replace('('+val+')','');
    $('#search_address').val($.trim(formated_text));
  }
}

BRAVURA.getVarUrl = function getVarUrl() {
  var category = BRAVURA.getCategory();
  if(category == "job"){
    return "/jobs.json?filter=all&category="+category+"&active=true&address=%QUERY"
  }else{
    return "/jobs.json?filter=all&category="+category+"&active=true&address=%QUERY"
  }
}

BRAVURA.filterButton = function filterButton(el) {
  if (el.attr("id") == 'filter-all') {
    $("#date").val(null);
  } else if (el.attr("id") == 'filter-today') {
    $("#date").val($("#today_str").val());
  } else if  (el.attr("id") == 'filter-yesterday') {
    $("#date").val($("#yesterday_str").val());
  }  
    
}

BRAVURA.searchAdress = function searchAddress(item) {
  $('#search_address').typeahead('val',item.address);
  $('select#address').val(item.id);
  BRAVURA.submitFormFilter();
}
$(document).ready(function(){
  var category = BRAVURA.getCategory();
  var var_url = BRAVURA.getVarUrl();
  var address = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: var_url,
      wildcard: "%QUERY"
    }
  });

  $('#search_address').typeahead({
    hint: true,
    highlight: true,
    minLength: 1,
    showHintOnFocus: true,
    items: 30
  },
  {
    source: address,
    templates: {
      empty: [
        '<div class="empty-message">',
          'unable to find any address that match the current query',
        '</div>'
      ].join('\n'),
      suggestion: function(data){
        return `<li>(${data.id}) ${data.address}</li>`
      }
    }
  });

  $('#search_address').on('typeahead:selected', function(evt, item) {
    BRAVURA.searchAdress(item)
  })

  $('.filter-button').on('change', function () {
    BRAVURA.filterButton($(this));
    BRAVURA.submitFormFilter();
  });


  $('a.filter-button').on('click', function () {
    BRAVURA.submitFormFilter();
  });
  
  $('select#user').on('change', function() { 
    BRAVURA.submitFormFilter();
  });

  $('select#address').on('change', function() {
    BRAVURA.selectAddress();
    BRAVURA.submitFormFilter();
  });

  
  $('select#status').on('change', function() { 
    BRAVURA.submitFormFilter();
  });
})
