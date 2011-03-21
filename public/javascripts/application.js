// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
  $('input.ui-date-picker').datepicker({ dateFormat: 'yyyy-mm-dd' });
  $('input.ui-datetime-picker').datetimepicker({ dateFormat: 'yyyy-mm-dd', timeFormat: 'HH:mm tt'  });
});

