// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
  $('input.ui-date-picker').datepicker({ dateFormat: 'mm/dd/yyyy' });
  $('input.ui-datetime-picker').datetimepicker({ dateFormat: 'mm/dd/yyyy', timeFormat: 'HH:mm tt'  });
});

