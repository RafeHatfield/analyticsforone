(function($) {
	
	$.fn.daterangepicker = function() {
	
	  if (!this.length) { return this; }
	
		return this.datepicker({
			numberOfMonths: 1,
    	minDate: new Date(2011, 1-1, 1),
    	onSelect: function( selectedDate ) {
      	var option = this.id == "start_date" ? "minDate" : "maxDate",
      	instance = $( this ).data( "datepicker" ),
      	date = $.datepicker.parseDate(
      		instance.settings.dateFormat ||
      		$.datepicker._defaults.dateFormat,
      		selectedDate, instance.settings 
				);
      	dates.not( this ).datepicker( "option", option, date );
    })
	
	};
	
})(jQuery);