package com.cictec.middleware.tsinghua.entity.po;

import java.util.Date;
import javax.persistence.*;

@Table(name = "t_warn_media")
public class TWarnMedia {
    public static final int DOWNLOAD_STATUS_SUCCESS = 1;
    public static final int DOWNLOAD_STATUS_ERROR = 2;
    public static final int DOWNLOAD_STATUS_UNDOWNLOAD = 0;

    /**
     * 报警图片表主键uuid
     */
    @Id
    @Column(name = "media_uuid")
    private String mediaUuid;

    /**
     * 报警图片序号
     */
    @Column(name = "media_type")
    private Integer mediaType;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "download_url")
    private String downloadUrl;

    @Column(name = "download_time")
    private Date downloadTime;

    /**
     * 0.未下载1.下载成功2.下载失败
     */
    @Column(name = "download_status")
    private Integer downloadStatus;

    @Column(name = "media_encoding")
    private String mediaEncoding;

    @Column(name = "hex_media_id")
    private String hexMediaId;

    @Column(name = "hex_localtion_buf")
    private String hexLocaltionBuf;

    @Column(name = "save_type")
    private String saveType;

    /**
     * 获取报警图片表主键uuid
     *
     * @return media_uuid - 报警图片表主键uuid
     */
    public String getMediaUuid() {
        return mediaUuid;
    }

    /**
     * 设置报警图片表主键uuid
     *
     * @param mediaUuid 报警图片表主键uuid
     */
    public void setMediaUuid(String mediaUuid) {
        this.mediaUuid = mediaUuid;
    }

    /**
     * 获取报警图片序号
     *
     * @return media_type - 报警图片序号
     */
    public Integer getMediaType() {
        return mediaType;
    }

    /**
     * 设置报警图片序号
     *
     * @param mediaType 报警图片序号
     */
    public void setMediaType(Integer mediaType) {
        this.mediaType = mediaType;
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
     * @return download_url
     */
    public String getDownloadUrl() {
        return downloadUrl;
    }

    /**
     * @param downloadUrl
     */
    public void setDownloadUrl(String downloadUrl) {
        this.downloadUrl = downloadUrl;
    }

    /**
     * @return download_time
     */
    public Date getDownloadTime() {
        return downloadTime;
    }

    /**
     * @param downloadTime
     */
    public void setDownloadTime(Date downloadTime) {
        this.downloadTime = downloadTime;
    }

    /**
     * 获取0.未下载1.下载成功2.下载失败
     *
     * @return download_status - 0.未下载1.下载成功2.下载失败
     */
    public Integer getDownloadStatus() {
        return downloadStatus;
    }

    /**
     * 设置0.未下载1.下载成功2.下载失败
     *
     * @param downloadStatus 0.未下载1.下载成功2.下载失败
     */
    public void setDownloadStatus(Integer downloadStatus) {
        this.downloadStatus = downloadStatus;
    }

    /**
     * @return media_encoding
     */
    public String getMediaEncoding() {
        return mediaEncoding;
    }

    /**
     * @param mediaEncoding
     */
    public void setMediaEncoding(String mediaEncoding) {
        this.mediaEncoding = mediaEncoding;
    }

    /**
     * @return hex_media_id
     */
    public String getHexMediaId() {
        return hexMediaId;
    }

    /**
     * @param hexMediaId
     */
    public void setHexMediaId(String hexMediaId) {
        this.hexMediaId = hexMediaId;
    }

    /**
     * @return hex_localtion_buf
     */
    public String getHexLocaltionBuf() {
        return hexLocaltionBuf;
    }

    /**
     * @param hexLocaltionBuf
     */
    public void setHexLocaltionBuf(String hexLocaltionBuf) {
        this.hexLocaltionBuf = hexLocaltionBuf;
    }

    /**
     * @return save_type
     */
    public String getSaveType() {
        return saveType;
    }

    /**
     * @param saveType
     */
    public void setSaveType(String saveType) {
        this.saveType = saveType;
    }
}