// jQuery plugin to make a table into a lazy-ajax-loading table
// with a "load more" button, and a loading indicator.
// Structure:
//	#object_id
//		%table
//			%thead
//				...
//			%tbody
//				[ajax loaded content]		
//		.loading
//		.more
// Calling:
//	$("#object_id").paginated_table("url_to_load_data");
// Server-side:
//	The loading url should accept 'limit', and 'offset' parameters
// 	and return the appropriate data in html table row format.

(function($) {

	$.fn.paginated_table = function(data_url, limit, start_limit) {
		// Save wrapped object as 'o'.
		var o = this;
		// If no wrapped object, return the empty wrap.
	  if (!o.length) { return o; }
		// Define a default limit.
		if (typeof limit == "undefined") {
		    var limit = 10;
		 }
		if (typeof start_limit == "undefined") {
		    var start_limit = 10;
		 }

		// Hide the 'more' button.
		$(".more", o).hide();

		// Load the first set of data.
		$.get(data_url, {limit : start_limit, offset : 0}, function(html){
			if(html == ''){
				o.parent().hide();
			}
			else{
				// Hide the loading indicator.
	      $(".loading", o).hide();
				// Append the returned html to the table.
	      $("table", o).append(html);
				// Show the 'more' button if at least 'limit' items were loaded.
				var items_loaded = $(html).filter("tr").length
				if(items_loaded >= start_limit){
					$(".more", o).show();
				}
			}
    }); 

		// When the 'more' button is clicked.
    $(".more", o).click(function(){
			// Hide the 'more' button
			$(".more", o).hide();
			// Show the loading indicator.
      $(".loading", o).show();
			// Load the next set of data.
      $.get( data_url, {limit : limit, offset : $("tbody tr", o).length}, function(html){
				// Hide the loading indicator.
				$(".loading", o).hide();
				// Append the returned html to the table.
        $("table", o).append(html);
				// Show the 'more' button if at least 'limit' items were loaded.
				var items_loaded = $(html).filter("tr").length
				if(items_loaded >= limit){
					$(".more", o).show();
				}
      });
      
			return false;
    });
		
		return o;		
	};

})(jQuery);
