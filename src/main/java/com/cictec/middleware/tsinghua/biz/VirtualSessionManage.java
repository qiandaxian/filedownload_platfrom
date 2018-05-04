package com.cictec.middleware.tsinghua.biz;

import com.cictec.middleware.tsinghua.entity.dto.Terminal.PositionMessageDTO;
import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * 虚拟session的状态管理模块
 * @author qiandaxian
 */
@Component
@EnableScheduling
public class VirtualSessionManage {
    private ConcurrentMap<String,VirtualSession> sessions = new ConcurrentHashMap();

    @Value("${virtualsession.efficacy.time}")
    private Integer efficacyTime;

    Logger logger = LoggerFactory.getLogger(VirtualSessionManage.class);

    /**
     * 新建session
     * @param message
     */
    public VirtualSession createSession(TsinghuaDeviceMessageDTO message){
        VirtualSession virtualSession = new VirtualSession();
        virtualSession.setCreateTime(new Date(System.currentTimeMillis()));
        virtualSession.setDevCode(message.getHexDevIdno());
        virtualSession.setLastReceiveMessageTime(new Date(System.currentTimeMillis()));
        sessions.put(message.getHexDevIdno(),virtualSession);
        logger.info("设备【{}】新建连接。",message.getHexDevIdno());
        return virtualSession;
    }

    /**
     * 关闭session
     * @param devCode
     * @return
     */
    public void closeSession(String devCode){
        if(sessions.get(devCode)!=null) {
            sessions.remove(devCode);
            logger.info("设备【{}】连接超时，断开连接。", devCode);
        }
    }

    /**
     * 更新位置信息
     * @param positionMessageDTO
     */
    public void updatePosition(PositionMessageDTO positionMessageDTO){
        VirtualSession session = sessions.get(positionMessageDTO.getHexDevIdno());
        if(session==null){
            session = createSession(positionMessageDTO);
        }
        session.setLastPosition(positionMessageDTO);
        session.setLastReceiveMessageTime(new Date(System.currentTimeMillis()));
        logger.debug("设备【{}】更新位置点信息",session.getDevCode());
    }


    /**
     * 获取所有在线session
     * @return
     */
    public List<VirtualSession> getAllOnlineSession(){
        List<VirtualSession> onlineSession  = new ArrayList();
        sessions.forEach((k,v)-> onlineSession.add(v));
        return onlineSession;
    }

    /**
     * 定时任务，每分钟触发一次，移除超时的session。
     */
    @Scheduled(cron = "0 0/1 * * * ?")
    protected void lostEfficacyByTime(){
        getAllOnlineSession().forEach(session -> {
            if(sessionTimeoutCheck(session)){
                closeSession(session.getDevCode());
            }
        });
    }

    /**
     * session超时判断，超时返回true，未超时返回false
     * @param session
     * @return
     */
    private boolean sessionTimeoutCheck(VirtualSession session){
        boolean result = false;
        if(System.currentTimeMillis()-session.getLastReceiveMessageTime().getTime()>efficacyTime){
            result =  true;
        }
        return result;
    }

}
