(function($) {
	
	$.fn.source_chart = function(data) {
	
	  if (!this.length) { return this; }
		return new Highcharts.Chart({
			series: [{
	       type: 'pie',
	       data: data
	    }],
			chart: {
	     renderTo: this.attr('id'),
	     plotBackgroundColor: null,
	     plotBorderWidth: null,
	     plotShadow: false,
	     marginLeft: 100,
	     marginRight: 100,
	     marginBottom: 50,
	     marginTop: 50
	  	},
			title: {
		     text: ''
		  },
		  tooltip: {
		     formatter: function() {
		        return '<b>'+ this.point.name +'</b>: '+ this.y;
		     }
		  },
		  credits: {
		    enabled: false
		  },
		  plotOptions: {
		     pie: {
		        allowPointSelect: true,
		        cursor: 'pointer',
		        dataLabels: {
		           enabled: true,
		           color: '#000000',
		           connectorColor: '#000000',
		           formatter: function() {
		              return '<b>'+ this.point.name +'</b>: '+ this.y;
		           }
		        }
		     }
		  }
		});
	
	};
	
})(jQuery);