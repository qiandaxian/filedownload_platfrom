package com.cictec.middleware.tsinghua.router;

import com.cictec.middleware.tsinghua.processor.HttpDownloadResponseRabbitMqProcessor;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class HttpDownloadResponseRabbitMqRouter extends RouteBuilder {
    @Autowired
    HttpDownloadResponseRabbitMqProcessor httpDownloadResponseRabbitMqProcessor;

    @Value("${media.file.save-model}")
    private String saveModel;
    @Value("${rabbitmq.download.host}")
    private String host;
    @Value("${rabbitmq.download.port}")
    private String port;
    @Value("${rabbitmq.download.username}")
    private String username;
    @Value("${rabbitmq.download.password}")
    private String password;
    @Value("${rabbitmq.download.response.exchangename}")
    private String exchangename;
    @Value("${rabbitmq.download.response.queuename}")
    private String queuename;


    @Override
    public void configure() throws Exception {

        StringBuffer rabbitmqUrl = new StringBuffer();
        rabbitmqUrl.append("rabbitmq://").append(host).append(":").append(port).append("/").append(exchangename).append("?").append("username=").append(username)
                .append("&password=").append(password).append("&queue=").append(queuename);

        from(rabbitmqUrl.toString()).process(httpDownloadResponseRabbitMqProcessor);

    }
}
