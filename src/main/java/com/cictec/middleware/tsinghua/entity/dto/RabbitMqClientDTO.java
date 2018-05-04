package com.cictec.middleware.tsinghua.entity.dto;


import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RabbitMqClientDTO {
    private String host;
    private String port;
    private String exchangename;
    private String username;
    private String password;
    private String queuename;
}
