
(function () {
  'use strict'
	resizeMyPopUp();
	var thisUrlInfo = getCurrentUrlInfo();
	if( thisUrlInfo.dType ){
		d3ATGCBarChart(thisUrlInfo.dType);
	}
})()

function closePopUpWindow(){
	window.close();
}

function d3ATGCBarChart(dType){
	var dataList = null;
	switch(dType){
		case "orgn":{
			dataList = gcat_bar_chart;
		};break;
		case "trim":{
			dataList = trimmed_gcat_bar_chart;
		};break;
		case "umi":{
			dataList = umi_gcat_bar_chart;
		};break;
	}
	var dataAllCnt = dataList.gc.length;
	var allChartNum = dataAllCnt / 20;
	
	var divIdx = 0;
	var htmlStr = "";
	for(var chartNum = 0; chartNum < allChartNum; chartNum++){
		if(chartNum%2==0){
			divIdx = chartNum+1;
			htmlStr = '<div class="w3-row w3-margin-top"><div class="w3-col l6"><div id="atgc_bar_chart_div_'+divIdx+'"></div></div><div class="w3-col l6"><div id="atgc_bar_chart_div_'+(divIdx+1)+'"></div></div></div>';
			$("#popup_chart_area_div").append(htmlStr);
		}
	}
	
	var eachBarHeight = 0;
	var chartSTIdx = 0;
	var chartLTIdx = chartSTIdx+20;
	var divIdStr = "atgc_bar_chart_div_";
	var dMxVal = Math.max.apply(null, dataList.gc);
	var dMxValStrArr = bytesToSize(dMxVal, true).split("_");
	var dMxValArr = getChartRange( dMxValStrArr[0] );
	var yPaddingVal = 0.3;
	var chartHeight = 0;
	var oneWord = 20; //BF: 15
	var bfLeftMargin = 0;
	var leftMargin = 0;
	
	for(var chartNum = 0; chartNum < allChartNum; chartNum++){
		var atgcData = new Array();
		var dataRow = null;
		
			for(var i = chartSTIdx; i < chartLTIdx; i++){
				dataRow = new Object();
				dataRow.label = dataList.labels[i];
				dataRow.gc = Number( dataList.gc[i].toFixed(1) );
				dataRow.at = Number( dataList.at[i].toFixed(1) );
				atgcData.push(dataRow);
				eachBarHeight += 38;
				bfLeftMargin = dataList.labels[i].length * oneWord;
				leftMargin = (leftMargin>bfLeftMargin)?leftMargin:bfLeftMargin;
			}
			if(chartLTIdx <= 10 || (chartLTIdx-chartSTIdx) <= 10){
				chartHeight = eachBarHeight+40+30;
			}else {
				chartHeight = eachBarHeight;
			}
			if(leftMargin <= 20){
				leftMargin = leftMargin + oneWord;
			}
			drawD3ATGCBarChart(
					(divIdStr+(chartNum+1)), atgcData, eachBarHeight, chartHeight, yPaddingVal, dMxValArr, leftMargin
			);
		
		chartSTIdx = chartLTIdx;
		if( (dataAllCnt - chartLTIdx) > 20 ){
			chartLTIdx = chartSTIdx + 20;
		}else{
			chartLTIdx = dataAllCnt;
		}
		eachBarHeight = 0;
		atgcData = null;
		bfLeftMargin = 0;
		leftMargin = 0;
	}
}

function drawD3ATGCBarChart(divIdStr , atgcData, eachBarHeight, chartHeight, yPaddingVal, dMxValArr, leftMargin){
	
	var margin = {top: 40, right: 30, bottom: 30, left: leftMargin },
    width = 660 - margin.left - margin.right,
    height = chartHeight - margin.top - margin.bottom;

	var y = d3.scaleBand().range([0, height]).padding(yPaddingVal);
	var x = d3.scaleLinear().range([0, width]);
	var atgcToolTip = d3.select(".atgcToolTip");
	
	
	var svg = d3.select(("#"+divIdStr)).append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	    .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	  x.domain( [0, 100] )
	  y.domain( atgcData.map( function(d) { return d.label; } ) );
	  
	  svg.selectAll(".gcbar")
	      .data(atgcData)
	      .enter().append("path")
	      .attr("class", "gcbar")
	      .attr("d", function(d){
	    	  var pathDataValue = generatePathData( x(0) , y(d.label) , x(d.gc) , y.bandwidth() , 0, 0, 10, 10);
	    	  return pathDataValue;
	      })
	      .on("mouseover", function(d) {
	    	  atgcToolTip.style("display", null);
	    	  atgcToolTip.style("left", (d3.event.pageX - 175) + "px");
	          atgcToolTip.style("top", (d3.event.pageY - 125) + "px");
	          atgcToolTip.select(".atgcToolTipHeader").text(d.label);
	          atgcToolTip.select(".atgcToolTipGC").text(d.gc+"(%)");
	          atgcToolTip.select(".atgcToolTipAT").text(d.at+"(%)");
	          
	      })
	      .on("mouseout",  function() { atgcToolTip.style("display", "none"); });
	  
	
	  svg.selectAll(".atbar")
	      .data(atgcData)
	      .enter().append("path")
	      .attr("class", "atbar")
	      .attr("d", function(d){
	    	  var pathDataValue = generatePathData( x(d.gc) , y(d.label) , x(d.at) , y.bandwidth() , 10, 10, 0, 0);
	    	  return pathDataValue;
	      })
	      .on("mouseover", function(d) {
	    	  atgcToolTip.style("display", null);
	    	  atgcToolTip.style("left", (d3.event.pageX - 175) + "px");
	          atgcToolTip.style("top", (d3.event.pageY - 125) + "px");
	          atgcToolTip.select(".atgcToolTipHeader").text(d.label);
	          atgcToolTip.select(".atgcToolTipGC").text(d.gc+"(%)");
	          atgcToolTip.select(".atgcToolTipAT").text(d.at+"(%)");
	      })
	      .on("mouseout",  function() { atgcToolTip.style("display", "none"); });
	  
	  
	  svg.append("g")
	  	.attr("class", "d3HighLightG")
	  	.selectAll("text")
	  	.data(atgcData)
	  	.enter().append("text")
	  	.attr("class", "d3HighLightTxt")
	  	.attr("x", function(d){
	  		var stX = d.gc-12;
	  		return x(stX);
	  	})
	  	.attr("y", function(d) {
	  		return (y(d.label)+5+(y.bandwidth()/2));
	  	})
	  	.text(function(d) { return d.gc; });

	  svg.append("g")
	  	.attr("class", "d3HighLightG")
	  	.selectAll("text")
	  	.data(atgcData)
	  	.enter().append("text")
	  	.attr("class", "d3HighLightTxt")
	  	.attr("x", function(d){
	  		var stX = d.gc+5;
	  		return x(stX);
	  	})
	  	.attr("y", function(d) {
	  		return (y(d.label)+5+(y.bandwidth()/2));
	  	})
	  	.text(function(d) { return d.at; });
	  
	
	  svg.append("g")
	      .attr("class", "d3TopAxis")
	      .attr("transform", "translate(0,-10)")
	      .call(d3.axisBottom(x).tickFormat(function(d, i){
	    	  //return (i<5)?(d):(100-(i*10));
	    	  return d;
	      }));
	
	  svg.append("g")
	      .attr("class", "d3BottomAxis")
	      .attr("transform", "translate(0," + height + ")")
	      .call(d3.axisBottom(x).tickFormat(function(d, i){
	    	  //return (i<5)?(d):(100-(i*10));
	    	  return (100-(i*10));
	      }));
	
	  svg.append("g")
	      .attr("class", "d3LeftAxis")
	      .call(d3.axisLeft(y));
	  
	  //svg.append("g")      
	      //.attr("class", "d3HighLightArea");
	
	  //d3.select(".d3TopAxis").selectAll(".tick").selectAll("line").remove();
	  d3.select(("#"+divIdStr)).select(".d3TopAxis").selectAll(".domain").remove();
	  d3.select(("#"+divIdStr)).select(".d3TopAxis").selectAll(".tick").selectAll("line").attr("transform", "translate(0,0)");
	  d3.select(("#"+divIdStr)).select(".d3TopAxis").selectAll(".tick").selectAll("text").attr("transform", "translate(0,-20)");
	
	  d3.select(("#"+divIdStr)).select(".d3LeftAxis").selectAll(".domain").remove();
	  d3.select(("#"+divIdStr)).select(".d3LeftAxis").selectAll(".tick").selectAll("line").remove();
	
	  d3.select(("#"+divIdStr)).select(".d3BottomAxis").selectAll(".domain").remove();
	
}



