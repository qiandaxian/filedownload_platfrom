package com.cictec.middleware.download.processor;

import org.apache.camel.Exchange;
import org.apache.camel.Message;
import org.apache.camel.Processor;
import org.apache.camel.ProducerTemplate;

import java.util.Map;

/**
 * @author qiandaxian
 */
public abstract class BaseProcessor implements Processor {

	private static final ThreadLocal<Exchange> localExchange = new ThreadLocal<Exchange>();

	@Override
	public void process(Exchange exchange) throws Exception {

		setLocalExchange(exchange);

		try{
			doProcess(exchange.getIn());
		}finally{
			removeLocalExchange();
		}

	}

	public abstract void doProcess(Message message) throws Exception;

	public void sendBody(String uri,Object body){
		Exchange exchange = localExchange.get();
		ProducerTemplate template = exchange.getContext().createProducerTemplate();
		template.sendBody(uri, body );
	}

	public void sendBodyAndHeaders(String uri,Object body,Map<String,Object> headers){
		Exchange exchange = localExchange.get();
		ProducerTemplate template = exchange.getContext().createProducerTemplate();
		template.sendBodyAndHeaders(uri, body, headers);
	}

	protected Message getMessage(){
		Exchange exchange = localExchange.get();
		return exchange.getIn();
	}



	protected Map<String,Object> getHeaders(){
		return getMessage().getHeaders();
	}

	protected Object getHeaders(String key){
		return getMessage().getHeaders().get(key);
	}

	protected void setHeader(String key,Object obj){
		getMessage().setHeader(key, obj);
	}

	public void setLocalExchange(Exchange exchange) {
		localExchange.set(exchange);
	}

	public void removeLocalExchange() {
		localExchange.remove();
	}

	public String getMapBodyValue(String field){
		return (String) this.getMessage().getBody(Map.class).get(field);
	}

	public void setMapBodyValue(String key,String value){
		getMessage().getBody(Map.class).put(key, value);
	}
}
