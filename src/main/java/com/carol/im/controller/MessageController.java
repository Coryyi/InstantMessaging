package com.carol.im.controller;

import com.carol.im.entity.MessageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import com.carol.im.result.Result;
import com.carol.im.service.MessageService;

import java.util.List;

@Controller
@RequestMapping("/message")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @PostMapping("/save")
    @ResponseBody
    public Result saveMessage(@RequestBody MessageInfo messageInfo){
        return messageService.saveMessage(messageInfo);

    }

    @GetMapping("/getAll")
    @CrossOrigin
    @ResponseBody
    public Result<List<MessageInfo>> getMessages(){
        return messageService.getMessageInfo();
    }

    @ResponseBody
    @GetMapping("/rangeMsg")
    @CrossOrigin
    public Result<List<MessageInfo>> rangeMsg(Long msgId) {
        System.out.println("前端传入时间：============== " + msgId);
        return messageService.rangeMessageByDefaultId(msgId);
    }

}
