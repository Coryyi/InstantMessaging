package com.carol.im.service;

import com.carol.im.entity.User;
import com.carol.im.util.UserHolder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
public class UserService {


    @Autowired
    private MongoTemplate mongoTemplate;

    //登录
    public User findByUsernameAndPassword(String username, String password) {
        //User user = userDao.findByUsernameAndPassword(username, password);
        Query query = new Query(Criteria.where("username").is(username).and("password").is(password));
        List<User> users = mongoTemplate.find(query, User.class);
        if (users.isEmpty()){
            return null;
        }
        User user = users.get(0);
        UserHolder userHolder = new UserHolder();
        userHolder.setUserLocal(String.valueOf(user.getId()));
        System.out.println("登录存入userId:"+userHolder.getUserLocal());
        return user;
    }

    //注册
    public void save(User user1) {
        mongoTemplate.insert(user1);
        //userDao.save(user1);
    }

    //注册时差询名字是否重复
    public List<User> findByUsername(String username) {
        Query query = new Query(Criteria.where("username").is(username));
        return mongoTemplate.find(query, User.class);
        //return userDao.findByUsername(username);
    }




}
