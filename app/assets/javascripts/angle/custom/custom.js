// Custom jQuery
// -----------------------------------


(function(window, document, $, undefined){
  function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
  }

  function getCookie(cname) {
      var name = cname + "=";
      var ca = document.cookie.split(';');
      for(var i = 0; i < ca.length; i++) {
          var c = ca[i];
          while (c.charAt(0) == ' ') {
              c = c.substring(1);
          }
          if (c.indexOf(name) == 0) {
              return c.substring(name.length, c.length);
          }
      }
      return "";
  }

  function checkCookie() {
      var user = getCookie("username");
      if (user != "") {
          alert("Welcome again " + user);
      } else {
          user = prompt("Please enter your name:", "");
          if (user != "" && user != null) {
              setCookie("username", user, 365);
          }
      }
  }

  $(function(){


    // document ready

    var dataTableAdvancedSettings = {
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
            {extend: 'print', className: 'btn-sm' }
        ],
        columnDefs: [
          { targets  : 'no-sort', orderable: false },
          { visible: false, targets: 'hide' }
        ],
        order: []
      };
      // apply the advanced datatable settings
      $('.datatable').dataTable(dataTableAdvancedSettings);

      var dataTableBasicSettings = dataTableAdvancedSettings;
      dataTableBasicSettings.buttons = [];

      var dataTableFOSettings  = {
        'paging':   false,  // Table pagination
        'info':     false,
        // Datatable Buttons setup
        dom: '<"html5buttons"B>lTfgitp',
        buttons: [
            {extend: 'copy',  className: 'btn-sm' },
            {extend: 'csv',   className: 'btn-sm' },
            {extend: 'excel', className: 'btn-sm', title: 'XLS-File'},
            {extend: 'pdf',   className: 'btn-sm', title: $('title').text() },
            {extend: 'print', className: 'btn-sm' }
        ],
        columnDefs: [
          { targets  : 'no-sort', orderable: false },
          { visible: false, targets: 'hide' }
        ],
        order: []
      };

      // apply the basic datatable settings
      $('.datatable-basic').dataTable(dataTableBasicSettings);

      $('.datatable-fo').dataTable(dataTableFOSettings);

      // apply the select2 component
      $('.select-bootstrap').select2({
        theme: 'bootstrap'
      });
      $(".select-bootstrap").each(function (e) {
        $(".select-bootstrap").eq(e).next(".select2").find(".select2-selection").focus(function() {
           $(".select-bootstrap").eq(e).select2("open");
        })
      })

      $('[data-masked]').inputmask();

      // $('.date').datetimepicker();
      var url = new URL(window.location.href);
      var scrollTo = url.searchParams.get("scroll");

      if(scrollTo){
        $('html, body').animate({ scrollTop: getCookie("scroll")||0 }, 0.5);
      }

      $( document ).scroll(function() {
        var scrollTop = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
        $('#content_wrapper').data('offset-top', scrollTop)
        if($('#scroll').length == 0 || $('#scroll').hasClass('set_offset')){
          setCookie('scroll',scrollTop,1)
        }
      });

  });

})(window, document, window.jQuery);
