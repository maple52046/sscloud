if (document.createEvent){

}else{
	if (confirm("Really submit this form?")){
		document.getElementById("openstack_settings").submit();
	}
}
