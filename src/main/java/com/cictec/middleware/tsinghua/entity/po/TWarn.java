package com.cictec.middleware.tsinghua.entity.po;

import lombok.ToString;

import java.util.Date;
import javax.persistence.*;
@ToString
@Table(name = "t_warn")
public class TWarn {
    /**
     * 报警信息主键uuid
     */
    @Id
    @Column(name = "warn_uuid")
    private String warnUuid;

    /**
     * 设备uuid
     */
    @Column(name = "device_id")
    private String deviceId;

    @Column(name = "device_code")
    private String deviceCode;

    /**
     * 报警类型
     */
    @Column(name = "warn_type")
    private Integer warnType;

    /**
     * 报警时间
     */
    @Column(name = "warn_time")
    private Date warnTime;

    /**
     * 报警id
     */
    @Column(name = "warn_id")
    private String warnId;

    /**
     * 报警信息
     */
    @Column(name = "warn_content")
    private String warnContent;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "hex_location_buf")
    private String hexLocationBuf;

    /**
     * 获取报警信息主键uuid
     *
     * @return warn_uuid - 报警信息主键uuid
     */
    public String getWarnUuid() {
        return warnUuid;
    }

    /**
     * 设置报警信息主键uuid
     *
     * @param warnUuid 报警信息主键uuid
     */
    public void setWarnUuid(String warnUuid) {
        this.warnUuid = warnUuid;
    }

    /**
     * 获取设备uuid
     *
     * @return device_id - 设备uuid
     */
    public String getDeviceId() {
        return deviceId;
    }

    /**
     * 设置设备uuid
     *
     * @param deviceId 设备uuid
     */
    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    /**
     * @return device_code
     */
    public String getDeviceCode() {
        return deviceCode;
    }

    /**
     * @param deviceCode
     */
    public void setDeviceCode(String deviceCode) {
        this.deviceCode = deviceCode;
    }

    /**
     * 获取报警类型
     *
     * @return warn_type - 报警类型
     */
    public Integer getWarnType() {
        return warnType;
    }

    /**
     * 设置报警类型
     *
     * @param warnType 报警类型
     */
    public void setWarnType(Integer warnType) {
        this.warnType = warnType;
    }

    /**
     * 获取报警时间
     *
     * @return warn_time - 报警时间
     */
    public Date getWarnTime() {
        return warnTime;
    }

    /**
     * 设置报警时间
     *
     * @param warnTime 报警时间
     */
    public void setWarnTime(Date warnTime) {
        this.warnTime = warnTime;
    }

    /**
     * 获取报警id
     *
     * @return warn_id - 报警id
     */
    public String getWarnId() {
        return warnId;
    }

    /**
     * 设置报警id
     *
     * @param warnId 报警id
     */
    public void setWarnId(String warnId) {
        this.warnId = warnId;
    }

    /**
     * 获取报警信息
     *
     * @return warn_content - 报警信息
     */
    public String getWarnContent() {
        return warnContent;
    }

    /**
     * 设置报警信息
     *
     * @param warnContent 报警信息
     */
    public void setWarnContent(String warnContent) {
        this.warnContent = warnContent;
    }

    /**
     * @return create_time
     */
    public Date getCreateTime() {
        return createTime;
    }

    /**
     * @param createTime
     */
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    /**
     * @return hex_location_buf
     */
    public String getHexLocationBuf() {
        return hexLocationBuf;
    }

    /**
     * @param hexLocationBuf
     */
    public void setHexLocationBuf(String hexLocationBuf) {
        this.hexLocationBuf = hexLocationBuf;
    }
}