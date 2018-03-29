<?php

class CraftfloorsController extends UnitController{

    public function onBeforeBuy($unit, $stock, &$result = null){
        $result['toThrow'] = $unit->data['toThrow'];
        $result['slots'] = $unit->data['slots'];
        $result['crafts'] = $unit->data['crafts'];
    }

    public function onBeforeStock($unit, $stock, &$result = null){
        $result['toThrow'] = $unit->data['toThrow'];
        $result['slots'] = $unit->data['slots'];
        $result['crafts'] = $unit->data['crafts'];
    }

    public function throwAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'type']);
        $building = $this->loadModel();

        $type = $this->query['type'];

        if (!isset($building->data['toThrow'][$type])){
            throw new ResponceException(UNDEFINED_ID, $type);
        }

        // Извлечение данных для вкидывания
        $toThrowIdx = $building->data['toThrow'][$type];
        $level = $building->data['floor'];
        $toThrow = $building->info['levels'][$level]['throw'][$type][$toThrowIdx];

        $mID = $toThrow['m'];
        $count = $toThrow['c'];
        $number = $toThrow['k'];
        $treasure = empty($toThrow['b']) ? '' : $toThrow['b'];

        $stock = Stock::instance($this->query['uID']);
        if(!$stock->get()){
            throw new ResponceException(CANT_LOAD_STOCK);
        }

        if($type == 'mdonate'){
            // Снятие кристаллов
            $material = Storage::$data[$mID];
            if(!$stock->takeAll($material['price'])){
                throw new ResponceException(NOT_ENAUGH_MATERIALS);
            }
        } elseif ($type == 'msimple' || $type == 'mhard'){
            // Снятие материала
            if(!$stock->take($mID, $count)){
                throw new ResponceException(NOT_ENAUGH_MATERIALS);
            }
        } else {
            throw new ResponceException(UNDEFINED_ID, 'type');
        }

        if(!isset($building->data['kicks'])){
            $building->data['kicks'] = 0;
        }
        $building->data['kicks'] += $number;

        // Бонус за вкидывание
        $bonus = [];
        if (!empty($treasure)){
            $bonus = Treasure::generate($treasure, $treasure);
            $stock->addFromTreasure($bonus);
        }

        Quest::register($building->sID, 1);

        // Обновление toThrow
        $building->setToThrow($type);

        $building->update();
        $stock->update();

        $result = ['bonus' => $bonus, 'kicks' => $building->data['kicks'], 'toThrow' => $building->data['toThrow']];
        return $result;
    }

    public function growAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id']);
        $building = $this->loadModel();
        $uID = $this->query['uID'];
        $floor = $building->data['floor'];

        $needKicks = $building->info['levels'][$floor]['req']['kicks'];
        if ($building->data['kicks'] < $needKicks)
            throw new ResponceException(NOT_READY, "NOT_ENAUGH_KICKS");

        // Повышение уровня
        $building->data['floor']++;
        Quest::register($building->sID, $building->data['floor']);

        // Бонус за уровень
        $bonus = [];
        if (!empty($building->info['levels'][$floor]['bonus'])){
            $treasure = $building->info['levels'][$floor]['bonus'];

            if (YBTreasure::isJapan()) {
                $treasure = YBTreasure::generate($treasure, $treasure, $building);
            } else $treasure = Treasure::generate($treasure, $treasure);

            $bonus = Treasure::merge($bonus, $treasure);
        }

        $result = [];
        $remove = false;

        // Последний уровень
        end($building->info['levels']);
        $maxLevel = key($building->info['levels']);

        if ($building->data['floor'] != $maxLevel){
            // Обновление toThrow
            $building->setToThrow('all'); 
            $result['toThrow'] = $building->data['toThrow']; 
        } 

        $result['floor'] = $building->data['floor'];

        // Добавление крафтов с полученного уровня
        if (!empty($building->info['levels'][$floor+1]['option']['craft']))
        {
            $building->data['crafts'] = array_values(array_unique(array_merge($building->data['crafts'], $building->info['levels'][$floor+1]['option']['craft'])));
            $result['crafts'] = $building->data['crafts'];
        }

        // Начисление бонусов
        if (!empty($bonus)){
            $stock = Stock::instance($uID);
            if(!$stock->get())
                throw new ResponceException(CANT_LOAD_STOCK);

            $stock->addFromTreasure($bonus);
            $stock->update();
        }

        $building->update();
        
        $result['bonus'] = $bonus;

        return $result;
    }

    public function craftingAction(){
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'fID']);
        $building = $this->loadModel();

        $fID = (int)$this->query['fID'];

        // Проверка существования крафта
        Crafting::get();
		if (!isset(Crafting::$data[$fID]))
			throw new ResponceException(UNDEFINED_CRAFTING);

        $formula = Crafting::$data[$fID];

        // Забираем материалы
        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        if (!$stock->takeAll($formula['items']))
            throw new ResponceException(NOT_ENAUGH_MATERIALS, $formula['items']);

        // Определение позиции слота с последним крафтом для вычисления старта отчета времени
        $slotsCount = count($building->data['slots']);
        $lastCrafted = -1;

        for ($i = 0; $i < $slotsCount; ++$i){
             if (!isset($building->data['slots'][$i]['crafted']))
                break;
            $lastCrafted = $i;
            //$start = $building->data['slots'][$i]['crafted'];
        }

        if ($lastCrafted == $slotsCount-1)
            throw new ResponceException(NOT_READY, 'full');

        $craftTime = $formula['time'];
        
        $start = ($lastCrafted == -1 || $building->data['slots'][$lastCrafted]['crafted'] < time()) ? time() : $building->data['slots'][$lastCrafted]['crafted'];

        // Boost crafting
        if (!empty($this->query['bSID']) && !empty($this->query['bID'])){
            $prc = $this->craftingBoost($building);
            $craftTime = (int)$craftTime * (100-$prc) / 100;
        }

        // Добавление крафта в конец очереди
        $building->data['slots'][$lastCrafted+1]['fID'] = $fID;
        $building->data['slots'][$lastCrafted+1]['crafted'] = $start + $craftTime;

        Quest::register($formula['out'], $formula['count']);
        App::$request['data']['fID'] = [$formula['out'] => $formula['count']];

        $building->update();
        $stock->update();

        return ['slots' => $building->data['slots']];
    }

    private function craftingBoost($unit){
        $sID = $unit->sID;
        $bSID = $this->query['bSID'];
        $bID = $this->query['bID'];

        if (!isset(Storage::$data[$bSID]) || Storage::$data[$bSID]['type'] != 'Booster' || !isset(Storage::$data[$bSID]['target'][$sID]))
            throw new ResponceException(ARE_YOU_HACKER, $bSID);

        $units = TUnits::load($unit->userID, $unit->worldID, $bSID);
        $_unit = $units->unit($bID, false);

        if ($_unit === null || $_unit->sid != $bSID)
            throw new ResponceException(NOT_READY, $bSID.':'.$bID);

        return (int)Storage::$data[$bSID]['target'][$sID];
    }


    public function cancelAction(){
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'slotID']);
        $building = $this->loadModel();

        $slotID = (int)$this->query['slotID']; 
        $fID = $building->data['slots'][$slotID]['fID'];

        Crafting::get();
        if (!isset(Crafting::$data[$fID]))
            throw new ResponceException(UNDEFINED_CRAFTING);
        $formula = Crafting::$data[$fID];

        if (!isset($building->data['slots'][$slotID]))
            throw new ResponceException(NOT_READY);

        //время до начала следующего крафта
        $timetocrafted = 0;
        if (isset($building->data['slots'][$slotID]['crafted']))
        {
        	$timetostart = $building->data['slots'][$slotID]['crafted'] - time() - $formula['time'];
			if ($timetostart > 0)
            	$timetocrafted = $formula['time'];
			else
				$timetocrafted = $building->data['slots'][$slotID]['crafted'] - time();
        }
        unset($building->data['slots'][$slotID]['crafted'], $building->data['slots'][$slotID]['fID']);
         // Смещение слотов
        $slotsCount = count($building->data['slots']);
        for ($i = $slotID; $i < $slotsCount; ++$i) {
            if (!isset($building->data['slots'][$i+1]) || $building->data['slots'][$i+1]['status'] == 0) {
                $building->data['slots'][$i] = [
                    'status' => $building->data['slots'][$i]['status']
                ];
                break;
            } else {
                $building->data['slots'][$i] = $building->data['slots'][$i+1];
                if (isset($building->data['slots'][$i]['crafted'] )) {
                	//var_dump($building->data['slots'][$i]['crafted']);
                    $building->data['slots'][$i]['crafted'] = $building->data['slots'][$i]['crafted'] - $timetocrafted;
                    //var_dump($timetocrafted);
                    //var_dump($building->data['slots'][$i]['crafted']);
                }
                
            }
        }

        // Возврат материалов
        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        $bonus = $formula['items'];
        $stock->addAll($bonus);

        $stock->update();
        $building->update();
        return ['bonus'=>$bonus, 'slots' => $building->data['slots']];
    }

    public function boostAction(){
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'slotID']);
        $building = $this->loadModel();

        $slotID = (int)$this->query['slotID'];
        if (!isset($building->data['slots'][$slotID]) || $building->data['slots'][$slotID]['crafted'] <= time()){
            throw new ResponceException(NOT_READY);
        }

        $fID = $building->data['slots'][$slotID]['fID'];
        $formula = Crafting::$data[$fID];
        if (!empty($formula['noboost'])){
            throw new ResponceException(NOT_READY, 'noboost');
        }

        // Вычисление стоимости ускорения
        $diff = $building->data['slots'][$slotID]['crafted'] - time();
        $count = ceil($diff / $building->info['boostops']['i']);
        $price = [$building->info['boostops']['s'] => $building->info['boostops']['c'] * $count];

        // Забираем материалы
        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        if (!$stock->takeAll($price))
            throw new ResponceException(NOT_ENAUGH_MATERIALS, $price);

        $building->data['slots'][$slotID]['crafted'] = 0;

        $slotsCount = count($building->data['slots']);
        for ($i = 0; $i < $slotsCount; ++$i){
            if ($i == $slotID || !isset($building->data['slots'][$i]['crafted']))
                continue;

            $building->data['slots'][$i]['crafted'] -= $diff;
        }

        //Quest::register($building->data['sID'], 1);

        $building->update();
        $stock->update();

        return ['slots' => $building->data['slots'], 'price' => $price];
    }


    public function storageAction(){
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'slotID']);
        $building = $this->loadModel();

        $slotID = (int)$this->query['slotID'];
        if (!isset($building->data['slots'][$slotID]) || $building->data['slots'][$slotID]['crafted'] > time()) {
            throw new ResponceException(NOT_READY, 'nothing to storage');
        }

        Crafting::get();
        $fID = $building->data['slots'][$slotID]['fID'];
        $formula = Crafting::$data[$fID];

        // Out
        $bonus = [$formula['out'] => $formula['count']];

        // Treasure
        $treasure = [];
        if (!empty($formula['treasure'])) {
            $trName = $formula['treasure'];
            $treasure = Treasure::generate($trName, $trName);
        }
        $this->mergeTB($treasure, $bonus);

        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        $stock->addFromTreasure($treasure);

        // Смещение слотов
        $slotsCount = count($building->data['slots']);
        for ($i = $slotID; $i < $slotsCount; ++$i) {
            if (!isset($building->data['slots'][$i+1]) || $building->data['slots'][$i+1]['status'] == 0) {
                $building->data['slots'][$i] = [
                    'status' => $building->data['slots'][$i]['status']
                ];
                break;
            } else {
                $building->data['slots'][$i] = $building->data['slots'][$i+1];
            }
        }
        //array_shift($building->data['slots']);

        Quest::register($building->sID, 1);
		App::$request['data']['mID'] = [$formula['out'] => $formula['count']];

        $stock->update();
        $building->update();

        return ['bonus' => $treasure, 'slots' => $building->data['slots']];
    }

    public function unlockAction(){
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'slotID']);
        $building = $this->loadModel();

        $slotID = (int)$this->query['slotID'];
        if (!isset($building->data['slots'][$slotID]) || $building->data['slots'][$slotID]['status'] == 1)
            throw new ResponceException(UNDEFINED_ID, $slotID);

        $price = $building->info['slots'][$slotID]['price'];

        // Забираем материалы
        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        if (!$stock->takeAll($price))
            throw new ResponceException(NOT_ENAUGH_MATERIALS, $price);

        $building->data['slots'][$slotID]['status'] = 1;

        $building->update();
        $stock->update();

        return ['slots' => $building->data['slots']];
    }
    
    public function refreshcraftsAction(){
        $this->requireQuery(['uID', 'wID', 'sID', 'id']);
        $building = $this->loadModel();

        $floor = $building->data['floor'];
        if (!empty($building->info['levels'][$floor]['option']['craft'])) {
            $building->data['crafts'] = array_values(array_unique(array_merge($building->data['crafts'], $building->info['levels'][$floor]['option']['craft'])));
            //$result['crafts'] = $building->data['crafts'];
        }

        $building->update();

        return ['crafts' => $building->data['crafts']];
    }
}
