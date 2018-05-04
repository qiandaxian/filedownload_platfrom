package com.cictec.middleware.tsinghua.handle;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.tsinghua.entity.dto.download.HttpDownloadDTO;
import com.cictec.middleware.tsinghua.entity.dto.RabbitMqClientDTO;
import com.cictec.middleware.tsinghua.entity.dto.Terminal.MediaMessageDTO;
import com.cictec.middleware.tsinghua.entity.po.TWarnMedia;
import com.cictec.middleware.tsinghua.handle.state.MessageState;
import com.cictec.middleware.tsinghua.service.TWarnMediaService;
import com.cictec.middleware.tsinghua.utils.CamelRabbitMqDslUtils;
import com.cictec.middleware.tsinghua.utils.DateUtils;
import com.cictec.middleware.tsinghua.utils.UUIDGenerator;
import org.apache.camel.ProducerTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;



/**
 * @author 媒体信息处理，保存基本信息，推送到下载服务器下载
 */
@Component("0801")
public class MediaMessageHandle implements MessageState {


    Logger logger = LoggerFactory.getLogger(MediaMessageHandle.class);

    @Value("${media.file.save-model}")
    private String saveModel;
    @Value("${rabbitmq.download.host}")
    private String host;
    @Value("${rabbitmq.download.port}")
    private String port;
    @Value("${rabbitmq.download.exchangename}")
    private String exchangename;
    @Value("${rabbitmq.download.username}")
    private String username;
    @Value("${rabbitmq.download.password}")
    private String password;
    @Value("${rabbitmq.download.queuename}")
    private String queuename;

    @Autowired
    private TWarnMediaService tWarnMediaService;
    @Autowired
    private ProducerTemplate producerTemplate;

    private String httpDownloadDsl;

    @Override
    public void messageHandle(byte[] bytes) {
        MediaMessageDTO mediaMessage = JSONObject.parseObject(bytes,MediaMessageDTO.class);
        logger.debug("收到设备【{}】多媒体消息，消息内容：{}",mediaMessage.getHexDevIdno(),mediaMessage.toString());

        TWarnMedia warnMedia = converMediaMessageToTwarnMedia(mediaMessage);
        logger.debug("保存多媒体基本信息：{}",JSON.toJSONString(warnMedia));
        tWarnMediaService.save(warnMedia);

        HttpDownloadDTO httpDownloadDTO  = initHttpDownloadDTO(warnMedia,mediaMessage);
        logger.debug("推送多媒体下载消息到MQ：{}",JSON.toJSONString(httpDownloadDTO));
        producerTemplate.sendBody(getHttpDownloadDsl(), JSON.toJSONString(httpDownloadDTO));
    }

    public String getHttpDownloadDsl(){
        if (httpDownloadDsl == null || httpDownloadDsl.equals("")){
            httpDownloadDsl = createHttpDownlodDsl();
        }
        return httpDownloadDsl;
    }

    private TWarnMedia converMediaMessageToTwarnMedia(MediaMessageDTO messageDTO){
        TWarnMedia tWarnMedia = new TWarnMedia();
        tWarnMedia.setMediaUuid(UUIDGenerator.genUuidStr());
        tWarnMedia.setCreateTime(DateUtils.parseDate(messageDTO.getYyMMddHHmmss()));
        tWarnMedia.setHexLocaltionBuf(messageDTO.getHexDevIdno()+messageDTO.getHexLocationBuf());
        tWarnMedia.setHexMediaId(messageDTO.getHexMediaId());
        tWarnMedia.setMediaEncoding(messageDTO.getMediaEncoding());
        tWarnMedia.setMediaType(messageDTO.getMediaType());
        tWarnMedia.setDownloadStatus(TWarnMedia.DOWNLOAD_STATUS_UNDOWNLOAD);
        tWarnMedia.setSaveType(saveModel);
        return tWarnMedia;
    }

    private HttpDownloadDTO initHttpDownloadDTO(TWarnMedia tWarnMedia,MediaMessageDTO messageDTO){
        HttpDownloadDTO httpDownloadDTO = new HttpDownloadDTO();
        httpDownloadDTO.setMediaUuid(tWarnMedia.getMediaUuid());
        httpDownloadDTO.setSaveModel(saveModel);
        httpDownloadDTO.setUrl(messageDTO.getMediaUrl());
        String savePath = DateUtils.getDate()+"/"+messageDTO.getHexDevIdno()+"/"+UUIDGenerator.genUuidStr()+"."+messageDTO.getMediaEncoding();
        httpDownloadDTO.setSavePath(savePath);
        return httpDownloadDTO;
    }

    private String createHttpDownlodDsl(){

        RabbitMqClientDTO rabbitMqClientDTO = new RabbitMqClientDTO(
                host,
                port,
                exchangename,
                username,
                password,
                queuename
        );

        return CamelRabbitMqDslUtils.getCamelUrl(rabbitMqClientDTO);
    }
}
