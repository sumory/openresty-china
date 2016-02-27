(function (L) {
    var _this = null;
    L.Index = L.Index || {};
    _this = L.Index = {
        data: {
        	current_category: "0"
        },
 
        init: function (current_category) {
        	_this.data.current_category = current_category || "0"
        	_this.loadTopics("default");
        	_this.initEvents();
        },

        initEvents: function(){
        	$(document).on("click", "#topic-type-tab a", function(){
        		$("#topic-type-tab a").each(function(){
        			$(this).removeClass("active");
        		});

        		$(this).addClass("active");
        	});

        	$("#default-topics-btn").click(function(){
        		_this.loadTopics("default");
        	});

        	$("#recent-reply-topics-btn").click(function(){
        		_this.loadTopics("recent-reply");
        	});

        	$("#good-topics-btn").click(function(){
        		_this.loadTopics("good");
        	});

        	$("#noreply-topics-btn").click(function(){
        		_this.loadTopics("noreply");
        	});
        },

        loadTopics: function(type, pageNo){
        	pageNo = pageNo || 1;
        	$.ajax({
	            url : '/topics/all',
	            type : 'get',
	            cache: false,
	            data: {
	                page_no: 1,
	                type: type,
	                category: _this.data.current_category
	            },
	            dataType : 'json',
	            success : function(result) {
	                if(result.success){
	                	if(!result.data || (result.data && result.data.topics.length<=0)){
	                		$("#topics-body").html('<div class="alert alert-info" role="alert">此分类下没有任何内容</div>');
	                	}else{
	                		 _this.page(result, type, 1);
	                	}
	                }else{
	                    $("#topics-body").html('<div class="alert alert-danger" role="alert">'+result.msg+'</div>');
	                }
	            },
	            error : function() {
	                $("#topics-body").html('<div class="alert alert-danger" role="alert">error to send request.</div>');
	            }
	        });
        },

        page: function(result, type, pageNo){
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
							url : '/topics/all',
				            type : 'get',
				            cache: false,
				            data: {
				                page_no: pageNo,
				                type: type,
	                			category: _this.data.current_category
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
								 $("#topics-body").html('<div class="alert alert-danger" role="alert">error to find topics page.</div>');
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