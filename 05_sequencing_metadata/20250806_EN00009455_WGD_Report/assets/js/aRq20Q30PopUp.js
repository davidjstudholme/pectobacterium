
(function () {
  'use strict'
	resizeMyPopUp();
	var thisUrlInfo = getCurrentUrlInfo();
	if( thisUrlInfo.dType ){
		horizontalBarChart(thisUrlInfo.dType);
	}
})()

function closePopUpWindow(){
	window.close();
}

function horizontalBarChart(dType){
	
	var dataList = null;
	
	switch(dType){
		case "orgn":{
			dataList = quality_score_bar_chart;
		};break;
		case "trim":{
			dataList = trimmed_quality_score_bar_chart;
		};break;
		case "umi":{
			dataList = umi_quality_score_bar_chart;
		};break;
	}
	
	var q20ScoreArr = null;
	var q30ScoreArr = null;
	
	for(var idxNum in dataList.datasets){
		var dsObj = dataList.datasets[idxNum];
		
		if(dsObj.label == "Q20"){
			q20ScoreArr = dsObj.data;
		}
		if(dsObj.label == "Q30"){
			q30ScoreArr = dsObj.data;
		}
	}
	
	var dataAllCnt = q20ScoreArr.length;
	var allChartNum = dataAllCnt / 20;
	
	var divIdx = 0;
	var htmlStr = "";
	for(var chartNum = 0; chartNum < allChartNum; chartNum++){
		if(chartNum%2==0){
			divIdx = chartNum+1;
			htmlStr = '<div class="w3-row w3-margin-top"><div class="w3-col l6"><div id="barChartCVS'+divIdx+'"></div></div><div class="w3-col l6"><div id="barChartCVS'+(divIdx+1)+'"></div></div></div>';
			$("#popup_chart_area_div").append(htmlStr);
		}
	}
	
	var eachBarHeight = 0;
	var chartSTIdx = 0;
	var chartLTIdx = chartSTIdx+20;
	var divIdStr = "barChartCVS";
//	var dMxVal = Math.max.apply(null, dataList.data);
//	var dMxValStrArr = bytesToSize(dMxVal, true).split("_");
//	var dMxValArr = getChartRange( dMxValStrArr[0] );
	var dMxValArr = null;
	
	var yPaddingVal = 0.4;
	var chartHeight = 0;
	var oneWord = 20; //BF: 15
	var bfLeftMargin = 0;
	var leftMargin = 0;
	
	for(var chartNum = 0; chartNum < allChartNum; chartNum++){
		var qualityScoreData = new Array();
		var dataRow = null;
		
			for(var i = chartSTIdx; i < chartLTIdx; i++){
				dataRow = new Object();
				dataRow.label = dataList.labels[i];
				dataRow.q20 = Number( q20ScoreArr[i].toFixed(1) );
				dataRow.q30 = Number( q30ScoreArr[i].toFixed(1) );
				qualityScoreData.push(dataRow);
				eachBarHeight += 75;
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
			
			drawHorizontalBarChart(
					(divIdStr+(chartNum+1)), qualityScoreData, eachBarHeight, chartHeight, yPaddingVal, dMxValArr, leftMargin
			);
		
		chartSTIdx = chartLTIdx;
		if( (dataAllCnt - chartLTIdx) > 20 ){
			chartLTIdx = chartSTIdx + 20;
		}else{
			chartLTIdx = dataAllCnt;
		}
		eachBarHeight = 0;
		qualityScoreData = null;
		bfLeftMargin = 0;
		leftMargin = 0;
	}
	
}


function drawHorizontalBarChart(divIdStr , qualityScoreData, eachBarHeight, chartHeight, yPaddingVal, dMxValArr, leftMargin){
	
//	var qualityScoreData = [
//		{"label":"PM-PM-1072-N-A1","q20":96.41,"q30":91.3}
//	];
	
	var margin = {top: 40, right: 80, bottom: 30, left: leftMargin },
    width = 650 - margin.left - margin.right,
    height = chartHeight - margin.top - margin.bottom;

	var y = d3.scaleBand().range([0,height]).padding(yPaddingVal);
	var x = d3.scaleLinear().range([0, width]);
	var d3ChartToolTip = d3.select(".d3ChartToolTip");
	
	
	var svg = d3.select(("#"+divIdStr)).append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	    .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
	  x.domain( [0, 100] )
	  y.domain( qualityScoreData.map(function(d,i) { return d.label; } )
	  );
	  
	  svg.append("g")
	  .attr("class", "d3ChartYGridline")
	  .selectAll("line")
	  .data([0,10,20,30,40,50,60,70,80,90,100])
	  .enter().append("line")
	  .attr("x1", function(d) { return x(d); })
	  .attr("x2", function(d) { return x(d); })
	  .attr("y1", function(d) { return 0; })
	  .attr("y2", function(d) { return height; });
	  
	  svg.selectAll(".d3ChartBar1")
      .data(qualityScoreData)
      .enter().append("path")
      .attr("class", "d3ChartBar1")
      .attr("d", function(d){
    	  var barWidth = (y.bandwidth()/2)-2;
    	  var yPst = y(d.label);
    	  var pathDataValue = generatePathData( x(0) , yPst , x(d.q20) , barWidth , 8, 8, 0, 0);
    	  return pathDataValue;
      })
      .on("mouseover", function(d) {
    	  d3ChartToolTip.style("display", null);
    	  d3ChartToolTip.style("left", (d3.event.pageX - 175) + "px");
    	  d3ChartToolTip.style("top", (d3.event.pageY - 125) + "px");
    	  d3ChartToolTip.select(".d3ChartToolTipHeader").text(d.label);
          d3ChartToolTip.select(".d3ChartToolTipValue1").text(d.q20);
    	  d3ChartToolTip.select(".d3ChartToolTipValue2").text(d.q30);
      })
      .on("mouseout",  function() { d3ChartToolTip.style("display", "none"); });
	  
	  
	  svg.selectAll(".d3ChartBar2")
      .data(qualityScoreData)
      .enter().append("path")
      .attr("class", "d3ChartBar2")
      .attr("d", function(d){
    	  var barWidth = (y.bandwidth()/2)-2;
    	  var yPst = (y(d.label)+barWidth)+4;
    	  var pathDataValue = generatePathData( x(0) , yPst , x(d.q30) , barWidth , 8, 8, 0, 0);
    	  return pathDataValue;
      })
      .on("mouseover", function(d) {
    	  d3ChartToolTip.style("display", null);
    	  d3ChartToolTip.style("left", (d3.event.pageX - 175) + "px");
    	  d3ChartToolTip.style("top", (d3.event.pageY - 125) + "px");
    	  d3ChartToolTip.select(".d3ChartToolTipHeader").text(d.label);
    	  d3ChartToolTip.select(".d3ChartToolTipValue1").text(d.q20);
    	  d3ChartToolTip.select(".d3ChartToolTipValue2").text(d.q30);
      })
      .on("mouseout",  function() { d3ChartToolTip.style("display", "none"); });
	  
	  	  
	  svg.append("g")
	  	.attr("class", "d3HighLightG")
	  	.selectAll("text")
	  	.data(qualityScoreData)
	  	.enter().append("text")
	  	.attr("class", "d3HighLightTxt1")
	  	.attr("x", function(d){
	  		var addMargin = x( (d.q20/(d.q20*2)) );
	  		return (x(d.q20)+addMargin);
	  	})
	  	.attr("y", function(d) {
	  		var barWidth = (y.bandwidth()/2)/2;
	  		return y(d.label)+barWidth;
	  	})
	  	.text(function(d) { return d.q20; });

	  svg.append("g")
	  	.attr("class", "d3HighLightG")
	  	.selectAll("text")
	  	.data(qualityScoreData)
	  	.enter().append("text")
	  	.attr("class", "d3HighLightTxt2")
	  	.attr("x", function(d){
	  		var addMargin = x( (d.q30/(d.q30*2)) );
	  		return (x(d.q30)+addMargin);
	  	})
	  	.attr("y", function(d) {
	  		
	  		var barWidth = y.bandwidth()/2;
	    	var yPst = (y(d.label)+barWidth)+14;
	  		return yPst;
	  	})
	  	.text(function(d) { return d.q30; });
	  
	  
	  svg.append("g")
	      .attr("class", "d3TopAxis")
	      .attr("transform", "translate(0,-10)")
	      .call(d3.axisBottom(x));
	
	  svg.append("g")
	      .attr("class", "d3LeftAxis")
	      .call(d3.axisLeft(y));
	  
	  d3.select(("#"+divIdStr)).select(".d3TopAxis").selectAll(".domain").remove();
	  d3.select(("#"+divIdStr)).select(".d3TopAxis").selectAll(".tick").selectAll("line").attr("transform", "translate(0,0)");
	  d3.select(("#"+divIdStr)).select(".d3TopAxis").selectAll(".tick").selectAll("text").attr("transform", "translate(0,-20)");
	
	  d3.select(("#"+divIdStr)).select(".d3LeftAxis").selectAll(".domain").remove();
	  d3.select(("#"+divIdStr)).select(".d3LeftAxis").selectAll(".tick").selectAll("line").remove();
	
}




