package com.cictec.middleware.tsinghua.utils;

import com.aliyun.oss.OSSClient;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.Date;

/**
 * @author qiandaxian
 * 基于Apache httpclient的http媒体文件下载方法
 */
public  class DownloadUtils {

    /**
     * download file by http url , and save the file by savePath .
     * when file download error , alibabaOSS server will response a error xml ,
     * this function will return false and savePath will become savePath.xml .
     * @param url
     * @param savePath
     * @return
     */
    public static boolean saveFileLocal(String url,String savePath){
        boolean result = true;
        //下载媒体资源
        CloseableHttpClient httpclient = HttpClients.createDefault();
        HttpGet httpGet = new HttpGet(url);
        try {
            CloseableHttpResponse response1 = httpclient.execute(httpGet);
            HttpEntity entity1 = response1.getEntity();
            if(entity1.isStreaming()){
                if(!"application/xml".equals(entity1.getContentType())) {

                //媒体信息下载返回xml，说明下载文件可能过期等情况。
                }else {

                    savePath= savePath+".xml";
                    result = false;
                }
                File file = new File(savePath);
                if (!file.exists()) {
                    file.createNewFile();
                }
                FileOutputStream out = new FileOutputStream(file);
                entity1.writeTo(out);
                out.close();
            }
            response1.close();
        } catch (IOException e) {
            result = false;
            e.printStackTrace();
        }finally {
            return result;
        }
    }


    public static String getAlibabaOSSDownloadUrl( OSSClient ossClient,String url,String bucketName,String key,Integer expir) throws IOException {
        Date expiration = new Date(System.currentTimeMillis() + (long)expir*24*60*60*1000);
        URL downloadUrl = ossClient.generatePresignedUrl(bucketName, key, expiration);
        return downloadUrl.toString();

    }


    public static void main(String[] args) {
        String a = "http://tsinghua-device-platfrom.oss-cn-hangzhou.aliyuncs.com/2018-05-03/211712230085/f9a51a424bbc4044aab1.mp4?Expires=1533115934&OSSAccessKeyId=LTAIMMZcBdG4YbJU&Signature=88BkMl1vt1eWCtDjbLDJikolyAU%3D";
        System.out.println(a.length());
    }

}
