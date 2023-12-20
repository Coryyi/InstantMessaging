package com.carol.im.controller;

import com.carol.im.result.Result;
import com.carol.im.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

@Controller
public class Upload {
    @Autowired
    MessageService messageService;

    @PostMapping("/api/upload")
    @ResponseBody
    public Result UploadImg(@RequestParam("multipartFile") MultipartFile multipartFile) throws Exception {
        System.err.println("前端传入图片对象："+multipartFile);
        return new Result(messageService.multipartFileTest(multipartFile));
    }
}
