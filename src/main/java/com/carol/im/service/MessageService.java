package com.carol.im.service;

import com.carol.im.entity.MessageInfo;
import com.carol.im.util.FastDFSClient;
import com.carol.im.util.IdGeneratorSnowflake;
import com.github.tobato.fastdfs.domain.conn.FdfsWebServer;
import com.github.tobato.fastdfs.service.FastFileStorageClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.carol.im.entity.User;
import com.carol.im.result.Result;

import java.io.File;
import java.util.List;


@Service
public class MessageService {
    @Autowired
    private MongoTemplate mongoTemplate;

    @Autowired
    private FastFileStorageClient fastFileStorageClient;

    @Autowired
    private FdfsWebServer fdfsWebServer;

    @Autowired
    private FastDFSClient fastDFSClient;
    /**
     * 保存信息
     */
    public Result saveMessage(MessageInfo messageInfo){
        IdGeneratorSnowflake idGeneratorSnowflake = new IdGeneratorSnowflake();
        String pubId = messageInfo.getPubId();
        Long msgId = idGeneratorSnowflake.snowflakeId();
        messageInfo.setId(msgId);
        User user = mongoTemplate.findById(pubId, User.class);
        if (user != null) {
            messageInfo.setPubName(user.getUsername());
        }
        mongoTemplate.save(messageInfo);
        System.out.println("信息保存成功");
        return new Result(msgId);
    }

    /**
     * 通过用户id查询当前用户收到的信息
     * @return
     */
    public Result<List<MessageInfo>> getMessageInfo(){
        //UserHolder userHolder = new UserHolder();
        //String userId = userHolder.getUserLocal();
        //System.out.println("获取信息时，当前userId:"+userId);
        //构建查询条件
        //Query query = new Query(Criteria.where("subId").is(userId));
        List<MessageInfo> messageInfos = mongoTemplate.findAll(MessageInfo.class);
        Result<List<MessageInfo>> result = new Result<>(messageInfos);
        result.setCount(messageInfos.size());
        //System.out.println("查询所有消息结果："+result);
        return result;
    }


    public Result<List<MessageInfo>> rangeMessageByDefaultId(Long msgId){
        System.out.println("获取前端传入msgId:"+msgId);
        //Date date = strToDateLong(msgId);
        //Date startDate = dateToISODate(date);

        //System.out.println("查询起始时间为：========="+startDate);
        if (msgId==0){
            msgId = Long.MAX_VALUE;
        }
        Query query = new Query(Criteria.where("id").lt(msgId)).
                with(Sort.by(Sort.Direction.DESC,"id")).limit(11);
        List<MessageInfo> messageInfos = mongoTemplate.find(query, MessageInfo.class);
        if (messageInfos.isEmpty()){
            return new Result(false);
        }
        //messageInfos.remove(0);
        for (MessageInfo messageInfo : messageInfos) {
            System.out.println("查询十条历史记录"+messageInfo.getPubId());
        }
        Result<List<MessageInfo>> result = new Result<>(messageInfos);
        result.setCount(messageInfos.size());

        System.out.println("count==============="+messageInfos.size());
        return result;
    }


    public String multipartFileTest(MultipartFile multipartFile) throws Exception{
        /*System.out.println("文件名称："+multipartFile.getOriginalFilename());
        if (multipartFile.isEmpty()) return null;

        // 获取文件名
        String fileName = multipartFile.getOriginalFilename();
        // 获取文件后缀(.xml)
        if (fileName == null) {
           return null;
        }



        String suffix = fileName.substring(fileName.lastIndexOf("."));
        System.out.println("显示文件后缀："+suffix);
        File file = multipartFileToFile(multipartFile);
        //上传图片
        StorePath storePath = fastFileStorageClient.uploadFile(FileUtils.openInputStream(file), file.length(), suffix, null);
        //拼接路径   可通过该路径访问上传的照片  http://192.168.136.160:8888/group1/M00/00/00/wKiIoGMB7PmAUPZZAAHMYGEwMhg147.jpg
        System.out.println("web服务器server"+fdfsWebServer.getWebServerUrl());
        String url = fdfsWebServer.getWebServerUrl() + "/" + storePath.getFullPath();
        System.out.println(url);

        return url;*/

        String string = fastDFSClient.uploadFile(multipartFile);
        System.out.println(string);
        return string;

    }





    /**
     * 将MultipartFile转换为File
     * @param multiFile
     * @return
     */
    public File multipartFileToFile(MultipartFile multiFile) {
        // 获取文件名
        String fileName = multiFile.getOriginalFilename();
        // 获取文件后缀(.xml)
        String suffix = fileName.substring(fileName.lastIndexOf("."));
        // 若要防止生成的临时文件重复,需要在文件名后添加随机码
        File file = null;
        try {
            //"tmp", ".txt"
            //fileName这块可以根据自己的业务需求进行修改，我这里没有做任何处理
            file = File.createTempFile(fileName, suffix);
            multiFile.transferTo(file);

            return file;
        } catch (Exception e) {
            System.err.println("MultipartFile转File失败" + e);
        } finally {
            //处理掉临时文件
            if (file != null) {
                file.deleteOnExit();
            }
        }

        return null;
    }







}
