(function (L) {
    var _this = null;
    L.Common = L.Common || {};
    _this = L.Common = {
        data: {},
 
        init: function () {

            emojify.setConfig({
                img_dir: '/static/libs/emojify/images/basic',  // Directory for emoji images
            });

            _this.md = markdownit({
                html: false,
                highlight: function (str, lang) {
                    if (lang && hljs.getLanguage(lang)) {
                        try {
                            return hljs.highlight(lang, str).value;
                        } catch (e) {}
                    }

                    return hljs.highlightAuto(str).value;; // use external default escaping
                }
            });
        },

        findUnreadMsg: function(){
            var maxRetryTimes = 5;

            var queryIntervar = setInterval(function(){
                query();
            }, 120000);

            function query(){
                $.ajax({
                    url : '/notification/unread_count',
                    type : 'get',
                    cache: false,
                    data: {},
                    dataType : 'json',
                    success : function(result) {
                        if(result.success){
                            var unread_count = result.data.count || 0;
                            if(unread_count>0){
                                $("#notification-area a").addClass("red-color");
                                $("#notification-area .count").text(unread_count).show();
                            }else{
                                $("#notification-area a").removeClass("red-color");
                                $("#notification-area .count").text(0).hide();
                            }
                        }else{
                            maxRetryTimes = maxRetryTimes-1;
                            if(maxRetryTimes <= 0){
                                clearInterval(queryIntervar);
                            }
                        }
                    },
                    error : function() {
                        maxRetryTimes = maxRetryTimes-1;
                        if(maxRetryTimes <= 0){
                            clearInterval(queryIntervar);
                        }
                    }
                });
            }

            query();
        },

        showTipDialog: function (title, content) {
            if (!content) {
                content = title;
                title = "Tips";
            }
            var d = dialog({
                title: title || 'Tips',
                content: content,
                width: 350,
                cancel: false,
                ok: function () {
                }
            });
            d.show();
        },
        
        resetNav: function(select){
            $("#main-nav-menu li").each(function(){
                $(this).removeClass("active")
            });

            if(select){
                $("#main-nav-menu li#"+select).addClass("active");
            }
        },
 
        formatDate: function (now) {
            var year = now.getFullYear();
            var month = now.getMonth() + 1;
            var date = now.getDate();
            var hour = now.getHours();
            var minute = now.getMinutes();
            var second = now.getSeconds();
            if (second < 10) second = "0" + second;
            return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
        }
    };
}(APP));