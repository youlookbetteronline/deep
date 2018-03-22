<?php

class BeastController extends UnitController
{
    public function onBeforeBuy($unit, $stock, &$result = null){
        $result['expire'] = $unit->data['expire'];
        $result['toThrow'] = $unit->data['toThrow'];
    }

    public function onBeforeStock($unit, $stock, &$result = null){
        $result['expire'] = $unit->data['expire'];
        $result['toThrow'] = $unit->data['toThrow'];
    }

    public function throwAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'type']);
        $unit = $this->loadModel();

        // Время жизни
        if ($unit->data['expire'] <= time()) {
            $unit->delete();
            return ['died' => 1];
        }
        $type = $this->query['type'];
        if (!isset($unit->info['throw'][$type]))
            throw new ResponceException(ARE_YOU_HACKER, 'Undefined type');

        // Получение toThrow по сохраненному ранее номеру
        $idx = $unit->data['toThrow'][$type];
        $toThrow = $unit->info['throw'][$type][$idx];

        // Контроль максимального времени жизни
        /*$lifetime = $unit->data['expire'] + (int)$toThrow['t'] - time();
        if ($lifetime > $unit->info['maxtime'])
            throw new ResponceException(NOT_READY, 'maxtime');*/
        
		if ($toThrow['b'] == 2){
			// by FANTS
			$price = [Stock::FANT => $toThrow['c']];
		}
		else
			$price = [$toThrow['m'] => $toThrow['c']];

        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        if (!$stock->takeAll($price))
            throw new ResponceException(NOT_ENAUGH_MATERIALS);

        // Продление времени жизни юнита
        $unit->data['expire'] += (int)$toThrow['t'];

        // Обновление toThrow
        $unit->setToThrow($type);

        Quest::register($unit->sID, 1);
        App::$request['data']['expire'] = $unit->data['expire'];

        $unit->update();
        $stock->update();

        

        return ['expire' => $unit->data['expire'], 'toThrow' => $unit->data['toThrow']];
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

        $treasure = $unit->info['shake'];
        if (YBTreasure::isJapan()) {
            $treasure = YBTreasure::generate($treasure, $treasure, $unit);
        } else $treasure = Treasure::generate($treasure, $treasure);
        $stock->addFromTreasure($treasure);

        Quest::register($unit->sID, 1);

        // Время жизни
        if ($unit->data['expire'] <= $ctime) {
            $unit->delete();
            $stock->update();

            return ['died' => 1, 'bonus' => $treasure];
        }

        $unit->data['crafted'] = $ctime + (int)$unit->info['time'];

        $unit->update();
        $stock->update();

        return ['crafted' => $unit->data['crafted'], 'bonus' => $treasure];
    }

    public function renameAction()
    {
        $this->requireQuery(['uID', 'wID', 'sID', 'id', 'name']);
        $unit = $this->loadModel();

        $name = $this->query['name'];
        Quest::register($unit->sID, 1);
        $unit->data['beastName'] = $name;
        $unit->update();
        return ['beastName' => $unit->data['beastName']];
    }
}
