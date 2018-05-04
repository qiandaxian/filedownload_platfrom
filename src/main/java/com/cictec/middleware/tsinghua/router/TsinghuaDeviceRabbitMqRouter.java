package com.cictec.middleware.tsinghua.router;

import com.cictec.middleware.tsinghua.processor.TsinghuaRabbitMqProcessor;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class TsinghuaDeviceRabbitMqRouter extends RouteBuilder {
    @Autowired
    TsinghuaRabbitMqProcessor tsinghuaRabbitMqProcessor;

    @Value("${rabbitmq.tsinghua.host}")
    private String host;
    @Value("${rabbitmq.tsinghua.port}")
    private String port;
    @Value("${rabbitmq.tsinghua.exchangename}")
    private String exchangename;
    @Value("${rabbitmq.tsinghua.username}")
    private String username;
    @Value("${rabbitmq.tsinghua.password}")
    private String password;
    @Value("${rabbitmq.tsinghua.queuename}")
    private String queuename;
    @Value("${rabbitmq.tsinghua.skipqueuedeclare}")
    private String skipqueuedeclare;


    @Override
    public void configure() throws Exception {

        StringBuffer rabbitmqUrl = new StringBuffer();
        rabbitmqUrl.append("rabbitmq://").append(host).append(":").append(port).append("/").append(exchangename).append("?").append("username=").append(username)
                .append("&password=").append(password).append("&skipQueueDeclare=").append(skipqueuedeclare).append("&queue=").append(queuename);

        from(rabbitmqUrl.toString()).process(tsinghuaRabbitMqProcessor);

    }
}
