package com.cictec.middleware.tsinghua.handle;

import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.tsinghua.dao.elasticsearch.PositionInfoReponsitory;
import com.cictec.middleware.tsinghua.entity.dto.Terminal.PositionMessageDTO;
import com.cictec.middleware.tsinghua.entity.po.TWarn;
import com.cictec.middleware.tsinghua.entity.po.elasticsearch.PositionInfo;
import com.cictec.middleware.tsinghua.handle.state.MessageState;
import com.cictec.middleware.tsinghua.biz.VirtualSessionManage;
import com.cictec.middleware.tsinghua.service.TWarnService;
import com.cictec.middleware.tsinghua.utils.DateUtils;
import com.cictec.middleware.tsinghua.utils.DaxianStringUtils;
import com.cictec.middleware.tsinghua.utils.UUIDGenerator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.text.MessageFormat;
import java.util.Date;


/**
 * @author qiandaxian
 * 位置信息处理
 */
@Component("0200")
public class PositionMessageHandle implements MessageState {
    Logger logger = LoggerFactory.getLogger(PositionMessageHandle.class);

    @Autowired
    private VirtualSessionManage sessionManage;
    @Autowired
    private PositionInfoReponsitory positionInfoReponsitory;
    @Autowired
    private TWarnService tWarnService;
    @Override
    public void messageHandle(byte[] bytes) {
        PositionMessageDTO positionMessage = JSONObject.parseObject(bytes,PositionMessageDTO.class);
        logger.info("收到位置信息消息，消息内容：{}",positionMessage.toString());
        sessionManage.updatePosition(positionMessage);

        PositionInfo positionInfo = converPositionMessageToPositionInfo(positionMessage);
        logger.debug("保存位置信息到ES:{}",positionInfo.toString());
        positionInfoReponsitory.save(positionInfo);

        if(positionMessage.getAlarmSet().length>0) {
            TWarn warn = getWarnFromPosition(positionMessage);
            logger.debug("保存报警信息到数据库:{}",warn.toString());
            tWarnService.save(warn);
        }
    }

    /**
     * 获取报警信息对象
     * @param message
     * @return
     */
    private TWarn getWarnFromPosition(PositionMessageDTO message){
        TWarn warn = new TWarn();
        warn.setDeviceCode(message.getHexDevIdno());
        warn.setCreateTime(new Date(System.currentTimeMillis()));
        warn.setHexLocationBuf(message.getHexDevIdno()+message.getHexLocationBuf());
        warn.setWarnTime(DateUtils.parseDate(message.getYyMMddHHmmss()));
        warn.setWarnUuid(UUIDGenerator.genUuidStr());
        String content =  MessageFormat.format("报警类型：{},状态标识：{}",message.getAlarmSet()[0],DaxianStringUtils.join(message.getStatusSet()));
        warn.setWarnContent(content);
        //类型后期待定
        //warn.setWarnType();
        return warn;
    }

    /**
     * 将DTO转换为ES存储对象
     * @param message
     * @return
     */
    private PositionInfo converPositionMessageToPositionInfo(PositionMessageDTO message){
        PositionInfo positionInfo = new PositionInfo();
        positionInfo.setUuid(UUIDGenerator.genUuidStr());
        positionInfo.setLat(message.getHexDevIdno());
        positionInfo.setLng(message.getLng());
        positionInfo.setAlarmSetStr(StringUtils.arrayToDelimitedString(message.getAlarmSet(),","));
        positionInfo.setAltitude(message.getAltitude().toString());
        positionInfo.setAngle(message.getAngle().toString());
        positionInfo.setCreateTime(message.getYyMMddHHmmss());
        positionInfo.setMile(message.getMile().toString());
        positionInfo.setDeviceCode(message.getHexDevIdno());
        positionInfo.setSpeed(message.getSpeed().toString());
        positionInfo.setStatusSetStr(StringUtils.arrayToDelimitedString(message.getStatusSet(),","));
        //hexLocationBuf在不同设备间，会出现重复的情况，为了当做唯一编码使用，所有加上设备号
        positionInfo.setHexLocationBuf(message.getHexDevIdno()+message.getHexLocationBuf());
        return positionInfo;
    }
}
