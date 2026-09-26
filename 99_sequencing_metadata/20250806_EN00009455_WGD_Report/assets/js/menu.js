
(function () {
  'use strict'
	
	$('.m_menu_li').on({
		click: function(){
			var liObj = $(this); 
			liObj.children("img").attr("src",function(idx, attr){
				if(attr.match("plus")){
					liObj.children('span').addClass("mg_bold_txt");
					liObj.children('.menu-mg-ul').show();
					return attr.replace("./assets/images/plus_icon_test.png","./assets/images/minus_icon_test.png");
				}else{
					liObj.children('span').removeClass("mg_bold_txt");
					liObj.children('.menu-mg-ul').hide();
					return attr.replace("./assets/images/minus_icon_test.png","./assets/images/plus_icon_test.png");
				}
			});
			
			var otherObj = $(this).siblings();
			otherObj.find('span').removeClass("mg_bold_txt");
			otherObj.find('.menu-mg-ul').hide();
			otherObj.children('img').attr("src","./assets/images/plus_icon_test.png");
		}
	});
	
	
	$(document).mouseup(function(e){
		var chkObjArr = new Array();
		chkObjArr.push("user_info_modal_div");
		chkObjArr.push("company_location_modal_div");
		chkObjArr.push("main_alert_svg");

		var modalTagObj;
		for(var tagIdx in chkObjArr){
			modalTagObj = $('#'+chkObjArr[tagIdx]);
			if(modalTagObj.length){
				if( modalTagObj.has(e.target).length ===0 ){
					modalTagObj.hide();
				}
			}
			
		}
	});
	
  
})()


