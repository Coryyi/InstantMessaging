package com.example.websocket;


import com.github.tobato.fastdfs.domain.conn.FdfsWebServer;
import com.github.tobato.fastdfs.domain.fdfs.StorePath;
import com.github.tobato.fastdfs.service.FastFileStorageClient;
import org.apache.commons.io.FileUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.File;
import java.io.IOException;

@RunWith(SpringRunner.class)
@SpringBootTest
public class FastDFSTest {

    @Autowired
    protected FastFileStorageClient storageClient;
    @Autowired
    private FdfsWebServer fdfsWebServer;

    @Autowired
    FastFileStorageClient fastFileStorageClient;
    @Test
    public void testUpload() {
        String path = "D:\\IMAGE\\2e8e06bd-bfe3-4af3-9540-83eb20982656.jpg";
        File file = new File(path);
        try {
            //上传图片
            StorePath storePath = this.storageClient.uploadFile(FileUtils.openInputStream(file), file.length(), "jpg", null);
            //拼接路径   可通过该路径访问上传的照片  http://192.168.136.160:8888/group1/M00/00/00/wKiIoGMB7PmAUPZZAAHMYGEwMhg147.jpg
            String url = fdfsWebServer.getWebServerUrl() + "/" + storePath.getFullPath();
            System.out.println(url);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

