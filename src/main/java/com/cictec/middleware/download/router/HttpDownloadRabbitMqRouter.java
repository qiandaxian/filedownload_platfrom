package com.cictec.middleware.download.router;

import com.cictec.middleware.download.processor.HttpDownloadRabbitMqProcessor;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class HttpDownloadRabbitMqRouter extends RouteBuilder {
    @Autowired
    HttpDownloadRabbitMqProcessor httpDownloadRabbitMqProcessor;

    @Value("${rabbitmq.host}")
    private String host;
    @Value("${rabbitmq.port}")
    private String port;
    @Value("${rabbitmq.username}")
    private String username;
    @Value("${rabbitmq.password}")
    private String password;
    @Value("${rabbitmq.receive.exchangename}")
    private String exchangename;
    @Value("${rabbitmq.receive.queuename}")
    private String queuename;


    @Override
    public void configure() throws Exception {

        StringBuffer rabbitmqUrl = new StringBuffer();
        rabbitmqUrl.append("rabbitmq://").append(host).append(":").append(port).append("/").append(exchangename).append("?").append("username=").append(username)
                .append("&password=").append(password).append("&queue=").append(queuename);

        from(rabbitmqUrl.toString()).process(httpDownloadRabbitMqProcessor);

    }
}
