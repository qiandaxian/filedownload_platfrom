package com.cictec.middleware.tsinghua.utils.log;


import org.apache.log4j.PropertyConfigurator;

import java.io.File;

/**
 * log4j日志文件代码加载方式
 * @author ql
 *
 */
public class Log4jConfig {
	private static boolean isReload = true;

	/**
	 * 装载log4j配置文件，默认加载跟路径下的配置文件
	 *
	 * @author zhaigx
	 * @DATE 2011-5-28
	 */
	public static void load() {



		String rootPath = Thread.currentThread().getContextClassLoader().getResource("").getPath();
		String filePath = rootPath + File.separator + "log4j.properties";
		// 指定log4j文件位置加载
		PropertyConfigurator.configure(filePath);

	}

	/**
	 * 加载指定的log4j配置文件
	 * @param path 指定log4j文件位置
	 */
	public static void load(String path){
		// 指定log4j文件位置加载
		PropertyConfigurator.configure(path);
	}


	private static void reload() {
		if (isReload) {
			load();
		}
		isReload = false;
	}

	public void setReload(boolean flag) {
		isReload = flag;
	}

}
