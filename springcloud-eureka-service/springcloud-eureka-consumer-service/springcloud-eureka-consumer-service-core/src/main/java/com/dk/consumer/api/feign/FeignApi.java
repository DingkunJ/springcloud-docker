package com.dk.consumer.api.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import com.dk.consumer.api.feign.FeignHyx;

@FeignClient(name = "SayHelloWorld", fallback = FeignHyx.class)
public interface FeignApi {

    @RequestMapping("/hello")
    String hello();
}
