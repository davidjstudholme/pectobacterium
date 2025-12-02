var morethanval = 10;
var isFirst = true;
(function () {
  'use strict'

    
    $(window).scroll(function () {
    	
    	var docScrollTopVal = $(this).scrollTop(); 
    	
        if (docScrollTopVal > 300) {
            $('#content_menu_div').css({
            	"position":"fixed", "top": 0, "left": 80, "z-index":1
            });
        } else {
            $('#content_menu_div').css({
            	"position":"static", "z-index":0
            });
        }
        
        
        
        var libDiv = $('#content_lib_div').offset().top;
        var clusterDiv = $('#content_cluster_div').offset().top;
        var seqDiv = $('#content_sequencing_div').offset().top;
        var dataDiv = $('#content_data_div').offset().top;
        var dataDivHt = $('#content_data_div').height();
        
        if( docScrollTopVal == 0 ){
        	var btnObj0 = $('#workflow_btn_1');
        	if( !btnObj0.hasClass("workflow_btn_after") ){
        		btnObj0.addClass("workflow_btn_after");
            	btnObj0.siblings("img").show();
        		$('.workflow_dft_btn').not(btnObj0).removeClass("workflow_btn_after");
        		$('.workflow_dft_btn').not(btnObj0).siblings("img").hide();
        	}
        }else if( (docScrollTopVal>libDiv) && (docScrollTopVal<clusterDiv) ){
        	var btnObj1 = $('#workflow_btn_1');
        	if( !btnObj1.hasClass("workflow_btn_after") ){
        		btnObj1.addClass("workflow_btn_after");
            	btnObj1.siblings("img").show();
        		$('.workflow_dft_btn').not(btnObj1).removeClass("workflow_btn_after");
        		$('.workflow_dft_btn').not(btnObj1).siblings("img").hide();
        	}
        }else if( (docScrollTopVal>=clusterDiv) && (docScrollTopVal<seqDiv) ){
        	var btnObj2 = $('#workflow_btn_2');
        	if( !btnObj2.hasClass("workflow_btn_after") ){
        		btnObj2.addClass("workflow_btn_after");
            	btnObj2.siblings("img").show();
        		$('.workflow_dft_btn').not(btnObj2).removeClass("workflow_btn_after");
        		$('.workflow_dft_btn').not(btnObj2).siblings("img").hide();
        	}
        }else if( (docScrollTopVal>=seqDiv) && (docScrollTopVal<dataDiv) ){
        	var btnObj3 = $('#workflow_btn_3');
        	if( !btnObj3.hasClass("workflow_btn_after") ){
        		btnObj3.addClass("workflow_btn_after");
            	btnObj3.siblings("img").show();
        		$('.workflow_dft_btn').not(btnObj3).removeClass("workflow_btn_after");
        		$('.workflow_dft_btn').not(btnObj3).siblings("img").hide();
        	}
        }else if( (docScrollTopVal>=dataDiv) && (docScrollTopVal<(dataDiv + dataDivHt)) ){
        	var btnObj4 = $('#workflow_btn_4');
        	if( !btnObj4.hasClass("workflow_btn_after") ){
        		btnObj4.addClass("workflow_btn_after");
            	btnObj4.siblings("img").show();
        		$('.workflow_dft_btn').not(btnObj4).removeClass("workflow_btn_after");
        		$('.workflow_dft_btn').not(btnObj4).siblings("img").hide();
        	}
        }
        
        
        
    });
	
	
	
	
	$('#workflow_btn_1').on('click', function () {
		if(isFirst){
			var btnObj1 = $('#workflow_btn_1');
			btnObj1.addClass("workflow_btn_after");
        	btnObj1.siblings("img").show();
			isFirst = false;
		}
		$('html').animate({scrollTop : 0}, 400);
	});
	$('#workflow_btn_2').on('click', function () {
		var divObj = ($('#content_cluster_div').offset().top)+morethanval;
		$('html').animate({scrollTop : divObj}, 400);
	});
	$('#workflow_btn_3').on('click', function () {
		var divObj = ($('#content_sequencing_div').offset().top)+morethanval;
		$('html').animate({scrollTop : divObj}, 400);
	});
	$('#workflow_btn_4').on('click', function () {
		var divObj = ($('#content_data_div').offset().top)+morethanval;
		$('html').animate({scrollTop : divObj}, 400);
	});
	
	
	$('.top-btn').on('click', function () {
		$('html').animate({scrollTop : 0}, 400);
	});
	
	
	
	var thisUrlInfo = getCurrentUrlInfo();
	
	var exeBtnObj = "#workflow_btn_"+thisUrlInfo.stNum;
	$(exeBtnObj).trigger("click");
})()



