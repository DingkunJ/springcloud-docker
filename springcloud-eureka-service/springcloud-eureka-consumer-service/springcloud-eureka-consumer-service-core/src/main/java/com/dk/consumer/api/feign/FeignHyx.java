package com.dk.consumer.api.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import com.dk.consumer.api.feign.FeignApi;
import org.springframework.stereotype.Component;

@Component
public class FeignHyx implements FeignApi {

    @Override
    public String hello(){
        return "熔断啦";
    };
}
