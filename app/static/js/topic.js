(function (L) {
    var _this = null;
    L.Topic = L.Topic || {};
    _this = L.Topic = {
        data: {
        	topic_id:0,
        	pattern: /(@[A-Za-z][A-Za-z0-9_]+[ \n]+)/g
        },
 
        init: function (topic_id) {
        	_this.data.topic_id = topic_id;

        	//获取文章
        	$.ajax({
	            url : '/topic/' + topic_id + '/query',
	            type : 'get',
	            data: {},
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                	var tpl = $("#topic-body-tpl").html();
	                	result.data.topic.content = result.data.topic.content || "";
	                	result.data.topic.content = L.Common.md.render(result.data.topic.content);

			            var html = juicer(tpl, result.data);
			            $("#topic-body").html(html).show();
			            $("#reply").show();

			            var tpl2 = $("#ops-area-tpl").html();
			            var html2 = juicer(tpl2, result.data);
			            $("#ops-area").html(html2);

			            _this.loadComments();
        				_this.initEvents();

        				emojify.run(document.getElementById('article-content'));
        				$("title").append(" "+result.data.topic.title);
	                }else{
	                    L.Common.showTipDialog("提示", result.msg);
	                }
	            },
	            error : function() {
	            	L.Common.showTipDialog("提示", "发送请求失败.");
	            }
	        });
        },

        initEvents: function(){
        	_this.initCollectEvent();
        	_this.initLikeEvent();
        	_this.initReplyEvent();
        	_this.initDeleteTopic();
        	_this.initDeleteComment();
        	_this.initEditComment(); //编辑评论事件
        	_this.initUploader(); //评论上传图片事件
        },

        initUploader:function() {
        	$("#upload_image").fileupload({  
	            url: '/upload/file',
	            sequentialUploads: true,
		        fail: function(e, data) {
		        	L.Common.showTipDialog("提示",'上传文件发生错误，只允许jpe/jpeg/png/gif/bmp文件，大小不超过2M.');
		        },
	        }).bind('fileuploadprogress', function (e, data) {  
	            var progress = parseInt(data.loaded / data.total * 100, 10);  
	            console.log(progress + '%');  
	        }).bind('fileuploaddone', function (e, data) { 
	        	//console.dir(data.result)
	        	var result = data.result || {};
	        	if(result.success && result.filename){
	        		var file_path = "/static/files/" + result.filename;
	        		$("#reply_content").val($("#reply_content").val()+" !["+ result.originFilename +"](" + file_path +  ") ");
	        	}else{
	        		L.Common.showTipDialog("提示",'上传文件失败'  + (result.msg?": "+result.msg:"")+ '，只允许jpe/jpeg/png/gif/bmp文件，大小不超过2M.');
	        	}
	        });  
        },

        initEditComment: function(){
        	$("#reply-edit-btn").click(function(){
        		$(this).parent().addClass("active");
        		$("#reply-preview-btn").parent().removeClass("active");
        		$("#edit-area").show();
        		$("#preview-area").hide();
        	});

        	$("#reply-preview-btn").click(function(){
        		$(this).parent().addClass("active");
        		$("#reply-edit-btn").parent().removeClass("active");
        		var preview_content = L.Common.md.render($("#reply_content").val());
        		$("#preview-area").html(preview_content);
        		emojify.run(document.getElementById('preview-area'));
        		$("#edit-area").hide();
        		$("#preview-area").show();
        	});
        },

        initDeleteTopic: function(){
        	$(document).on("click", ".delete-topic", function(){
        		var topic_id = $(this).attr("data-id");
        		$.ajax({
                    url : '/topic/'+topic_id+'/delete',
                    type : 'get',
                    data : {},
                    dataType : 'json',
                    success : function(result) {
                        if(result.success){
                        	window.location.href="/";
                        }else{
                            L.Common.showTipDialog("提示", result.msg);
                        }
                    },
                    error : function() {
                        L.Common.showTipDialog("提示", "删除文章请求发生错误");
                    }
                });
        	});
        },

         initDeleteComment: function(){
            $(document).on("click", ".delete-comment", function(){
                var comment_id = $(this).attr("data-id");
                $.ajax({
                    url : '/comment/'+comment_id+'/delete',
                    type : 'get',
                    data : {},
                    dataType : 'json',
                    success : function(result) {
                        if(result.success){
                            $("#reply_"+comment_id).remove();
                            $(".total-comment-count").each(function(){
				            	var last_count = 0;
				            	try{
				            		last_count = parseInt($(this).text());
				            	}catch(e){}
				            	if(last_count>=1){
				            		$(this).text(last_count-1);
				            	}
							});
                        }else{
                            L.Common.showTipDialog("提示", result.msg);
                        }
                    },
                    error : function() {
                        L.Common.showTipDialog("提示", "删除评论请求发生错误");
                    }
                });
            });
        },

        initReplyEvent:function(){
			$("#reply-btn").click(function(){
        		var reply_content = $("#reply_content").val();
        		if(!reply_content){
        			return;
        		}

        		if(reply_content.length>2500){
        			L.Common.showTipDialog("提示", "评论内容长度不得超过2500字符，当前字符数" + reply_content.length + ".");
        			return;
        		}
        		
        		var mention_users = [];
        		try{
        			var at_users = reply_content.match(_this.data.pattern);
        			if (at_users){
	        			for(var i in at_users){
	        				var tmp = at_users[i] && at_users[i].replace(/(@)|(^\s+)|(\s+$)/g,'');
	        				if(tmp){
	        					//解析转换reply_content中的@为markdown
	        					reply_content = reply_content.replace(at_users[i], "[@"+tmp+"](/user/" + tmp + "/index) ");

	        					var is_exist = false;
					            for(var un in mention_users){
					            	if(mention_users[un]==tmp){
					            		is_exist=true;
					            	}
					            }
					            if(!is_exist){
					            	mention_users.push(tmp);
					            }
	        				}
	        			}
	        		}
        		}catch(e){}

        		if(mention_users.length>5){
        			L.Common.showTipDialog("提示", "提及的用户不得多于5个, 当前"+mention_users.length+"个.");
        			return;
        		}

				$.ajax({
		            url : '/comment/new',
		            type : 'post',
		            data: {
		            	topic_id: _this.data.topic_id,
		                content: reply_content,
		                mention_users: mention_users.join(",")
		            },
		            dataType : 'json',
		            success : function(result) {
		                if(result.success){
		                	$("#mention-area").text("");

		                	var data = result.data || {};
		                	var tpl = $("#single-comment-item-tpl").html();
				            var comment = data.c || {};
					        comment.content = L.Common.md.render(comment.content);

							var html = juicer(tpl, data);
				            $("#comments-body").append(html);
				            emojify.run(document.getElementById('reply_'+comment.id));

				            $("#reply_content").val("");
				            var alert_div = $("#comments-body .alert");
				            alert_div.hide();

				            $("#replies").show();
				            $(".total-comment-count").each(function(){
				            	var last_count = 0;
				            	try{
				            		last_count = parseInt($(this).text());
				            	}catch(e){}
				            	 
								$(this).text(last_count+1);
							});
		                }else{
		                    L.Common.showTipDialog("提示", result.msg);
		                }
		            },
		            error : function() {
		            	L.Common.showTipDialog("提示", "发送请求失败.");
		            }
		        });

        	});

        	function show_mention_users(){
        		var mention_users = [];
        		try{
        			var reply_content = $("#reply_content").val();
	        		if(!reply_content){
	        			$("#mention-area").text("");
	        			return;
	        		}
        			var at_users = reply_content.match(_this.data.pattern);
        			if (at_users){
	        			for(var i in at_users){
	        				var tmp = at_users[i] && at_users[i].replace(/(@)|(^\s+)|(\s+$)/g,'');
	        				if(tmp){
	        					var is_exist = false;
					            for(var un in mention_users){
					            	if(mention_users[un]==tmp){
					            		is_exist=true;
					            	}
					            }
					            if(!is_exist){
					            	mention_users.push(tmp);
					            }
	        				}
	        			}
	        		}
        		}catch(e){}

        		if(mention_users && mention_users.length>0){
        			$("#mention-area").text("提及(最多5个): ");
        			for(var i=0;i<5&&i<mention_users.length;i++){
        				$("#mention-area").append('<span class="label label-danger">'+ mention_users[i] +'</span>&nbsp;');
        			}
        		}else{
        			$("#mention-area").text("");
        		}
        	}

        	$("#reply_content").keyup(function(){
        		show_mention_users();
        	});

        	$("#reply_content").on("change", function(){
        		show_mention_users();
        	});

        	$("#reply_content").focusout(function(){
        		show_mention_users();
        	});

        	//回复此楼
        	$(document).on("click", "#replies .reply_to_this", function(){
        		var user_name = $(this).attr("data-name");
        		$("#reply_content").val($("#reply_content").val()+" @"+user_name+" ");
        		$('html,body').animate({scrollTop:$("#new_reply").offset().top},50)
        	});
        },

        initCollectEvent:function(){
			$("#collect-btn").click(function(){
        		var op = $(this).attr("data-op");
        		var topic_id = $(this).attr('data-id');
        		var _self = $(this);

        		if(op=="collect"){
        			$.ajax({
			            url : '/topic/collect',
			            type : 'post',
			            data: {
			                topic_id: topic_id
			            },
			            dataType : 'json',
			            success : function(result) {
			                if(result.success){
			                	_self.attr("data-op", "cancel_collect");
			                	_self.addClass("active");
			                	$("#collect-num-text").text(parseInt($("#collect-num-text").text())+1);
			                }else{
			                    L.Common.showTipDialog("提示", result.msg);
			                }
			            },
			            error : function() {
			            	L.Common.showTipDialog("提示", "发送请求失败.");
			            }
			        });
        		}else if(op=="cancel_collect"){
        			$.ajax({
			            url : '/topic/cancel_collect',
			            type : 'post',
			            data: {
			                topic_id: topic_id
			            },
			            dataType : 'json',
			            success : function(result) {
			                if(result.success){
			                	_self.attr("data-op", "collect");
			                	_self.removeClass("active");
			                	$("#collect-num-text").text(parseInt($("#collect-num-text").text())-1);
			                }else{
			                    L.Common.showTipDialog("提示", result.msg);
			                }
			            },
			            error : function() {
			                L.Common.showTipDialog("提示", "发送请求失败.");
			            }
			        });
        		}
        	});
        },

        initLikeEvent:function(){
			$("#like-btn").click(function(){
        		var op = $(this).attr("data-op");
        		var topic_id = $(this).attr('data-id');
        		var _self = $(this);

        		if(op=="like"){
        			$.ajax({
			            url : '/topic/like',
			            type : 'post',
			            data: {
			                topic_id: topic_id
			            },
			            dataType : 'json',
			            success : function(result) {
			                if(result.success){
			                	_self.attr("data-op", "cancel_like");
			                	_self.addClass("active");
			                	$(".like-num-text").each(function(){
			                		$(this).text(parseInt($(this).text())+1);
			                	});
			                }else{
			                    L.Common.showTipDialog("提示", result.msg);
			                }
			            },
			            error : function() {
			            	L.Common.showTipDialog("提示", "发送请求失败.");
			            }
			        });
        		}else if(op=="cancel_like"){
        			L.Common.showTipDialog("提示", "已赞过的文章不允许取消赞.");
        			// $.ajax({
			        //     url : '/topic/cancel_like',
			        //     type : 'post',
			        //     data: {
			        //         topic_id: topic_id
			        //     },
			        //     dataType : 'json',
			        //     success : function(result) {
			        //         if(result.success){
			        //         	_self.attr("data-op", "like");
			        //         	_self.removeClass("active");
			        //         	$(".like-num-text").each(function(){
			        //         		$(this).text(parseInt($(this).text())-1);
			        //         	});
			        //         }else{
			        //             L.Common.showTipDialog("提示", result.msg);
			        //         }
			        //     },
			        //     error : function() {
			        //         L.Common.showTipDialog("提示", "发送请求失败.");
			        //     }
			        // });
        		}
        	});
        },

        loadComments: function(pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/comments/all',
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1,
	                topic_id: _this.data.topic_id
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                	if(!result.data || (result.data && result.data.comments.length<=0)){
	                		$("#comments-body").html('<div class="alert alert-info" role="alert">没有任何评论内容</div>')
	                	}else{
	                		 _this.page(result, 1);
	                		 $("#replies").show();
	                	}
	                }else{
	                    $("#comments-body").html('<div class="alert alert-danger" role="alert">'+result.msg+'</div>');
	                }
	            },
	            error : function() {
	                $("#comments-body").html('<div class="alert alert-danger" role="alert">发送请求失败.</div>');
	            }
	        });
        },

        page: function(result, pageNo){
			var data = result.data || {};
			var $container = $("#comments-body");
			$container.empty();

			var tpl = $("#comment-item-tpl").html();
			var comments = data.comments || [];
			var can_mention_users = [];

			// convert markdown to html
			try{
				for(var i = 0; i<comments.length; i++){
		            comments[i].content = L.Common.md.render(comments[i].content);
		            var user_name = comments[i].user_name;
					_this.set_mention(user_name, can_mention_users);
				}
	            var html = juicer(tpl, data);
	            $container.html(html);
	            for(var i = 0; i<comments.length; i++){
	            	emojify.run(document.getElementById('reply_'+comments[i].id));
	            }
			}catch(e){}

			// atwho init
			_this.init_mention("#reply_content", can_mention_users);
			

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			$(".total-comment-count").each(function(){
				$(this).text(totalCount||0);
			});
			if (totalPage > 1) {
				$("#comment-pagebar").show();
				$.fn.jpagebar({
					renderTo : $("#comment-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/comments/all',
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo,
	                			topic_id: _this.data.topic_id
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#comments-body");
								$container.empty();

								var tpl = $("#comment-item-tpl").html();
								var comments = data.comments || [];
								can_mention_users = [];

								for(var i = 0; i<comments.length; i++){
						            comments[i].content = L.Common.md.render(comments[i].content);
						            var user_name = comments[i].user_name;
									_this.set_mention(user_name, can_mention_users);
								}
					            var html = juicer(tpl, data);
					            $container.html(html);
					            for(var i = 0; i<comments.length; i++){
					            	emojify.run(document.getElementById('reply_'+comments[i].id));
					            }

					            // atwho init
								_this.init_mention("#reply_content", can_mention_users);

							},
							error : function() {
								 $("#comments-body").html('<div class="alert alert-danger" role="alert">发送查找评论请求失败.</div>');
				            }
						});
					}
				});
			} else {
				$("#comment-pagebar").hide();
			}
        },

        set_mention: function(user_name, can_mention_users){
			var is_exist = false;
            for(var un in can_mention_users){
            	if(can_mention_users[un]==user_name){
            		is_exist=true;
            	}
            }
            if(!is_exist){
            	can_mention_users.push(user_name);
            }
        },

        init_mention: function(container, can_mention_users){
			if(can_mention_users && can_mention_users.length>0){
				$(container).atwho({
				    at: "@",
				    data: can_mention_users
				});
			}
        },
        
    };
}(APP));