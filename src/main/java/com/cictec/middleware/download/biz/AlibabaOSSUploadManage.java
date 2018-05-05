package com.cictec.middleware.download.biz;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.concurrent.*;

import com.aliyun.oss.OSSClient;
import com.aliyun.oss.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;


/**
 * @author qiandaxian
 * 阿里云OSS多线程上传
 */
@Component
public class AlibabaOSSUploadManage {

    @Value("${media.alibaba.endpoint}")
    private String endpoint = "oss-cn-hangzhou.aliyuncs.com";
    @Value("${media.alibaba.access-id}")
    private String accessKeyId = "LTAIMMZcBdG4YbJU";
    @Value("${media.alibaba.access-key}")
    private String accessKeySecret = "zyDWSfOLHAzpbIzw5i1GZmB4p0POlr";
    @Value("${media.alibaba.bucket-name}")
    private String bucketName = "tsinghua-device-platfrom";

    private static OSSClient client = null;
    private static ExecutorService executorService = null;
    //采用阻塞的数组队列，去控制mq的消费速度，当队列满时，不在消费mq中得消息，方便后期拓展。
    private BlockingQueue<Future<String>> blockingQueue = new ArrayBlockingQueue<Future<String>>(5);

    Logger logger = LoggerFactory.getLogger(AlibabaOSSUploadManage.class);

    /**
     * 单例的OSSclient
     * @return
     */
    public OSSClient getClient(){
        if(client == null){
            client = new OSSClient(endpoint, accessKeyId, accessKeySecret);
        }
        return client;
    }

    public ExecutorService getExecutorService(){
        if (executorService == null){
            executorService = new ScheduledThreadPoolExecutor(5);
        }
        return executorService;
    }

    public void downloadFile(String url,String key,String mediaUUid){
        Future<String> future =  getExecutorService().submit(new UploaderThread(url,key,mediaUUid));
//        try {
//            String s  = future.get();
//            logger.error("线程执行完毕，返回：{}",s);

//        } catch (InterruptedException e) {
//            e.printStackTrace();
//        } catch (ExecutionException e) {
//            e.printStackTrace();
//        }
    }


    private class UploaderThread  implements Callable<String> {


        private String url;
        private String key;
        private String mediaUuid;

        public UploaderThread(String url, String key ,String mediaUuid) {
            this.url = url;
            this.key = key;
            this.mediaUuid = mediaUuid;
        }

//        @Override
//        public void run() {
//            InputStream instream = null;
//            try {
//
//                logger.info("开始执行上传任务:"+key);
//
//                InputStream inputStream = new URL(url).openStream();
//
//
//                PutObjectResult result = getClient().putObject(bucketName, key, inputStream);
//
//                logger.info(key+"上传完毕！");
//
//                logger.info(result.toString());
//
//            } catch (Exception e) {
//                e.printStackTrace();
//            } finally {
//                if (instream != null) {
//                    try {
//                        instream.close();
//                    } catch (IOException e) {
//                        e.printStackTrace();
//                    }
//                }
//            }
//        }

        @Override
        public String call() throws Exception {
            InputStream instream = null;
            try {

                logger.info("开始执行上传任务:"+key);

                InputStream inputStream = new URL(url).openStream();


                PutObjectResult result = getClient().putObject(bucketName, key, inputStream);

                logger.info(key+"上传完毕！");

                logger.info(result.toString());


            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (instream != null) {
                    try {
                        instream.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

            return key+"上传完毕！uuid:"+mediaUuid;
        }
    }
}