package com.cictec.middleware.tsinghua.utils.log;

import org.apache.log4j.Logger;
import org.slf4j.helpers.FormattingTuple;
import org.slf4j.helpers.MessageFormatter;

/**
 * 日志多文件输出文件名 辅助类
 * 
 * @author Administrator
 *
 */
public class MultiLog {

	private String loggerName;
	private Logger logger;

	public void debug(String format, Object... arguments) {
		if (logger != null) {
			FormattingTuple ft = MessageFormatter.arrayFormat(format, arguments);
			logger.debug(ft.getMessage());
		}
	}

	public String getLoggerName() {
		return loggerName;
	}

	public void setLoggerName(String loggerName) {
		this.loggerName = loggerName;
	}

	public Logger getLogger() {
		return logger;
	}

	public void setLogger(Logger logger) {
		this.logger = logger;
	}

}
