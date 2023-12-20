<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Access-Control-Allow-Origin" content="*">
    <title>即时通讯</title>


    <link rel="stylesheet" href="/css/bootstrap.css"/>
    <link rel="stylesheet" href="/css/font-awesome.min.css"/>
    <link rel="stylesheet" href="/css/build.css"/>
    <link rel="stylesheet" type="text/css" href="/css/qq.css"/>

</head>
<body>


<div class="qqBox">
    <div class="context">
        <div class="conLeft">
            <ul id="userList">

            </ul>
        </div>
        <div class="conRight">
            <div class="Righthead">
                <div class="headName">${userName}</div>
            </div>
            <div class="RightCont" >
                <p id="searchMsg" style="color: #2e6da4;text-align:center; margin-left: auto; margin-right: auto" onclick="searchMsg()">查询历史记录</p>
                <ul class="newsList" id="message">
                    <li id="top-li"></li>
                </ul>
            </div>
            <div class="RightMiddle">
                <div class="file">
                    <img src="/img/file.jpg" height="30px" width="30px" onclick="fileSelect()">
                    <form id="form_photo" method="post" enctype="multipart/form-data"
                          style="width:auto;">
                        <input type="file" accept="image/png, image/jpeg, image/jpg" name="filename" id="filename" onchange="fileSelected();"
                               style="display:none;">
                        <!-- <button id="fasongPhoto" name="fasongPhoto" class="sendBtn" type="submit"
                        style="border-radius: 5px"></button> -->
                    </form>
                </div>
                <button id="new-notion" style="position: relative;bottom: 30px ;text-align: center;display: none;left: 500px;border-width: 0px;border-radius:10px;color: white;background: red"
                        onclick="toBottom()">new</button>
            </div>
            <div class="RightFoot">


                    <textarea id="dope"
                              style="width: 100%;height: 100%; border: none;outline: none;padding:20px 0 0 3%;" name=""
                              rows="" cols=""></textarea>
                <button id="fasong" class="sendBtn" onclick="send()" style="border-radius: 5px">发送</button>
            </div>
        </div>
    </div>
</div>


<script src="/js/jquery_min.js"></script>
<script src="https://cdn.bootcss.com/jquery.form/4.2.2/jquery.form.min.js"></script>
<script type="text/javascript"  >
    //change ip to yours
    var IP_ADDR = "127.0.0.1";
    //fastdfs webserver ip addr
    var FASTDFS_SERVER_IP_ADDR = "http://127.0.0.1:8888/";

    var globalId = 0;

    //标记是否发送过消息
    var IS_SAND_MESSAGE = false;

    //js获取后端model传过来的对象
    var userId = "${userId}";
    //console.log("获取后端传值用户id"+userId);
    sessionStorage.setItem("userId",userId);

    var userName = "${userName}"
    sessionStorage.setItem("userName",userName)

    var webSocket = null;

    //滚动到底部
    function toBottom(){
        document.getElementById("new-notion").style.display="none";
        console.log("执行向下滚动")
        // 滑动底部
        let messageContain = document.querySelector(".RightCont");
        console.log("messageContain长度"+messageContain.scrollHeight)
        messageContain.scrollTop = messageContain.scrollHeight;
        /*toBottom.scrollTo({
            top: document.documentElement.scrollHeight,
            behavior: "smooth",
        });*/

    }

    //检测是否在对话框底部
    document.querySelector('.RightCont').addEventListener('scroll',function () {
        //读取内容区域的真实高度（滚动条高）
        console.log(this.scrollHeight);
        //读取滚动条的位置
        console.log(this.scrollTop);
        //设置滚动到的位置
           // this.scrollTop=800;
        //读取元素的高度
        console.log(this.clientHeight)
        //意思就是内容总体的高度 - 滚动条的偏移值  === 元素的高度(包含内边)但不包含外边距，边框，以及滚动条
        console.log("客户端液面高度+滚动条距离顶部距离："+(this.clientHeight+this.scrollTop)+ " 总高度："+ this.scrollHeight)

        if(this.scrollHeight-this.clientHeight-this.scrollTop<10){
            document.getElementById('new-notion').style.display = "none";
            console.log("到达底部");
        }
    })

    function searchMsg(){
        var msgId = globalId;

        IS_SAND_MESSAGE = true;

        //var time = sessionStorage.getItem(TOP_MESSAGE_DATE);

        //console.log("查询参数data为:================"+msgId)
        $.ajax({
            "async": true,
            "crossDomain": true,
            url: "http://"+IP_ADDR+":8090/message/rangeMsg",
            type: "GET",
            dataType: "json",
            data: {'msgId' : msgId},
            success: function (data) {
                var json= JSON.stringify(data);
                //console.log("接收后断查询消息记录返回的数据"+json);

                //获取当前用户id
                var userId = sessionStorage.getItem("userId").toString();

                /*var obj = data.parseJSON();
                var objData = obj.data;
                console.log("onjData"+objData)
                var dataList = objData.parseJSON();*/
                var obj = JSON.parse(json);
                //console.log("接收后断查询消息记录返回的数据"+obj);
                ///var objData = obj.date;
                /*console.log("objData==============="+objData)*/
                //修复重复刷出
                //console.log("obj解析出结果为："+obj)
                if (obj==null){
                    return
                }
                var size = obj.date.length
                //console.log("长度==============="+size)
                for (let i = 0; i < size; i++) {
                    if (globalId === obj.date[i].id){
                        continue;
                    }
                    //console.log("pubId===============:"+o bj.date[i].pubId)
                    //console.log("content================:"+obj.date[i].content)
                    //console.log("这是查询到的第 " + i +" 条数据")
                    if (obj.date[i].pubId === userId){
                        var content = obj.date[i].content;
                        if (content.indexOf("是否发送图片：") !== -1){
                            //图片信息
                            var pubTime = obj.date[i].date;
                            setMyOldMessage(content,pubTime)
                        }else {
                            content = obj.date[i].pubName+" "+obj.date[i].date+"</br>"+obj.date[i].content
                            setMyOldMessage(content)
                        }
                    }else {
                        setOldMessageInnerHTML(obj.date[i].pubName+" "+obj.date[i].date+"</br>"+obj.date[i].content);
                    }
                    //console.log("第 " + i +" 条数据加载完成")

                }

                //console.log("最后一个信息的id："+obj.date[size-1].id);
                globalId = obj.date[size-1].id;
                ///将最后一个信息id存入sessionStorage
                //sessionStorage.setItem(TOP_MESSAGE_DATE,obj.date[0].date)
            },
            error: function (e) {
                alert("查询信息失败");
            }
        });
    }


    //判断当前浏览器是否支持WebSocket
    if ('WebSocket' in window) {
        webSocket = new WebSocket('ws://'+IP_ADDR+':8090/webSocket?username=' + '${userName}');

    } else {
        alert("当前浏览器不支持WebSocket");
    }

    //连接发生错误的回调方法
    webSocket.onerror = function () {
        setMessageInnerHTML("WebSocket连接发生错误！");
    }

    webSocket.onopen = function () {
        setMessageInnerHTML("WebSocket连接成功！")
    }

    webSocket.onmessage = function (event) {
        //获取new圆点
        var newNotion = document.getElementById("new-notion");
        //如果显示区域小于实际列表长度
        var rightCont = document.querySelector(".RightCont");
        console.log("显示区域高度："+rightCont.clientHeight+'\n'+"实际区域高度："+rightCont.scrollHeight)

        if (rightCont.scrollHeight!==rightCont.clientHeight){
            console.log("显示区域高度："+rightCont.clientHeight+'\n'+"实际区域高度："+rightCont.scrollHeight)
            console.log("判断结果："+(rightCont.scrollHeight!==rightCont.clientHeight))
            newNotion.style.display="block";
        }

        newNotion.style.display="block"
        $("#userList").html("");
        eval("var msg=" + event.data + ";");

        //console.log("接收到消息传入的参数 event："+event+"\n以及event.data:"+event.data)


        if (undefined !== msg.content)
            setMessageInnerHTML(msg.content);
        if (undefined != msg.names) {
            $.each(msg.names, function (key, value) {
                var htmlstr = '<li>'
                        + '<div class="checkbox checkbox-success checkbox-inline">'
                        + '<input type="checkbox" class="styled" id="' + key + '" value="' + key + '" checked>'
                        + '<label for="' + key + '"></label>'
                        + '</div>'
                        + '<div class="liLeft"><img src="/img/robot2.jpg"/></div>'
                        + '<div class="liRight">'
                        + '<span class="intername">' + value + '</span>'
                        + '</div>'
                        + '</li>'

                $("#userList").append(htmlstr);
            })
        }
    }

    webSocket.onclose = function () {
        setMessageInnerHTML("WebSocket连接关闭");
    }

    window.onbeforeunload = function () {
        closeWebSocket();
    }

    function closeWebSocket() {
        webSocket.close();
    }

    //文件上传
    function fileSelect() {
        document.getElementById("filename").click();
    }

    function fileSelected() {
        // 文件选择后触发此函数
        var filenames = document.getElementById("filename");
        var len = filenames.files.length;
        var temp;
        for (var i = 0; i < len; i++) {
            temp = filenames.files[i].name;
            $("#dope").val("是否发送图片：" + temp);
        }
    }
    //表单提交,会把所有有name属性的值提交到后台
    function getJson(onSuccess) {
        //var form = new FormData(document.getElementById("form_photo"));
        var form = new FormData();
        //var img_element = document.getElementById("form_photo")
        var multipartFile = $('#filename').get(0).files[0]
        form.append("multipartFile",multipartFile)
        //console.log("前端传入图像："+form)
        $.ajax({
            "async": false,
            "crossDomain": true,
            url: "http://"+IP_ADDR+":8090/api/upload",
            type: "post",
            dataType: 'json',
            mimeType: "multipart/form-data",
            data: form,
            headers: {
                "cache-control": "no-cache",
            },
            processData: false,
            contentType: false,
            success: function (data) {
                //console.log("获取取后端传回的数据："+data)
                //string = JSON.parse(data);
                //console.log("解析后的对象："+string);
                var url = data.date
                //获取发送方图片url
                onSuccess(url);
            },
            error: function (e) {
                alert("文件过大！请重试");
            }
        });

    }

    /**
     * 预览图片
     */

    function onLoadImage() {
        var file=$('#filename').get(0).files[0];
        var reader = new FileReader();
        //将文件以Data URL形式读入页面
        reader.readAsDataURL(file);
        reader.onload=function(e){
            //显示文件
            $("#onLoadImage").html('<img src="' + this.result +'" alt="" />');
        }
    }


    /**
     * 显示历史信息
     * @param message
     * @param pubTime
     */
    function setMyOldMessage(message,pubTime){
        //加载图片
        if (message.indexOf("是否发送图片：") !== -1) {
            //发送图片
            // $("#fasongPhoto").submit();
            // var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div class="answers">'
            //     + '[本人]' + '   ' + pubTime + '<br/>' + '<img id="jsonImg">' + '</div></li>';
            var userName = sessionStorage.getItem("userName");
            var url = message.substring(0,message.indexOf("是否发送图片："))
            //console.log("加载我的消息记录中的图片url："+url)
            var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div style="background-color: greenyellow" class="answers">'
                + userName + '   ' + pubTime + '<br/>' + '<img src="' + url +'"/>' + '</div></li>';
        } else {

            //发送消息
            /*var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div class="answers">'
                + '[本人]' + '   ' + time + '<br/>' + message + '</div></li>';*/

            var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div style="background-color: greenyellow" class="answers">'
                + message + '</div></li>';
            //webSocketSend(htmlstr,message,"");
        }
        $("#message").prepend(htmlstr);

    }

    /**
     * 发送信息
     */
    function send() {
        var timeDate = new Date();
        //time = timeDate.toLocaleString();

        var message = $("#dope").val();
        $("#dope").val("");
        //生成发送消息时间
        var msgTime = parseDate(timeDate)

        //发送图片
        if (message.search("是否发送图片：") == 0) {
            //发送图片
            //console.log("正在发送图片")
            // $("#fasongPhoto").submit();
            var url = null


            //获取接收图片url
            getJson(function(re){
                url = webSocketSend(htmlstr,message,re);
                //console.log("返回的url"+url)
            });

            var userName = sessionStorage.getItem("userName")
            var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div style="background-color: greenyellow" class="answers">'
                + userName + '   ' + msgTime  + '<br/>' + '<img src="' + url +'"/>' + '</div></li>';
            message = url + message;
            $("#message").append(htmlstr);
        } else {
            //发送消息
            var htmlstr = '<li><div class="answerHead"><img src="/img/2.png"></div><div style="background-color: greenyellow" class="answers">'
                    + sessionStorage.getItem("userName") + '   ' + msgTime + '<br/>' + message + '</div></li>';
            webSocketSend(htmlstr,message,"");

            $("#message").append(htmlstr);
        }
        toBottom();


        //获取当前用户id
        var storage = window.sessionStorage;

        var pubId = storage.getItem("userId")
        //console.log("发送信息，从sessionStorage获取当前用户id："+pubId);

        //格式化日期
        //console.log("开始格式化日期,当前时间:"+timeDate)
        var year = timeDate.getFullYear(); //得到年份
        var month = timeDate.getMonth(); //得到月份
        var date = timeDate.getDate(); //得到日期

        var hour = timeDate.getHours();
        //console.log("Hours======="+hour)
        var minute = timeDate.getMinutes();
        //console.log("minute======="+minute)

        var second = timeDate.getSeconds();
        //console.log("second======="+second)

        month = month + 1;
        if (month < 10) month = "0" + month;
        if (date < 10) date = "0" + date;

        if(hour<10) hour = "0" + hour;
        if (minute<10) minute = "0" + minute;
        if (second<10) second = "0" +second;
        var timeStr = year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second; //（格式化"yyyy-MM-dd HH:mm:ss"）

        //console.log("格式化日期以后：=========="+timeStr)
        $.ajax({
            "async": true,
            "crossDomain": true,
            url: "http://"+IP_ADDR+":8090/message/save",
            contentType: "application/json;charset=UTF-8",
            type: "POST",
            mimeType: "multipart/form-data",
            data: JSON.stringify(
                {
                    "pubId" : pubId,
                    "subId" : "0",
                    "date" : timeStr,
                    "content" : message
                }
            ),
            headers: {
                "cache-control": "no-cache",
            },
            processData: false,
            success: function (data) {
                //console.log("保存信息后，接收后端返回信息id数据："+data)
                var string = JSON.parse(data);
                //console.log(string);
                if (IS_SAND_MESSAGE===false){
                    //获取信息id
                    var msgId = string.date;
                    globalId = msgId;
                    //console.log("发送消息后此时全局id为："+globalId+"刚发送的消息id为："+msgId)
                    IS_SAND_MESSAGE = true;
                }

            },
            error: function (e) {
                alert("保存信息失败");
            }
        });
    };

    function parseDate(timeDate){
        //格式化日期
        //console.log("开始格式化日期,当前时间:"+timeDate)
        var year = timeDate.getFullYear(); //得到年份
        var month = timeDate.getMonth(); //得到月份
        var date = timeDate.getDate(); //得到日期

        var hour = timeDate.getHours();
        //console.log("Hours======="+hour)
        var minute = timeDate.getMinutes();
        //console.log("minute======="+minute)

        var second = timeDate.getSeconds();
        //console.log("second======="+second)

        month = month + 1;
        if (month < 10) month = "0" + month;
        if (date < 10) date = "0" + date;

        if(hour<10) hour = "0" + hour;
        if (minute<10) minute = "0" + minute;
        if (second<10) second = "0" +second;
         //（格式化"yyyy-MM-dd HH:mm:ss"）
        return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
    }

    function webSocketSend(htmlstr,message,re){

        //$("#message").append(htmlstr);

        var ss = $("#userList :checked");
        //console.log("ss==============================="+ss)
        var to = "";
        $.each(ss, function (key, value) {
            to += value.getAttribute("value") + "-";
        })
        //console.info(to);
        //console.log("当前构建对象中的message为："+message)
        if (re){
            message = re + message;
        }
        if (ss.size() == 0) {
            var obj = {
                msg: message,
                type: 1
            }
        } else {
            var obj = {
                to: to,
                msg: message,
                type: 2
            }
        }
        var msg = JSON.stringify(obj);
        //console.log("websocket调用参数msg=======================："+msg)

        webSocket.send(msg);

        if(re){
            message = re + message;
            //console.log("让我看看传入的re是个什么鬼东西："+re)
            //$("#jsonImg").attr("src",re);
            // loadDiv(re);
            return re
        }

        //如果还是不行 就用延时执行函数 setTimeout 把注释放掉
        // setTimeout(function(){
        //     if(re){
        //     $("#jsonImg").attr("src", string.data);
        //     loadDiv(re);
        // }
        // },3000)



    }


    //回车键发送消息
    $(document).keypress(function (e) {

        if ((e.keyCode || e.which) == 13) {
            $("#fasong").click();
        }

    });

    //局部刷新div
    function loadDiv(sJ) {
        $("#delayImgPer").html('<img src="'+sJ+'" class="delayImg" >');
    }

    //将新消息显示在网页上
    function setMessageInnerHTML(innerHTML) {
        //console.log("显示加载新消息传入参数innerHtml："+innerHTML)
        if (innerHTML.indexOf("是否发送图片：") != -1) {
            var subStr = innerHTML.substring(innerHTML.indexOf(FASTDFS_SERVER_IP_ADDR), innerHTML.indexOf("是否发送图片："));
            //console.log("解析innerHtml中的subStr（url）"+subStr)
            var msg = '<li>'
                    + '<div class="nesHead">'
                    + '<img src="/img/robot.jpg">'
                    + ' </div>'
                    + '<div class="news">'
                    +  innerHTML.substring(0,innerHTML.indexOf(FASTDFS_SERVER_IP_ADDR))
                    + '<img class="delayImg" src="'+subStr+'"/>'
                    + '</div>'
                    + '</li>';
        } else {
            var msg = '<li>'
                    + '<div class="nesHead">'
                    + '<img src="/img/robot.jpg">'
                    + ' </div>'
                    + '<div class="news">'
                    + innerHTML
                    + '</div>'
                    + '</li>';
        }
        $("#message").append(msg);

    }

    //将查询消息显示在网页上
    function setOldMessageInnerHTML(innerHTML) {
        //console.log("打印查询历史记录，加载的消息语句"+innerHTML)
        if (innerHTML.indexOf("是否发送图片：") != -1) {
            //console.log("加载历史图片信息"+innerHTML.indexOf("是否发送图片："))
            var subStr = innerHTML.substring(innerHTML.indexOf(FASTDFS_SERVER_IP_ADDR), innerHTML.indexOf("是否发送图片："));
            var nameAndDate = innerHTML.substring(0,innerHTML.indexOf(FASTDFS_SERVER_IP_ADDR))
            var msg = '<li>'
                + '<div class="nesHead">'
                + '<img src="/img/robot.jpg">'
                + ' </div>'
                + '<div class="news">'
                + nameAndDate
                + '<img class="delayImg" src="'+ subStr +'"/>'
                + '</div>'
                + '</li>';
        } else {
            var msg = '<li>'
                + '<div class="nesHead">'
                + '<img src="/img/robot.jpg">'
                + ' </div>'
                + '<div class="news">'
                + innerHTML
                + '</div>'
                + '</li>';
        }
        $("#message").prepend(msg);

        //var targetNode = $("#top-li")
        //console.log("获取第一个li，显示inner"+targetNode)
        //var parentNode = $("#message")
        //parentNode.insertBefore(msg,targetNode);


    }

</script>

</body>
</html>
