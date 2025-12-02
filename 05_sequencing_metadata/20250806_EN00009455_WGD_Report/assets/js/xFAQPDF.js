
(function () {
  'use strict'

	//setTheBaseLine();
	
})()

function setTheBaseLine(){
	var lineHeight = ( $('#the_last_ball').offset().top+10 ) - ($('#the_first_ball').offset().top-10);
    $('#the_base_line').css("height", lineHeight );
}

