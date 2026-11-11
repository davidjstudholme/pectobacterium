
(function () {
  'use strict'

	
	var thisUrlInfo = getCurrentUrlInfo();
	
	
	scrollToTheElement(thisUrlInfo.tNum);
})()


function scrollToTheElement(tNum){
	if(tNum>0){
		var divObj = ($("#file_desc_area"+tNum).offset().top);
		$('html').animate({scrollTop : divObj}, 400);
	}else{
		$('html').animate({scrollTop : 0}, 400);
	}
}
