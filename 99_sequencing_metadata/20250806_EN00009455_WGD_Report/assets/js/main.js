
(function () {
  'use strict'
	
	var mainSplide = new Splide("#main_img_splide",{
		type : 'loop',
		arrows : false,
		autoplay: true,
		interval: 3000,
		classes:{
			page : 'splide__pagination__page add_style_splide_btn'
		}
	}).mount();
	
	
	var mainSplide2 = new Splide("#main_img_splide2",{
		type : 'fade',
		arrows : false,
		pagination: false,
		autoplay: true,
		rewind: true,
		interval: 2000
	}).mount();
	
	var mainSplide3 = new Splide("#main_img_splide3",{
		type : 'loop',
		arrows : false,
		autoplay: true,
		interval: 2000,
		classes:{
			pagination: 'splide__pagination add_splide_pagination',	
			page : 'splide__pagination__page add_style_splide_btn'
		}
	}).mount();
	
	$('#banner_raw_data_sttst_btn').hover(function(){
		mainSplide2.go(0);
	});
	$('#banner_total_bases_btn').hover(function(){
		mainSplide2.go(1);
	});
	$('#banner_gcat_btn').hover(function(){
		mainSplide2.go(2);
	});
	$('#banner_q20q30_btn').hover(function(){
		mainSplide2.go(3);
	});
	$('#banner_qualitybycycle_btn').hover(function(){
		mainSplide2.go(4);
	});
	
	
})()






