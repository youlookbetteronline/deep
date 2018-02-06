<?php
require($_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php');
class EParser {
    
    private $payment = null;    
    private $input = null;
    
    private $types = [
        '1' => 'coins[1]',
        '2' => 'reals[1]',
        '3' => 'promo[1]',
        '4' => 'set[1]',
        '5' => 'bigsale[2][1,1]',  
        '6' => 'sets[1]',
        '7' => 'energy[1]'    
    ];
        
    public function __construct($input) {
        $this->input = $input;      
        require_once($_SERVER['DOCUMENT_ROOT'].'/app/models/EPayment.php');
        $this->payment = new EPayment($this);
    }
    
    public function init() {
        $this->trace($this->input);
        
        //параметры приложения
        $privateKey = $this->payment->config('private_key');
        $secretKey = $this->payment->config('secret_key');

        //читаем переданные параметры 
        $appId              = isset($this->input["appId"])?$this->input["appId"]:'';
        $transaction_id     = isset($this->input["transaction_id"])?$this->input["transaction_id"]:'';
        $service_id         = isset($this->input["service_id"])?(string)$this->input["service_id"]:'';
        $sig                = isset($this->input["sig"])?$this->input["sig"]:'';
        $uid                = isset($this->input["uid"])?$this->input["uid"]:'';
        $mailiki_price      = isset($this->input["mailiki_price"])?(float)$this->input["mailiki_price"]:'';
        $profit             = isset($this->input["profit"])?$this->input["profit"]:'';
        $other_price        = isset($this->input["other_price"])?$this->input["other_price"]:'';
        $debug              = isset($this->input["debug"])?$this->input["debug"]:'';
        
        if($this->sig($secretKey) != $sig)
            $this->error('Sig Error', 700);
            
        $this->payment->loadUser($uid, 'ru');
        $transaction = $this->payment->load(["transaction_id" => $transaction_id]);
        if(empty($transaction)){
                            
            $curid = substr((string) $service_id, 0, 1);
            $item = [];
            
            $type = $this->types[$curid];
            preg_match_all('/\[([^\]]+)\]/', $type, $mathes);
            $cut = implode('', $mathes[0]);
            $item[] = str_replace($cut, '', $type);
            foreach($mathes[1] as $match) {
                $_nums = explode(',', $match);
                switch(count($_nums)) {
                    case 1: $item[] = substr($service_id, $_nums[0]); break;
                    case 2: $item[] = substr($service_id, $_nums[0], $_nums[1]); break;
                    default: $this->error('Item type error', 800); break;
                }
            } 
            $this->trace($item);
            $data = array(
                'appId'             => $appId,
                'transaction_id'    => $transaction_id,
                'service_id'        => implode('_', $item),
                'uid'               => $uid,
                'mailiki_price'     => (float)$mailiki_price,
                'profit'            => $profit,
                'other_price'       => $other_price,
                'current_time'      => time(),
            );
            
            if(!$this->payment->itemExists($item))
                $this->error('Item not found.', 20);
                
            $info = $this->payment->info($item);           
            
            ////////////////// cheaters
            if($mailiki_price !== (float)$info['cost']){
                $this->trace(['amount' => $mailiki_price, 'cost' => $info['cost']]);
                $this->error('Changed Amount.', 1002); 
            }
                
            if($this->payment->complete($item, $mailiki_price)){
                $update = $this->payment->update(["transaction_id" => $transaction_id], $data, ['upsert' => true]);
                $this->trace(['payment' => 'COMPLETE', 'update' => $update]);
            } else $this->error('Databade Complete Error', 1001);
            
        }
        
        $this->response(['status' => 1]);
    }
    
    public function sig($secretKey) {
        $i = 0;
        $params = array();
        foreach($this->input as $key => $value) {
            if($key != "sig") {
                $params[$i] = "$key=$value";
                $i++;
            }
        }
        sort($params);
        $params = join('', $params);
        return md5($params . $secretKey);        
    }
    
    public function trace($object) {
        file_put_contents('./payment.log', json_encode($object). "\r\n", FILE_APPEND);
    }
    
    public function response($response) {
        $this->trace($response);
        echo json_encode($response);
        die;
    }
    
    public function error($status, $error_code = 20) {
        $this->trace(['status' => $status, 'error_code' => $error_code]);
        echo json_encode(array(
            'status' => 2,
            'error_code' => $error_code,
        ));
        die;
    }
    
    public static function create($input) {
        try{$parse = new EParser($input);} catch(Exception $err) {
            file_put_contents('./payment.log', json_encode($err). "\r\n", FILE_APPEND);    
        }
        return $parse;  
    }
}   

EParser::create($_GET)->init();
