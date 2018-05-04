package com.cictec.middleware.tsinghua.handle;

import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.tsinghua.entity.dto.Terminal.PhotographReponseMessageDTO;
import com.cictec.middleware.tsinghua.entity.dto.Terminal.PositionMessageDTO;
import com.cictec.middleware.tsinghua.handle.state.MessageState;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component("0805")
public class PhotographMessageHandle implements MessageState {
    Logger logger = LoggerFactory.getLogger(PhotographMessageHandle.class);
    @Override
    public void messageHandle(byte[] bytes) {
        PhotographReponseMessageDTO photographReponseMessage = JSONObject.parseObject(bytes,PhotographReponseMessageDTO.class);
        logger.info("收到设备【{}】抓拍应答消息，消息内容：{}",photographReponseMessage.getHexDevIdno(),photographReponseMessage.toString());
    }
}
