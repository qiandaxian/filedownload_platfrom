package com.cictec.middleware.download.biz;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import com.aliyun.oss.ClientException;
import com.aliyun.oss.OSSClient;
import com.aliyun.oss.OSSException;
import com.aliyun.oss.model.*;


/**
 * @author qiandaxian
 * 阿里云OSS多线程上传
 */
public class UploadManage {

    private static String endpoint = "oss-cn-hangzhou.aliyuncs.com";
    private static String accessKeyId = "LTAIMMZcBdG4YbJU";
    private static String accessKeySecret = "zyDWSfOLHAzpbIzw5i1GZmB4p0POlr";
    private static String bucketName = "download-device-platfrom";

    private static OSSClient client = null;
    private static ExecutorService executorService = Executors.newFixedThreadPool(5);

    /**
     * 单例的OSSclient
     * @return
     */
    public static OSSClient getClient(){
        if(client == null){
            client = new OSSClient(endpoint, accessKeyId, accessKeySecret);
        }
        return client;
    }

    public static void main(String[] args) throws IOException {

        //模拟多文件同时上传
        try {

            String[] urls = {
                    "http://117.34.118.23:9004/upload/2018/01/05/20180105014850265.mp4",
                    "http://117.34.118.23:9004/upload/2018/01/05/20180105014818434.mp4",
                    "http://117.34.118.23:9003/mediaplayer/upload/default/2018/01/05/20180105020441693.jpg",
                    "http://117.34.118.23:9003/mediaplayer/upload/default/2018/01/05/20180105020432442.jpg",
                    "http://117.34.118.23:9004/upload/2018/01/05/20180105015033277.jpg",
                    "http://117.34.118.23:9004/upload/2018/01/03/20180103032228273.png"

            };

            String[] keys = {
                    "20180105014850265.mp4",
                    "20180105014818434.mp4",
                    "20180105020441693.jpg",
                    "20180105020432442.jpg",
                    "20180105015033277.jpg",
                    "20180103032228273.png"
            };

            for (int i = 0; i < 100; i++) {
                for (int j = 0; j < 6; j++) {
                    String url = urls[j];
                    String key = "test/"+i+"/"+keys[j];
                    executorService.execute(new UploaderThread(url,key));
                    System.out.println("第"+(i+1)*(j+1)+"个线程加入线程池");
                }
            }

            executorService.shutdown();

            while (!executorService.isTerminated()) {
                try {
                    executorService.awaitTermination(5, TimeUnit.SECONDS);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }


        } catch (OSSException oe) {
            System.out.println("Caught an OSSException, which means your request made it to OSS, "
                    + "but was rejected with an error response for some reason.");
            System.out.println("Error Message: " + oe.getErrorCode());
            System.out.println("Error Code:       " + oe.getErrorCode());
            System.out.println("Request ID:      " + oe.getRequestId());
            System.out.println("Host ID:           " + oe.getHostId());
        } catch (ClientException ce) {
            System.out.println("Caught an ClientException, which means the client encountered "
                    + "a serious internal problem while trying to communicate with OSS, "
                    + "such as not being able to access the network.");
            System.out.println("Error Message: " + ce.getMessage());
        } finally {
            /*
             * Do not forget to shut down the client finally to release all allocated resources.
             */
            if (client != null) {
                client.shutdown();
            }
        }
    }

    private static class UploaderThread  implements Runnable {

        private String url;
        private String key;

        public UploaderThread(String url, String key) {
            this.url = url;
            this.key = key;
        }

        @Override
        public void run() {
            InputStream instream = null;
            try {

                System.out.println("开始执行上传任务:"+key);

                InputStream inputStream = new URL(url).openStream();


                PutObjectResult result = getClient().putObject(bucketName, key, inputStream);

                System.out.println(key+"上传完毕！");

                System.out.println(result.toString());

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
        }
    }
}