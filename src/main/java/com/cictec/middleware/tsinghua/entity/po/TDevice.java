package com.cictec.middleware.tsinghua.entity.po;

import lombok.Data;
import lombok.ToString;

import java.util.Date;
import javax.persistence.*;

@Table(name = "t_device")
@Data
@ToString
public class TDevice {
    @Id
    @Column(name = "dev_uuid")
    private String devUuid;

    @Column(name = "dev_code")
    private String devCode;

    @Column(name = "dev_model_num")
    private String devModelNum;

    @Column(name = "dev_version")
    private String devVersion;

    @Column(name = "dev_plate_number")
    private String devPlateNumber;

    @Column(name = "dev_sim_num")
    private String devSimNum;

    /**
     * 设备在线状态
        0：断开
        1：在线
     */
    @Column(name = "dev_online_status")
    private String devOnlineStatus;

    /**
     * 设备状态
        1：正常
        0：维修
     */
    @Column(name = "dev_status")
    private String devStatus;

    /**
     * 1 启用 0 禁用 
     */
    @Column(name = "dev_isvalid")
    private String devIsvalid;

    @Column(name = "dev_phone")
    private String devPhone;

    @Column(name = "dev_ref_id")
    private String devRefId;

    @Column(name = "dev_status_change_time")
    private Date devStatusChangeTime;

    @Column(name = "dev_create_user")
    private String devCreateUser;

    @Column(name = "dev_create_time")
    private Date devCreateTime;

    @Column(name = "dev_update_user")
    private String devUpdateUser;

    @Column(name = "dev_update_time")
    private Date devUpdateTime;

    /**
     * 删除标示 0：未删除 1 删除
     */
    @Column(name = "dev_drop_flag")
    private String devDropFlag;

    @Column(name = "dev_remark")
    private String devRemark;

    /**
     * 设备编号序列
     */
    @Column(name = "dev_code_seq")
    private Short devCodeSeq;

    /**
     * 来自同步库 1 来自别的库 0 正常录入数据
     */
    @Column(name = "dev_flag")
    private Short devFlag;

    /**
     * 鉴权码
     */
    @Column(name = "dev_key")
    private String devKey;

    /**
     * 当前升级包版本号
     */
    @Column(name = "master_version")
    private String masterVersion;

    /**
     * 城市id
     */
    private String cityid;

    /**
     * 中间件tcpIp
     */
    private String ip;

    /**
     * 中间件端口号
     */
    private String port;

    /**
     * 设备配置编码
     */
    private String protocol;

    /**
     * 是否启用485协议 1启用 2关闭 默认1
     */
    @Column(name = "operational_type")
    private String operationalType;

   }