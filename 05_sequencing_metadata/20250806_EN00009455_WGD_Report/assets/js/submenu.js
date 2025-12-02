
(function () {
  'use strict'
	
	$('.m_menu_li').on('click', function () {
		var liObj = $(this); 
		liObj.children("img").attr("src",function(idx, attr){
			if(attr.match("plus")){
				liObj.children('span').css("font-weight","700");
				liObj.children('.menu-mg-ul').css("display","block");
				return attr.replace("../images/plus_icon_test.png","../images/minus_icon_test.png");
			}else{
				liObj.children('span').css("font-weight","400");
				liObj.children('.menu-mg-ul').css("display","none");
				return attr.replace("../images/minus_icon_test.png","../images/plus_icon_test.png");
			}
		});
		
		var otherObj = $(this).siblings();
		otherObj.find('span').css("font-weight","400");
		otherObj.find('.menu-mg-ul').css("display","none");
		otherObj.children('img').attr("src","../images/plus_icon_test.png");
	});
	
	
	
//
//	$(document).mouseup(function(e){
//		var qMenuObj1 = $('#topQuickMenu1');
//		var qMenuObj2 = $('#topQuickMenu2');
//		if( qMenuObj1.has(e.target).length ===0 ){
//			qMenuObj1.css("display","none");
//		}
//		if( qMenuObj2.has(e.target).length ===0 ){
//			qMenuObj2.css("display","none");
//		}
//	});
	
	$(document).mouseup(function(e){
		var chkObjArr = new Array();
		chkObjArr.push("topQuickMenu1");
		chkObjArr.push("topQuickMenu2");
		chkObjArr.push("user_info_modal_div");
		chkObjArr.push("mySidebar");
		chkObjArr.push("company_location_modal_div");
		chkObjArr.push("result_file_desc_modal_div");
		
		var modalTagObj;
		for(var tagIdx in chkObjArr){
			modalTagObj = $('#'+chkObjArr[tagIdx]);
			if(modalTagObj.length){
				if( modalTagObj.has(e.target).length ===0 ){
					modalTagObj.hide();
					if(chkObjArr[tagIdx]=="mySidebar"){
						if($('#mySmallSidebar').length){
							$('#mySmallSidebar').show();
						}
					}
					if(chkObjArr[tagIdx]=="result_file_desc_modal_div"){
						$("html, body").css({"overflow": "auto", "height": "100%"});
					}
				}
			}
			
		}
	});
	
	topBtn();
	$(window).scroll(function(){
		topBtn();
	});
	
  
})()


function topQuickMenuIcon1(){
	
	$('#topQuickMenu1').css("left", ($('#icon_path1').offset().left + 30));
	$('#topQuickMenu1').toggle();
	
	if($('#topQuickMenu2').is(":visible")){
		$('#topQuickMenu2').toggle();
	}

	
}
function topQuickMenuIcon2(){
	$('#topQuickMenu2').css("left",($('#icon_path2').offset().left + 30));
	$('#topQuickMenu2').toggle();
	if($('#topQuickMenu1').is(":visible")){
		$('#topQuickMenu1').toggle();
	}
}


function topBtn(){
	let top = $(window).scrollTop()
	if(top <= 0 ){
		$('.top-btn').fadeOut()
	}else{
		$('.top-btn').fadeIn()
	}
}

