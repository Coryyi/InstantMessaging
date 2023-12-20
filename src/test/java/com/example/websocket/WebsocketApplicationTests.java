package com.example.websocket;

import org.junit.Test;
import org.springframework.boot.test.context.SpringBootTest;
import com.carol.im.util.UserHolder;

@SpringBootTest
public class WebsocketApplicationTests {


    @Test
    public void test() {
        UserHolder userHolder = new UserHolder();
        userHolder.setUserLocal("testmessage");

        UserHolder userHolder1 = new UserHolder();
        String userLocal1 = userHolder1.getUserLocal();
        System.out.println(userLocal1);
    }

}
