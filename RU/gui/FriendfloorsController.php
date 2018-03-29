<?php

class FriendfloorsController extends UnitController{

    public function onBeforeBuy($unit, $stock, &$result = null){
        $result['toThrow'] = $unit->data['toThrow'];
    }

    public function onBeforeStock($unit, $stock, &$result = null){
        $result['toThrow'] = $unit->data['toThrow'];
    }

    public function mkickAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'type'/*, 'mID'*/]);
        $building = $this->loadModel();

        if (isset($building->data['died']))
            throw new ResponceException(NOT_READY, 'died');

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
        } elseif ($type == 'msimple'){
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

    public function fkickAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'fID']);
        $building = $this->loadModel();

        if (isset($building->data['died']))
            throw new ResponceException(NOT_READY, 'died');

        $uID = $this->query['uID'];
        $fID = $this->query['fID'];

        $friends = new Friends($uID);
        $friends->get();

        $ctime = time();
        // "Друг" - не друг
        if (!isset($friends->data[$fID])) {
            throw new ResponceException(CANT_FIND_FRIEND);
        }

        // Друг уже записан
        if (isset($building->data['friends'][$fID])){
            throw new ResponceException(KICKED_YET, $fID);
        }

        $building->data['friends'][$fID] = $ctime;

        Quest::register($building->sID, 1);

        $building->update();

        return ['friends' => $building->data['friends']];
    }

    public function fakefkickAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'ffID']);
        $building = $this->loadModel();
        if (isset($building->data['died']))
            throw new ResponceException(NOT_READY, 'died');
        $ffID = $this->query['ffID'];
        $fakefriend = Storage::$data[$ffID];
        $ctime = time();

        $stock = Stock::instance($this->query['uID']);
        if(!$stock->get()){
            throw new ResponceException(CANT_LOAD_STOCK);
        }

        if(!$stock->takeAll($fakefriend['price'])){
            throw new ResponceException(NOT_ENAUGH_MATERIALS);
        }
            
        for ($i = 0; $i < $fakefriend['count']; $i++) {
            do {
            	$fakeid = 'f'.rand(1,100000);
            } while (isset($building->data['friends'][$fakeid]));
            	$building->data['friends'][$fakeid] = $ctime;
        }
        Quest::register($building->sID, 1);

        $building->update();
		$stock->update();

        return ['friends' => $building->data['friends']];
    }

    public function growAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id']);
        $building = $this->loadModel();

        // Умерший объект не работает
        if (isset($building->data['died']))
            throw new ResponceException(NOT_READY, 'died');

        $uID = $this->query['uID'];

        // Последний уровень
        end($building->info['levels']);
        $maxLevel = key($building->info['levels']);
        // Кол-во друзей в здании
        $haveFriends = count($building->data['friends']);

        $bonus = [];
        for ($i = $building->data['floor']; $i <= $maxLevel; $i++){
            // Требования по кикам и друзьям
            $needKicks = $building->info['levels'][$i]['req']['kicks'];
            $needFriends = $building->info['levels'][$i]['req']['friends'];

            if ($building->data['kicks'] < $needKicks || $haveFriends < $needFriends)
                break;

            // Повышение уровня
            $building->data['floor']++;
            Quest::register($building->sID, $building->data['floor']);

            // Бонус за уровень
            if (!empty($building->info['levels'][$i]['bonus'])){
                $treasure = $building->info['levels'][$i]['bonus'];

                if (YBTreasure::isJapan()) {
                    $treasure = YBTreasure::generate($treasure, $treasure, $building);
                } else $treasure = Treasure::generate($treasure, $treasure);

                $bonus = Treasure::merge($bonus, $treasure);
            }
        }

        $result = [];
        $remove = false;

        // Проверка пройденности всех уровней
        if ($building->data['floor'] > $maxLevel){
            // Бонус за все уровни
            if (!empty($building->info['treasure'])){
                $treasure = $building->info['treasure'];

                if (YBTreasure::isJapan()) {
                    $treasure = YBTreasure::generate($treasure, $treasure, $building);
                } else $treasure = Treasure::generate($treasure, $treasure);

                $bonus = Treasure::merge($bonus, $treasure);
            }

            switch ($building->info['faction']){
                // Работает, как Decor
                case 0:
                    $result['died'] = 1;
                    $building->data['died'] = 1;
                    break;
                // Работает, как Golden
                case 1:
                    $building->data['crafted'] = 1;
                    $result['crafted'] = $building->data['crafted'];
                    $result['floor'] = $building->data['floor'];
                    if (!empty($building->info['lifetime'])){
                        $building->data['lifetime'] = time() + (int)$building->info['lifetime'];
                        $result['lifetime'] = $building->data['lifetime'];
                    }

                    break;
                // Превращается в ...
                case 2:
                    $placeUnit = Unit::fromData(
                        $this->query['uID'],
                        $this->query['wID'],
                        [
                            'sid' => $building->info['emergent'],
                            'x' => $building->data['x'],
                            'z' => $building->data['z']
                        ]
                    );

                    $result['id'] = $placeUnit->id;
                    $result['died'] = 1;

                    $remove = true;
                    break;
                // Удаляется
                case 3:
                    $result['died'] = 1;
                    $remove = true;
                    break;
                default:
                    throw new ResponceException(NOT_READY, 'Undefined action');
            }
        } else {
            // Обновление toThrow
            $building->setToThrow('all');
            $result['floor'] = $building->data['floor'];
            $result['toThrow'] = $building->data['toThrow'];
        }

        // Начисление бонусов
        if (!empty($bonus)){
            $stock = Stock::instance($uID);
            if(!$stock->get())
                throw new ResponceException(CANT_LOAD_STOCK);

            $stock->addFromTreasure($bonus);
            $stock->update();
        }

        if ($remove){
            $building->delete();
        } else {
            $building->update();
        }

        $result['bonus'] = $bonus;

        return $result;
    }

    public function storageAction(){

        $this->requireQuery(['uID','wID','sID','id']);
        $building = $this->loadModel();

        $ctime = time();

        if (isset($building->data['died']))
            throw new ResponceException(NOT_READY, 'died');

        if (empty($building->data['crafted']))
            $building->data['crafted'] = $ctime;
        else if ($building->data['crafted'] > $ctime)
            throw new ResponceException(NOT_READY);

        $result = [];

        // Время жизни декора вышло?
        if (!empty($building->info['lifetime']) && $ctime > $building->data['lifetime']){
            $building->data['died'] = 1;
            $result['died'] = 1;
        } else {
            // Capacity
            if(!empty($building->info['capacity'])) {
                if(!isset($building->data['capacity']))
                    $building->data['capacity'] = 0;
                $building->data['capacity']++;

                if($building->data['capacity'] >= (int)$building->info['capacity']){
                    $building->data['died'] = 1;
                    $result['died'] = 1;
                }
            }
        }

        $building->data['crafted'] = $building->info['time'] + $ctime;
        $result['crafted'] = $building->data['crafted'];

        Quest::register($building->sID, 1);

        $treasure = $building->info['treasure'];
        if(YBTreasure::isJapan()) {
            $treasure = YBTreasure::generate($treasure, $treasure, $building);
        } else $treasure = Treasure::generate($treasure, $treasure);

        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        $stock->addFromTreasure($treasure);
        $stock->update();

        $result['bonus'] = $treasure;

        $building->update();

        return $result;
    }
}
