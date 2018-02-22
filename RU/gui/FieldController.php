<?php

class FieldController extends UnitController{
    

    public function plantAction(){
        
        if(empty($this->query['pID'])){
            throw new ResponceException(UNDEFINED_PLANT_SID);
        }
        
        Storage::get();
        
        if(!isset(Storage::$data[$this->query['pID']])){	
            throw new ResponceException(UNDEFINED_PLANT_SID);
        }
        $plantObject = Storage::$data[$this->query['pID']];
        
        if(empty($this->query['id'])){
            
            $this->check(array('hasUID','hasWID', 'hasSID', 'hasCDT'));
            
            $field = $this->loadModel(false);
        
            $field->id = $field->nextID();
            $field->create();
            $field->data['x'] = $this->query['x'];
            $field->data['z'] = $this->query['z'];
        }else{
            
            $this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));
            $field = $this->loadModel();
            //parent::checkStorage($field);
        }
        //$field->get();
        
        if(!empty($field->data['pID'])){
            throw new ResponceException(FIELD_BUSY, $field->data);
        }
        
        $stock = Stock::instance($this->query['uID']);
        if(!$stock->get()){
            throw new ResponceException(CANT_LOAD_STOCK);
        }
        
        $price = $plantObject['price'];
        if(!isset($price[Stock::FANTASY]))
            $price[Stock::FANTASY] = 0;
        $price[Stock::FANTASY]++;

        if(!$stock->takeAll($price)){
            throw new ResponceException(NOT_ENAUGH_ITEMS);    
        }
        
        //Садим растение
        $field->data['pID'] = $this->query['pID'];
        $field->data['planted'] = time();
        
        $result = array(
            'id' => $field->id, 
            'pID' => $field->data['pID'], 
            'planted' => $field->data['planted'], 
            Stock::FANTASY => $stock->data[Stock::FANTASY]
        );
        
        //parent::completeCount($field, $result);

        if(empty($this->query['id'])){
            $field->insert();
        } else $field->update();
        
        Quest::register($field->data['pID'], 1);
        $stock->update();
        
        return $result;
    }
    
    public function harvestAction(){
        
        $this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));
        
        $field = $this->loadModel();
        //parent::checkStorage($field);
        
        if(empty($field->data['pID'])){
            throw new ResponceException(UNDEFINED_PLANT_SID, $field->data);
        } else App::$request['data']['fID'] = $field->data['pID'];
            
        Storage::get();
        
        if(!isset(Storage::$data[$field->data['pID']])){
            throw new ResponceException(UNDEFINED_PLANT_SID, $field->data);
        }
        
        $plant = Storage::$data[$field->data['pID']];
        
        $growthTime = $plant['levels']*$plant['levelTime'];
        
        //Если растение созрело
        if($field->data['planted']+$growthTime < time()){
			$stock = Stock::instance($this->query['uID']);
            if(!$stock->get())
                throw new ResponceException(CANT_LOAD_STOCK);

			// Если для сбора требуются материалы
			if (!empty($plant['require'])){
				if (!$stock->takeAll($plant['require']))
					throw new ResponceException(NOT_ENAUGH_ITEMS);
			}

            unset($field->data['pID']);
            unset($field->data['planted']);

            $treasure = array();
            foreach($plant['outs'] as $_sid=>$_cnt){
				$treasure[$_sid] = array(1=>$_cnt);
				if(Storage::$data[$_sid]['type'] == 'Material' && (Storage::$data[$_sid]['mtype'] == 0 || Storage::$data[$_sid]['mtype'] == 6)){
					Quest::register($_sid, $_cnt);
				}
			}
            
            if(!empty($plant['experience'])){
                $treasure[Stock::EXP] = array($plant['experience'] => 1);
            }

            if(!empty($plant['treasure'])){
                $treas = $plant['treasure'];
                if(YBTreasure::isJapan()) {
                    $treasBonus = YBTreasure::generate($treas, $treas, $field);
                } 
                else
                {
                    $treasBonus = Treasure::generate($treas, $treas);

                }
                $treasure = Treasure::merge($treasure, $treasBonus);
            }
            $stock->addFromTreasure($treasure);
            
            $result = array('bonus' => $treasure);
            
            //parent::completeStorage($field, $result);
            
            $stock->update();
            $field->update();
            
            return $result;
            
        } else throw new ResponceException(PLANT_YOUNG_YET, $field->data);
    }
    /*
    public function helpharvestAction(){
        
        $this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));
        
        if(empty($this->query['helper'])){
            throw new ResponceException(UNDEFINED_GUEST);
        }
        $guest = $this->query['helper'];
        
        $friends = new Friends($this->query['uID']);
        $friends->get();
        if(empty($friends->data[$guest])){
            throw new ResponceException(CANT_FIND_FRIEND);
        }
        
        if(empty($friends->data[$guest]['helped']) || $friends->data[$guest]['helped'] <= 0){
            return array("bonus"=>null);
            //throw new ResponceException(CANT_HELPED);
        }
        
        $friends->data[$guest]['helped']--;
        $friends->changed[$guest] = $guest;
        //$friends->changeOne($guest, 'helped', -1);
        
        $field = $this->loadModel();
        
        if(empty($field->data['pID'])){
            throw new ResponceException(UNDEFINED_PLANT_SID, $field->data);
        }
            
        Storage::get();
        
        if(!isset(Storage::$data[$field->data['pID']])){
            throw new ResponceException(UNDEFINED_PLANT_SID, $field->data);
        }
        
        $plant = Storage::$data[$field->data['pID']];
        
        $growthTime = $plant['levels']*$plant['levelTime'];
        
        //Если растение созрело
        if($field->data['planted']+$growthTime < time()){
            
            unset($field->data['pID']);
            unset($field->data['planted']);
            
            $stock = Stock::instance($this->query['uID']);
            if(!$stock->get()){
                throw new ResponceException(CANT_LOAD_STOCK);
            }
            
            $treasure = Treasure::generate('Field','harvest');
            $treasure[$plant['out']] = array(1=>1);
            $stock->addFromTreasure($treasure);
            
            $stock->update();
            $field->update();
            $friends->update();
            
            return array('bonus'=>$treasure, 'out'=>$plant['out']);
        }else{
            throw new ResponceException(PLANT_YOUNG_YET, $field->data);
        }
        
    }
    
    public function guestharvestAction(){
        
        $this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));
        
        if(empty($this->query['guest'])){
            throw new ResponceException(UNDEFINED_GUEST);
        }
        
        $guest = $this->query['guest'];
        
        $field = $this->loadModel();
        //$field->get();
        
        if(empty($field->data['pID'])){
            throw new ResponceException(UNDEFINED_PLANT_SID, $field->data);
        }
        
        Storage::get();
        
        if(!isset(Storage::$data[$field->data['pID']])){
            throw new ResponceException(UNDEFINED_PLANT_SID, $field->data);
        }
        
        $plant = Storage::$data[$field->data['pID']];
        
        $growthTime = $plant['levels']*$plant['levelTime'];
        
        //Если растение созрело
        if($field->data['planted']+$growthTime < time()){
            
            $friends = new Friends($guest);
            $friends->get();
            if(empty($friends->data[$this->query['uID']])){
                throw new ResponceException(CANT_FIND_FRIEND);
            }
            
            //if(!$friends->checkLimitEnergy()){
                //throw new ResponceException(LIMIT_GUEST_ENERGY);
            //}
            
            $stock = Stock::instance($guest);
            if(!$stock->get()){
                throw new ResponceException(CANT_LOAD_STOCK);
            }
            
            // отнимаем гостевую энергию
            if(false === $guestEnergy = $friends->takeGuestEnergy($this->query['uID'], $stock)){
                //return array("bonus"=>false, "capacity"=>$resource->data['capacity'], "energy"=>0);
                //return array("bonus"=>$false, 'out'=>$plant['out'], 'energy'=>0);
                throw new ResponceException(CANT_TAKE_ENERGY);
            }    
            
            
            $treasure = Treasure::generate('Field','harvest');
            $treasure[$plant['out']] = array(1=>1);
            
            Quest::register($plant['out'], 1);
            
            $stock->addFromTreasure($treasure);
            
            $stock->update();
            $friends->update();
            
            return array('bonus'=>$treasure, 'out'=>$plant['out'], 'energy'=>isset($guestEnergy)?$guestEnergy:0);
        }else{
            throw new ResponceException(PLANT_YOUNG_YET, $field->data);
        }
        
    }
    */
    
    public function boostAction(){
        $this->check(array('hasUID','hasWID', 'hasSID'));
        
        if(empty($this->query['IDs'])){
            throw new ResponceException(UNDEFINED_ID);
        }
        
        try{
            $IDs = $this->query['IDs'];
            $IDs = json_decode($IDs, true);
        }catch(Exception $e){
            throw new ResponceException(UNDEFINED_ID);
        }

        if(empty($this->query['bID'])){
            throw new ResponceException(UNDEFINED_SID);
        }
        
        $bID = (int) $this->query['bID'];
        
        Storage::get();
        
        $percent = 0;
        foreach(Storage::$data as $sID => & $item){
            if($item['type'] == 'Boost' && $item['out'] == $bID){
                $percent = $item['percent'];
            }
        }
        
        if($percent == 0){
            throw new ResponceException(WRONG_COUNT);
        }
        
        $stock = Stock::instance($this->query['uID']);
        if(!$stock->get()){
            throw new ResponceException(CANT_LOAD_STOCK);
        }
        
        if($stock->take($bID,count($IDs))){
            
            $result = array();
            
            foreach($IDs as $ID){
                
                $this->query['id'] = $ID;
                
                $field = $this->loadModel();
        
                if(empty($field->data['planted'])){
                    throw new ResponceException(CANT_FIND);
                }
                
                $plant = Storage::$data[$field->data['pID']];
                $growthTime = $plant['levels']*$plant['levelTime'];
        
                $planted = & $field->data['planted'];
                $planted -= $growthTime*($percent/100);

                $result[$ID] = $planted;
                
                $field->update();
            }
            
            Quest::register($this->query['sID'], count($IDs));
            Quest::register($bID, count($IDs));
            
            $stock->update();
            
            return $result;
            
        }else{
            throw new ResponceException(NOT_ENAUGH_ITEMS);
        }
        
        
    }
    
    
    
    
    /*
    public function digAction(){
        
        $this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));
        
        $field = $this->loadModel();
        //$field->get();
        
        if($field->data['status']!=Field::UNDIG){
            throw new ResponceException(FIELD_DIG, $field->data);
        }
        
        $field->data['status'] = Field::DIG;
        $field->update();
        
        return array('status'=>$field->data['status']);
    }
    */
}
