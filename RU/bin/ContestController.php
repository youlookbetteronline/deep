<?php

class ContestController extends UnitController
{
    public function onBeforeBuy($unit, $stock, &$result = null){
        $result['toThrow'] = $unit->data['toThrow'];
    }

    public function onBeforeStock($unit, $stock, &$result = null){
        $result['toThrow'] = $unit->data['toThrow'];
    }

    public function throwAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'type']);
        $building = $this->loadModel();
        $uID = $this->query['uID'];
        $sID = $this->query['sID'];
        $type = $this->query['type'];
        if (!isset($building->data['toThrow'][$type])){
            throw new ResponceException(UNDEFINED_ID, $type);
        }

        // Получение toThrow по сохраненному ранее номеру
        $toThrowIdx = $building->data['toThrow'][$type];
        $level = $building->data['floor'];
        $toThrow = $building->info['levels'][$level]['throw'][$type][$toThrowIdx];

        $mID = $toThrow['m'];
        $count = $toThrow['c'];
        $number = $toThrow['k'];

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
        } elseif ($type == 'msimple' || $type == 'mcomplex'){
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

        // Обновление toThrow
        $building->setToThrow($type);

        Quest::register($building->sID, 1);

        $building->update();
        $stock->update();

        Top::add($uID, $sID, $number);

        return ['kicks' => $building->data['kicks'], 'toThrow' => $building->data['toThrow']];
    }

    public function storageAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id']);
        $unit = $this->loadModel();

        $ctime = time();

        // Если занят
        if ($unit->data['crafted'] > $ctime)
            throw new ResponceException(NOT_READY, 'crafted');

        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        $level = $unit->data['floor'];
        $treasure = $unit->info['levels'][$level]['bonus'];
        if (YBTreasure::isJapan()) {
            $treasure = YBTreasure::generate($treasure, $treasure, $unit);
        } else $treasure = Treasure::generate($treasure, $treasure);
        $stock->addFromTreasure($treasure);

        Quest::register($unit->sID, 1);

        $unit->data['crafted'] = $ctime + (int)$unit->info['time'];

        $unit->update();
        $stock->update();

        return ['crafted' => $unit->data['crafted'], 'bonus' => $treasure];
    }

    public function upgradeAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id']);
        $building = $this->loadModel();

        $uID = $this->query['uID'];

        // Последний уровень
        end($building->info['levels']);
        $maxLevel = key($building->info['levels']);

        $result = [];
        $currentFloor = $building->data['floor'];
        $treasure = $building->info['levels'][$currentFloor]['bonusupgrade'];
        if (YBTreasure::isJapan()) {
            $treasure = YBTreasure::generate($treasure, $treasure, $building);
        } else $treasure = Treasure::generate($treasure, $treasure);

        $building->data['floor'] = $building->data['floor'] + 1;
        $building->setToThrow('all');
        $result['floor'] = $building->data['floor'];
        $result['toThrow'] = $building->data['toThrow'];

        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        
        $stock->addFromTreasure($treasure);

        $result['bonus'] = $treasure;
        Quest::register($building->sID, $building->data['floor']);

        $building->update();
        $stock->update();

        return $result;
    }

}
