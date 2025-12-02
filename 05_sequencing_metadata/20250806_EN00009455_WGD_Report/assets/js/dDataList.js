
(function () {
  'use strict'
	
	$("#data_all_jqdt").DataTable({
		"info":false,"ordering": false,"searching": false,"lengthChange": false, "paging":false
	});
	
	$("#example_jqdt").DataTable({
		"info":false,"ordering": false,"searching": false,"lengthChange": true,
		"lengthMenu": [[10, 30, 50, -1], [10, 30, 50, "All"]],
		"pageLength": -1,
		"language": {
		    "paginate": {
		      "previous": "<img src='../images/icon_dt_previous.png'>",
		      "next": "<img src='../images/icon_dt_next.png'>"
		    }
		}
	});
	
})()






function openResultFileDesc(){
	$("html, body").css({"overflow": "hidden", "height": "100%"});
	$("#result_file_desc_modal_div").show();
}
function closeResultFileDesc() {
	$("#result_file_desc_modal_div").hide();
	$("html, body").css({"overflow": "auto", "height": "100%"});
}