<?php

//Load libs

class Api{
		
	public function __construct(){
		
	} 

	
	public function getFriends($uids){	
		
	}
	
		
	public function setUserLevel($uid,$level){

	}
	
	private function sign_server_server(array $request_params, $secret_key) {
		ksort($request_params);
		$params = '';
		foreach ($request_params as $key => $value) {
			$params .= "$key=$value";
		}
		return md5($params . $secret_key);
	}
		
	public function sendNotification($uids,$message){
		
		$request = []; 
		$request['app_id'] = App::config('ml_api/app_id');
		$request['method'] = 'notifications.send';
		$request['secure'] = 1;
		$request['text'] = $message;
		$request['uids'] = $uids;
		
		$request['sig'] = $this->sign_server_server($request, App::config('ml_api/secret_key'));
		
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'http://www.appsmail.ru/platform/api');
		//curl_setopt($ch, CURLOPT_HEADER, false);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 30);
		//curl_setopt($ch, CURLOPT_USERAGENT, 'PHP Bot (http://blog.yousoft.ru)');
		$response = curl_exec($ch);
		curl_close($ch);
		
		return $response;
	}	
	
	
}
