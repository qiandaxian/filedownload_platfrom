package com.cictec.middleware.tsinghua.handle.state;

import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import lombok.Data;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;


/**
 * @author qiandaxian
 * messageState上下文，用于自动调用该类型的handle
 */
@Component
public class MessageStateContext implements ApplicationContextAware {
    Logger logger = LoggerFactory.getLogger(MessageStateContext.class);

    private ApplicationContext context;
    private MessageState messageState;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context = applicationContext;
    }
    public void messageHandle(TsinghuaDeviceMessageDTO messageDTO,byte[] bytes) {
        this.setMessageState(messageDTO);
        messageState.messageHandle(bytes);


    }

    public void setMessageState(TsinghuaDeviceMessageDTO messageDTO){
        try {
            this.messageState = (MessageState)context.getBean(messageDTO.getHexMsgId());
        }catch (Exception e){
            logger.error("未发现【{}】类型消息的逻辑处理模块。",messageDTO.getHexMsgId());
        }
    }



}
