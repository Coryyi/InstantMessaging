package com.carol.im.util;


public class UserHolder {

    private static ThreadLocal<String> userLocal = new ThreadLocal<String>();
    public String getUserLocal(){
        return userLocal.get();
    }

    public void  setUserLocal(String userId){
        userLocal.set(userId);
    }
}
