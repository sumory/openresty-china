(function (L) {
    var _this = null;
    L.Settings = L.Settings || {};
    _this = L.Settings = {
        data: {
        },
 
        init: function () {
        	_this.initEvents();
        	_this.initUploader();
    
        },

        initEvents:function(){
        	$("#edit-user-btn").click(function(){
        		$("#edit-user-result").hide();
        		$.ajax({
		            url : '/user/edit',
		            type : 'post',
		            data: {
		                email: $("input[name=email]").val(),
		                email_public: $("#user_email_public").prop("checked")?1:0,
		                city: $("input[name=city]").val(),
		                company: $("input[name=company]").val(),
		                github: $("input[name=github]").val(),
		                website: $("input[name=website]").val(),
		                sign: $("input[name=sign]").val()
		            },
		            dataType : 'json',
		            success : function(result) {
		                if(result.success){
		                    window.location.href="/settings";
		                }else{
		                     $("#edit-user-result").html("编辑资料失败，请重试");
		                }
		            },
		            error : function() {
		            	$("#edit-user-result").show();
		                $("#edit-user-result div div").html("编辑资料发生错误，请重试");
		            }
		        });
        	});

        	$("#edit-user-pwd-btn").click(function(){
        		$("#edit-user-pwd-result").hide();
        		var old_pwd = $("input[name=current_password]").val();
        		var new_pwd = $("input[name=password]").val();
        		var confirm_pwd = $("input[name=password_confirm]").val();

        		if(!new_pwd || !old_pwd){
		            _this.uploadTip(false, "输入的密码不能为空");
		            return;
        		}

        		if(new_pwd!=confirm_pwd){
		            _this.uploadTip(false, "两次输入的新密码不一致");
		            return;
        		}


        		$.ajax({
		            url : '/user/change_pwd',
		            type : 'post',
		            data: {
		                old_pwd:  hex_md5(old_pwd + L.pwd_secret),
		                new_pwd:  hex_md5(new_pwd + L.pwd_secret)
		            },
		            dataType : 'json',
		            success : function(result) {
		                if(result.success){
		                	_this.uploadTip(true, "修改密码成功!");
		                }else{
		                	_this.uploadTip(false, result.msg);
		                }
		            },
		            error : function() {
		            	_this.uploadTip(false, "修改密码发生错误，请重试");
		            }
		        });
        	});

        },

        uploadTip: function(ok, content){
        	if(ok){
				$("#edit-user-pwd-result").show();
				$("#edit-user-pwd-result div div").removeClass("alert-danger").addClass("alert-success").html(content);
        	}else{
        		$("#edit-user-pwd-result").show();
				$("#edit-user-pwd-result div div").removeClass("alert-success").addClass("alert-danger").html(content);
        	}
        },

        initUploader:function() {
        	$("#avatar_image").fileupload({  
	            url: '/upload/avatar',
	            sequentialUploads: true,
		        fail: function(e, data) {
		        	$("#upload_result_tip").html('<span style="color:red;">更改头像发生错误，请检查文件大小和格式</span>');
		        },
	        }).bind('fileuploadprogress', function (e, data) {  
	            var progress = parseInt(data.loaded / data.total * 100, 10);  
	            $("#avatar_upload_progress").css('width',progress + '%');  
	            $("#avatar_upload_progress").html(progress + '%');  
	        }).bind('fileuploaddone', function (e, data) { 
	        	//console.dir(data.result)
	        	var result = data.result || {};
	        	if(result.success && result.filename){
	        		var avatar_path = "/static/avatar/" + result.filename;
	        		$("#avatar_show").attr("src",avatar_path);
	            	$("#my_avatar").attr("src",avatar_path);
	            	$("#upload_result_tip").html('');
	        	}else{
	        		$("#upload_result_tip").html('<span style="color:red;">更改头像失败'  + (result.msg?": "+result.msg:"")+ '</span>');
	        	}
	        });  
        }
    };
}(APP));