// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(document).ready(function(){
	$('#clickme').click(function(){
		$('#uploadme').click();
	});
	$('#moreresults').css("height", null);
	$('#new_post').submit(function(){
		if($('#auto_post').val() === ""){
			alert('Please type in a post before submitting');
			return false;
		}
	});
	$('#username_result').hide();
	$('.data_load').each(function(){
		var obj_id = $(this).attr('id');
		$.ajax({
			url: $(this).attr('data-url'),
			type: "GET"
		}).done(function(msg) { 
			$("#" + obj_id).html(msg);
		});
	});
	
	// $('.refresh').each(function(){
	// 			var obj_id = $(this).attr('id');
	// 			var url = $(this).attr('data-url');
	// 			setInterval(function()
	// 			{
	// 				$('#'+ obj_id).fadeOut("slow").load(url).fadeIn("slow");
	// 			}, 10000);
	// 		});
	
	// $(".related_post").live("click", function(){
	// 		$.ajax({
	// 			url: $(this).attr('data-url')
	// 		}).done(function(msg){
	// 			$('#related_post').html(msg);
	// 		});
	// 	});
	
	$(".change_view").live("click", function(){
		var obj = $(this).attr('data-attr');
		$('.'+obj).toggle();
	});
	
	$('.listlink').click(function(){
		var obj = $(this).attr('data-attr');
		$('.'+obj).toggle();
	});
	
	// $('#username_search').keyup(function(){
	// 		$.ajax({
	// 			url : $(this).attr('data-url'),
	// 			data: {query : $(this).val()}
	// 		}).done(function(msg) {
	// 			if( msg === ""){
	// 				$('#username_result').hide();
	// 			}
	// 			else{
	// 				$('#username_result').show();
	// 				$('#username_result').html(msg);
	// 			}
	// 		});
	// 	});
	
	
  // $('#auto_post').keyup(function(){
  //  $.ajax({
  //    url : $(this).attr('data-url'),
  //    dataType: 'json',
  //    data: {query : $(this).val()},
  //    success: function(msg){
  //      $.each(msg, function(i,item){
  //      $('#auto_post_result').html(item.pos);
  //      });
  //      //$('#auto_post_result').html(msg.text);
  //    }
  //  });
  // });
  
  $('#auto_post').autocomplete({
    source: $('#auto_post').data('autocomplete-source')
  });

	$('#username_search').autocomplete({
    source: $('#username_search').data('autocomplete-source')
  });
	
	$('.get_message').click(function(){
        $(this).parent.removeClass("active");
		$.ajax({
			url : $(this).attr('data-url')
		}).done(function(msg) {
			$('.eighty').html(msg)
		});
	});
	
	//submit
	if($('#auto_post').val() !== ""){
		$('.btn.btn-info.pull-right.submit').click();
	}
	
	//infinite scroll
//	$('#news').scroll(function(){
//		url = $('#news .pagination li.next_page a').attr('href');
//		if(url && $('#news').scrollTop() >  $('#news').height() - 500){
//			$('#news .pagination').text('Fetching more products...');
//			$.getScript(url);
//		}
//	});
	
	if ($('#news').length > 0) {
	    setTimeout(updateNews, 10000);
	  }
	
	$('.unread td a').live("click", function(){
		$.ajax({
	    url : $(this).attr('data-link')
	 	});
	});
});

function updateNews() {
	var post_id = $('.content1.news_feeded:first').attr('data-id');
	var post_date = $('.content1.news_feeded:first').attr('data-date');
	var special =  $('.content1.news_feeded:first').attr('data-special');
	$.getScript('/paging_pages/news_polling?post_id='+post_id+'&post_date='+post_date+'&post_special='+special);
  
  setTimeout(updateNews, 10000);
}

function addUser(user){
	$('#username_search').val(user);
	$('#username_result').hide();
}


function validatePost(post) {
    var punctuationsPattern = /[\.,-\/#!$%\^&\*;:{}=\_`~()]/;
    var index = post.search(post);
    if (index != -1 && index < post.length - 1)
      window.alert("Please write a post without a punctuation mark in it (except possibly in the end)");
}