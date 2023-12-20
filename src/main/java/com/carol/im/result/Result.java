package com.carol.im.result;

import com.sun.org.apache.xpath.internal.operations.Bool;

public class Result<T> {
    //数量
    private int count;
    //是否成功
    private boolean isSuccess;
    //信息
    private String message;
    private T data;

    public Result(T data){
        this.isSuccess=true;
        this.data = data;
    }
    public Result(Boolean isSuccess){
        this.isSuccess = isSuccess;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public boolean isSuccess() {
        return isSuccess;
    }

    public void setSuccess(boolean success) {
        isSuccess = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getDate() {
        return data;
    }

    public void setDate(T data) {
        this.data = data;
    }
}
