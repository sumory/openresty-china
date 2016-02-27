(function (L) {
    var _this = null;
    L.UserIndex = L.UserIndex || {};
    _this = L.UserIndex = {
        data: {
        	username:"",
        	load_topics:false,
        	load_collects:false,
        	load_comments:false,
        	load_fans:false,
        	load_follows:false,
        	load_hot_topics:false,
        	load_like_topics:false
        },
 
        init: function (username) {
        	_this.data.username = username;
        	_this.initEvents();
        	$("#btn-show-hot-topics").click();
        },

        initEvents:function() {
        	var username = _this.data.username;

        	$("#btn-show-topics").click(function(){
        		if(!_this.data.load_topics){
        			_this.loadUserTopics(_this.data.username, 1);
        			_this.data.load_topics = true;
        		}
        	});

        	$("#btn-show-comments").click(function(){
        		if(!_this.data.load_comments){
        			_this.loadUserComments(_this.data.username, 1);
        			_this.data.load_comments = true;
        		}
        	});

        	$("#btn-show-collects").click(function(){
        		if(!_this.data.load_collects){
        			_this.loadUserCollects(_this.data.username, 1);
        			_this.data.load_collects = true;
        		}
        	});

        	$("#btn-show-follows").click(function(){
        		if(!_this.data.load_follows){
        			_this.loadUserFollows(_this.data.username, 1);
        			_this.data.load_follows = true;
        		}
        	});

        	$("#btn-show-fans").click(function(){
        		if(!_this.data.load_fans){
        			_this.loadUserFans(_this.data.username, 1);
        			_this.data.load_fans = true;
        		}
        	});

        	$("#btn-show-hot-topics").click(function(){
        		if(!_this.data.load_hot_topics){
        			_this.loadUserHotTopics(_this.data.username, 1);
        			_this.data.load_hot_topics = true;
        		}
        	});

        	$("#btn-show-like-topics").click(function(){
        		if(!_this.data.load_like_topics){
        			_this.loadUserLikeTopics(_this.data.username, 1);
        			_this.data.load_like_topics = true;
        		}
        	});

        	$(".sidebar-fans a").click(function(){
        		$("#btn-show-fans").click();
        	});

        	$(".sidebar-follows a").click(function(){
        		$("#btn-show-follows").click();
        	});

        	$(".sidebar-topics a").click(function(){
        		$("#btn-show-topics").click();
        	});


        	_this.initDeleteTopic();
            _this.initDeleteComment();
        	_this.initRelationOp();

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
                        	$("#topic-li-"+topic_id).remove();
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
                            $("#comment-li-"+comment_id).remove();
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


 
        initRelationOp:function(){
            $(document).on('click', '.follow-btn', function(){
                //var current_relation = $(this).attr("data-relation");
                var op = $(this).attr("data-op");
                var to_id = $(this).attr("data-toid");
                var _self = $(this);
                if(op==="follow"){
                    $.ajax({
                        url : '/user/follow',
                        type : 'post',
                        data : {
                            to_id:to_id
                        },
                        dataType : 'json',
                        success : function(result) {
                            if(result.success ){
                            	var relation = result.data.relation;
                            	var relation_text= "";
                            	if(relation == 0){
                                   relation_text="";
                            	}
                                else if(relation == 1){
                                   relation_text="已关注";
                                }
                                else if(relation == 2){
                                   relation_text="ta关注了我";
                                }
                                else if(relation == 3){
                                   relation_text="互相关注";
                                }
              
                            	var tpl = $("#relation-op-area-tpl").html();
                            	var html = juicer(tpl, {
                            		user_id: to_id,
                            		op: "unfollow",
                            		relation: relation,
                            		text: "取消关注",
                            		relation_text: relation_text
                            	});
                            	$("#relation-op-area").html(html);

                            	$("#fans-count").text(result.data.fans_count);
                            	$("#follows-count").text(result.data.follows_count);
                            }else{
                                L.Common.showTipDialog("提示", result.msg);
                            }
                        },
                        error : function() {
                            L.Common.showTipDialog("提示", "关注操作请求发生错误");
                        }
                    });
                }else if(op==="unfollow"){
                    $.ajax({
                        url : '/user/cancel_follow',
                        type : 'post',
                        data : {
                            to_id:to_id
                        },
                        dataType : 'json',
                        success : function(result) {
                            if(result.success ){
                                var relation = result.data.relation;
                            	var relation_text= "";
                            	if(relation == 0){
                                   relation_text="";
                            	}
                                else if(relation == 1){
                                   relation_text="已关注";
                                }
                                else if(relation == 2){
                                   relation_text="ta关注了我";
                                }
                                else if(relation == 3){
                                   relation_text="互相关注";
                                }
              
                            	var tpl = $("#relation-op-area-tpl").html();
                            	var html = juicer(tpl, {
                            		user_id: to_id,
                            		op: "follow",
                            		relation: relation,
                            		text: "关注",
                            		relation_text: relation_text
                            	});
                            	$("#relation-op-area").html(html);

                            	$("#fans-count").text(result.data.fans_count);
                            	$("#follows-count").text(result.data.follows_count);
                            }else{
                                L.Common.showTipDialog("提示", result.msg);
                            }
                        },
                        error : function() {
                            L.Common.showTipDialog("提示", "取消关注操作请求发生错误");
                        }
                    });
                }

            });
        },

        loadUserTopics: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/topics",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserTopics(result, 1, username);
	                }else{
	                    $("#topics-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#topics-body").html("error to send request.");
	            }
	        });
        },

        pageUserTopics: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#topics-body");
			$container.empty();

			var tpl = $("#topic-item-tpl").html();
            var html = juicer(tpl, data);
            $container.html(html);

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#topics-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#topics-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/topics",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#topics-body");
								$container.empty();

								var tpl = $("#topic-item-tpl").html();
					            var html = juicer(tpl, data);
					            $container.html(html);
							},
							error : function() {
				                $("#topics-body").html("error to find topics page.");
				            }
						});
					}
				});
			} else {
				$("#topics-pagebar").parent().hide();
			}
        },

        loadUserComments: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/comments",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserComments(result, 1, username);
	                }else{
	                    $("#comments-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#comments-body").html("发送评论查询请求错误.");
	            }
	        });
        },

        pageUserComments: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#comments-body");
			$container.empty();

	
            var tpl = $("#comment-item-tpl").html();
			var comments = result.data.comments || [];
			for(var i = 0; i<comments.length; i++){
	            comments[i].comment_content = L.Common.md.render(comments[i].comment_content);
			}
            var html = juicer(tpl, result.data);
            $container.html(html);
            for(var i = 0; i<comments.length; i++){
            	emojify.run(document.getElementById('reply_'+comments[i].comment_id));
            }


			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#comments-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#comments-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/comments",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var $container = $("#comments-body");
								$container.empty();

								var tpl = $("#comment-item-tpl").html();
								var comments = result.data.comments || [];
								for(var i = 0; i<comments.length; i++){
						            comments[i].comment_content = L.Common.md.render(comments[i].comment_content);
								}
					            var html = juicer(tpl, result.data);
					            $container.html(html);
					            for(var i = 0; i<comments.length; i++){
					            	emojify.run(document.getElementById('reply_'+comments[i].comment_id));
					            }
							},
							error : function() {
				                $("#comments-body").html("error to find comments page.");
				            }
						});
					}
				});
			} else {
				$("#comments-pagebar").parent().hide();
			}
        },

        loadUserCollects: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/collects",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserCollects(result, 1, username);
	                }else{
	                    $("#collects-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#collects-body").html("error to send request.");
	            }
	        });
        },

        pageUserCollects: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#collects-body");
			$container.empty();

			var tpl = $("#collect-item-tpl").html();
            var html = juicer(tpl, data);
            $container.html(html);

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#collects-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#collects-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/collects",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#collects-body");
								$container.empty();

								var tpl = $("#collect-item-tpl").html();
					            var html = juicer(tpl, data);
					            $container.html(html);
							},
							error : function() {
				                $("#collects-body").html("error to find collects page.");
				            }
						});
					}
				});
			} else {
				$("#collects-pagebar").parent().hide();
			}
        },

        loadUserFollows: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/follows",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserFollows(result, 1, username);
	                }else{
	                    $("#follows-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#follows-body").html("error to send request.");
	            }
	        });
        },

        pageUserFollows: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#follows-body");
			$container.empty();

			var tpl = $("#follow-item-tpl").html();
            var html = juicer(tpl, data);
            $container.html(html);

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#follows-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#follows-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/follows",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#follows-body");
								$container.empty();

								var tpl = $("#follow-item-tpl").html();
					            var html = juicer(tpl, data);
					            $container.html(html);
							},
							error : function() {
				                $("#follows-body").html("error to find follows page.");
				            }
						});
					}
				});
			} else {
				$("#follows-pagebar").parent().hide();
			}
        },

        loadUserFans: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/fans",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserFans(result, 1, username);
	                }else{
	                    $("#fans-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#fans-body").html("error to send request.");
	            }
	        });
        },

        pageUserFans: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#fans-body");
			$container.empty();

			var tpl = $("#fan-item-tpl").html();
            var html = juicer(tpl, data);
            $container.html(html);

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#fans-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#fans-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/fans",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#fans-body");
								$container.empty();

								var tpl = $("#fan-item-tpl").html();
					            var html = juicer(tpl, data);
					            $container.html(html);
							},
							error : function() {
				                $("#fans-body").html("error to find fans page.");
				            }
						});
					}
				});
			} else {
				$("#fans-pagebar").parent().hide();
			}
        },
 
 		loadUserHotTopics: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/hot_topics",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserHotTopics(result, 1, username);
	                }else{
	                    $("#hot-topics-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#hot-topics-body").html("error to send request.");
	            }
	        });
        },

        pageUserHotTopics: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#hot-topics-body");
			$container.empty();

			var tpl = $("#hot-topic-item-tpl").html();
            var html = juicer(tpl, data);
            $container.html(html);

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#hot-topics-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#hot-topics-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/hot_topics",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#hot-topics-body");
								$container.empty();

								var tpl = $("#hot-topic-item-tpl").html();
					            var html = juicer(tpl, data);
					            $container.html(html);
							},
							error : function() {
				                $("#hot-topics-body").html("error to find topics page.");
				            }
						});
					}
				});
			} else {
				$("#hot-topics-pagebar").parent().hide();
			}
        },

        loadUserLikeTopics: function(username, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/user/' + username + "/like_topics",
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                    _this.pageUserLikeTopics(result, 1, username);
	                }else{
	                    $("#like-topics-body").html(result.msg);
	                }
	            },
	            error : function() {
	                $("#like-topics-body").html("error to send request.");
	            }
	        });
        },

        pageUserLikeTopics: function(result, pageNo, username){
			var data = result.data || {};
			var $container = $("#like-topics-body");
			$container.empty();

			var tpl = $("#like-topic-item-tpl").html();
            var html = juicer(tpl, data);
            $container.html(html);

			var currentPage = data.currentPage;
			var totalPage = data.totalPage;
			var totalCount = data.totalCount;
			if (totalPage > 1) {
				$("#like-topics-pagebar").parent().show();
				$.fn.jpagebar({
					renderTo : $("#like-topics-pagebar"),
					totalpage : totalPage,
					totalcount : totalCount,
					pagebarCssName : 'pagination2',
					currentPage : currentPage,
					onClickPage : function(pageNo) {
						$.fn.setCurrentPage(this, pageNo);
						$.ajax({
							url : '/user/' + username + "/like_topics",
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo
				            },
							dataType : 'json',
							success : function(result) {
								var data = result.data || {};
								var $container = $("#like-topics-body");
								$container.empty();

								var tpl = $("#like-topic-item-tpl").html();
					            var html = juicer(tpl, data);
					            $container.html(html);
							},
							error : function() {
				                $("#like-topics-body").html("error to find topics page.");
				            }
						});
					}
				});
			} else {
				$("#like-topics-pagebar").parent().hide();
			}
        },
        
    };
}(APP));