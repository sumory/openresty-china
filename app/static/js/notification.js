(function (L) {
    var _this = null;
    L.Notification = L.Notification || {};
    _this = L.Notification = {
        data: {
        },
 
        init: function () {
        	_this.loadNotifications("all");
        	_this.initEvents();
        },

        initEvents: function(){

        	$("#unread-btn").click(function(){
        		_this.loadNotifications("unread");
        	});

        	$("#mark-btn").click(function(){
        		_this.markAllNotifications();
        	});

        	$("#delete-all-btn").click(function(){
        		_this.deleteAllNotifications();
        	});

        	$(document).on("click", "#notifications-body .delete-notification", function(){
        		var _self = $(this);
        		var id = _self.attr("data-id");
        		if(id && id!="" && id!="null"){
					$.ajax({
			            url : '/notification/' + id + '/delete',
			            type : 'post',
			            data: {},
			            dataType : 'json',
			            success : function(result) {
			                if(result.success){
			                	$("#notification-"+id).remove();
			                }else{
			                	L.Common.showTipDialog("提示", result.msg || "删除通知发生错误");
			                }
			            },
			            error : function() {
			               	L.Common.showTipDialog("提示", "删除通知请求发生异常");
			            }
			        });
        		}
        	})
        	
        },

        deleteAllNotifications: function(){
	        var d = dialog({
			    title: '提示',
			    content: '确定要删除所有通知吗?',
			    okValue: '确定',
			    ok: function () {
			        $.ajax({
			            url : '/notification/delete_all',
			            type : 'post',
			            data: {},
			            dataType : 'json',
			            success : function(result) {
			                if(result.success){
			                	$("#notifications-body").html('<div class="alert alert-info" role="alert">所有通知已被删除</div>');
			                	//清除通知数标记
			                	$("#notification-area a").removeClass("red-color");
		                        $("#notification-area .count").text(0).hide();

		                        //隐藏分页条
		                        $("#pagebar").hide();
			                }else{
			                	L.Common.showTipDialog("提示", result.msg || "删除全部通知发生错误");
			                }
			            },
			            error : function() {
			               	L.Common.showTipDialog("提示", "删除全部通知请求发生异常");
			            }
			        });
			        return true;
			    },
			    cancelValue: '取消',
			    cancel: function () {}
			});
			d.show();
        },

        markAllNotifications: function(){
			$.ajax({
	            url : '/notification/mark',
	            type : 'post',
	            data: {},
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                	$("#notifications-body .notification").each(function(){
	                		$(this).removeClass("not-mark");
	                	});

	                	//清除通知数标记
	                	$("#notification-area a").removeClass("red-color");
                        $("#notification-area .count").text(0).hide();
	                }else{
	                	L.Common.showTipDialog("提示", result.msg || "标记全部通知为已读发生错误");
	                }
	            },
	            error : function() {
	               	L.Common.showTipDialog("提示", "标记全部通知为已读请求发生异常");
	            }
	        });
        },

        loadNotifications: function(n_type, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/notification/all',
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1,
	                n_type: n_type
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                	$("#pagebar").hide();
	                	if(!result.data || (result.data && result.data.notifications.length<=0)){
	                		$("#notifications-body").html('<div class="alert alert-info" role="alert">没有任何'+ 
	                			(n_type=="unread"?"未读":"") +'通知</div>');
	                	}else{
	                		 _this.page(result, 1, n_type);
	                	}
	                }else{
	                    $("#notifications-body").html('<div class="alert alert-danger" role="alert">'+result.msg+'</div>');
	                }
	            },
	            error : function() {
	                $("#notifications-body").html('<div class="alert alert-danger" role="alert">查询通知请求发生错误.</div>');
	            }
	        });
        },

        page: function(result, pageNo, n_type){
			var data = result.data || {};
			var $container = $("#notifications-body");
			$container.empty();


			var tpl = $("#notification-item-tpl").html();
            var notifications = data.notifications || [];

            // convert markdown to html
			try{
				for(var i = 0; i<notifications.length; i++){
					try{
						var comment_content = notifications[i].comment_content;
						if(!comment_content){
							comment_content = "~~此评论已被删除~~";
						}
						notifications[i].comment_content = L.Common.md.render(comment_content);
					}catch(e){
						console.log(e);
					}
				}
	            var html = juicer(tpl, data);
	            $container.html(html);
	            for(var i = 0; i<notifications.length; i++){
	            	emojify.run(document.getElementById('notification-'+notifications[i].id));
	            }
			}catch(e){
				console.log(e);
			}

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#pagebar").show();
				$.fn.jpagebar({
					renderTo : $("#pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/notification/all',
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo,
	                			n_type: n_type
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#notifications-body");
								$container.empty();

								var tpl = $("#notification-item-tpl").html();
								var notifications = data.notifications || [];
					            // convert markdown to html
								try{
									for(var i = 0; i<notifications.length; i++){
										try{
											var comment_content = notifications[i].comment_content;
											if(!comment_content){
												comment_content = "~~此评论已被删除~~";
											}
											notifications[i].comment_content = L.Common.md.render(comment_content);
										}catch(e){
											console.log(e);
										}
									}
						            var html = juicer(tpl, data);
						            $container.html(html);
						            for(var i = 0; i<notifications.length; i++){
						            	emojify.run(document.getElementById('notification-'+notifications[i].id));
						            }
								}catch(e){
									console.log(e);
								}
							},
							error : function() {
								 $("#notifications-body").html('<div class="alert alert-danger" role="alert">查找通知请求发生错误.</div>');
				            }
						});
					}
				});
			} else {
				$("#pagebar").hide();
			}
        },
    };
}(APP));