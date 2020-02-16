$(function(){
	$("a#del").click(function(){
		var escapedName = $(this).attr("escaped_name");
		if ( window.confirm("削除してもよろしいですか？") ) {
			location.href = encodeURI("/videos/delete/" + escapedName);
		}
	});
});