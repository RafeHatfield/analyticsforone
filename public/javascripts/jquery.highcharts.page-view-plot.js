(function($) {

	$.fn.page_view_plot = function(data, utc_start_time_milliseconds) {

	  if (!this.length) { return this; }
	
		var milliseconds_in_day = 86400000;
	
		if(data.length < 6){
			// Show a bar chart with 1-day fixed tick intervals if there are less than 6 days of data.
			// This fixes a highcharts problem where it displays time instead of day.
			var chart = new Highcharts.Chart({
				chart: {
			    renderTo: this.attr('id'),
			    defaultSeriesType: 'column',
			    marginRight: 130,
			    marginBottom: 85,
			  },
				title: false,
			  legend: {
			    enabled: false
			  },
			  xAxis: {
			    type: 'datetime',
					tickInterval: 1000 * 3600 * 24
			  },
			  yAxis: {
			    title: false,
			    min: 0
			  },
			  tooltip: {
			    formatter: function() {
			      return Highcharts.dateFormat("%B %e %Y", this.x) + ': ' + this.y;
			    }
			  },
			  credits: {
			    enabled: false
			  },
				series: [{
		      name: 'series',
		      pointInterval: milliseconds_in_day,
		      pointStart: utc_start_time_milliseconds,
		      data: data
		    }]
	
			});
			
		} else { 
			// Display a spline chart with variable tick intervals.
			var chart =  new Highcharts.Chart({
				chart: {
			    renderTo: this.attr('id'),
			    defaultSeriesType: 'spline',
			    marginRight: 130,
			    marginBottom: 85,
			  },
				title: false,
			  legend: {
			    enabled: false
			  },
			  xAxis: {
			    type: 'datetime'
			  },
			  yAxis: {
			    title: false,
			    min: 0
			  },
			  tooltip: {
			    formatter: function() {
			      return Highcharts.dateFormat("%B %e %Y", this.x) + ': ' + this.y;
			    }
			  },
			  credits: {
			    enabled: false
			  },
				series: [{
		      name: 'series',
		      pointInterval: milliseconds_in_day,
		      pointStart: utc_start_time_milliseconds,
		      data: data
		    }]
	
			}); 
		
	}
	
	return chart;
	
	};

})(jQuery);
