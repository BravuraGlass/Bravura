// Custom jQuery
// -----------------------------------


(function(window, document, $, undefined){

  $(function(){

    // document ready

    var dataTableAdvancedSettings = {
        'paging':   true,  // Table pagination
        'ordering': true,  // Column ordering
        'info':     true,  // Bottom left status text
        "pageLength": 50,
        'responsive': true, // https://datatables.net/extensions/responsive/examples/
        // Text translation options
        // Note the required keywords between underscores (e.g _MENU_)
        oLanguage: {
            sSearch:      'Search all columns:',
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

      // apply the basic datatable settings
      $('.datatable-basic').dataTable(dataTableBasicSettings);

      // apply the select2 component
      $('.select-bootstrap').select2({
        theme: 'bootstrap'
      });

      $('[data-masked]').inputmask();

      // $('.date').datetimepicker();

  });

})(window, document, window.jQuery);
