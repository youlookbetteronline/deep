<?php

class GoldenController extends BuildingController{

	public function onBeforeBuy($unit, $stock, &$result = null){
		$stock->add(Stock::EXP, (int) $unit->info['experience']);

		if(!empty($unit->info['tostock']))
			$stock->addAll($unit->info['tostock']);

		$unit->data['crafted'] = time(); //$unit->info['time'] +
        $unit->update();
        $result['crafted'] = $unit->data['crafted'];

		Quest::register($unit->sID, 1, 'buy', 'alldecors');
	}

	public function onBeforePut($unit, $stock)
    {
        /* Сохранение оставшегося времени до 'crafted' перед зачислением на склад */

        if (!empty($unit->data['crafted'])) {
            $user = User::instance($this->query['uID']);
            if (!$user->get())
                throw new ResponceException(CANT_LOAD_USER);

            // Запись времени до 'crafted'
            if (empty($user->data['unitsHistory'][$unit->sID]))
                $user->data['unitsHistory'][$unit->sID] = [];
            $user->data['unitsHistory'][$unit->sID][] = ['craftedDiff' => $unit->data['crafted'] - time()];

			//$user->updatePartial(['unitsHistory']);
			$user->update();
        }
    }

	public function onBeforeStock($unit, $stock, &$result = NULL)
    {
        /* При выставлении со склада существовавшего ранее юнита оставшееся время до 'crafted' не должно сбрасываться */

        $user = User::instance($this->query['uID']);
        if (!$user->get())
            throw new ResponceException(CANT_LOAD_USER);

        if (empty($user->data['unitsHistory'][$unit->sID])) {
            $unit->data['crafted'] = time();
        } else {
            // Извлечение последней записи по sID
            $historyRecord = array_pop($user->data['unitsHistory'][$unit->sID]);
            $unit->data['crafted'] = time() + $historyRecord['craftedDiff'];

            //$user->updatePartial(['unitsHistory']);
			$user->update();
        }
	}

	public function rewardAction(){}
	public function upgradeAction(){}
	public function speedupAction(){}
	public function craftingAction(){}

    /*public function storage2Action(){

        $this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));

        $building = $this->loadModel();

        $time = $building->info['time'];
        $treasure = $building->info['shake'];

        if($building->data['crafted'] > time()){
            throw new ResponceException(NOT_READY);
        }

        $stock = Stock::instance($this->query['uID']);
        if(!$stock->get()){
            throw new ResponceException(CANT_LOAD_STOCK);
        }

        if(!$stock->take(Stock::FANTASY,1)){
            throw new ResponceException(NOT_ENAUGH_MATERIALS);
        }

        if(empty($building->data['number'])){
            $building->data['number'] = 0;
        }

        $number = & $building->data['number'];

        $treasure = Treasure::shake($treasure,$treasure, $number);
        $stock->addFromTreasure($treasure);

        $building->data['crafted'] = $time + time();

        Quest::register($building->sID, 1, 'storage');

        $building->update();
        $stock->update();

        return array('started'=>$building->data['crafted'], 'bonus'=>$treasure, Stock::FANTASY=>$stock->data[Stock::FANTASY], 'number'=>$number);
    }*/


    public function storageAction(){

        $this->requireQuery(['uID','wID','sID','id']);
        $building = $this->loadModel();

        $ctime = time();

        if (isset($building->data['died']))
            throw new ResponceException(NOT_READY, 'died');

        // Время жизни декора вышло?
        if (!empty($building->info['lifetime']) &&
            $ctime > ($building->data['started'] + $building->info['lifetime']))
                $building->data['died'] = 1;

        if (empty($building->data['crafted']))
            $building->data['crafted'] = $ctime;
        else if ($building->data['crafted'] > $ctime)
            throw new ResponceException(NOT_READY);

        /*
        if(!$stock->take(Stock::FANTASY,1)){
            throw new ResponceException(NOT_ENAUGH_MATERIALS);
        }
        */

        $treasure = $building->info['shake'];
		if(YBTreasure::isJapan()) {
			$treasure = YBTreasure::generate($treasure, $treasure, $building);
		} else $treasure = Treasure::generate($treasure, $treasure);

        $stock = Stock::instance($this->query['uID']);
        if (!$stock->get())
            throw new ResponceException(CANT_LOAD_STOCK);
        $stock->addFromTreasure($treasure);
		$stock->update();

        Quest::register($building->sID, 1);
		Quest::register($building->sID, 1, 'storage', 'alldecors');

		$building->data['crafted'] = $building->info['time'] + $ctime;

		// Capacity
        if(!empty($building->info['capacity'])) {
            if(!isset($building->data['capacity']))
                $building->data['capacity'] = 0;
            $building->data['capacity']++;

            if($building->data['capacity'] >= (int)$building->info['capacity'])
                $building->data['died'] = 1;
        }
		$building->update();

        return ['started' => $building->data['crafted'], 'bonus' => $treasure, 'died' => isset($building->data['died'])? 1 : 0];
    }

	public function boostAction(){

		$this->check(array('hasUID','hasWID', 'hasSID', 'hasID'));

		$building = $this->loadModel();

		$stock = Stock::instance($this->query['uID']);
		if(!$stock->get()){
			throw new ResponceException(CANT_LOAD_STOCK);
		}

		Options::get();

		if(!$stock->take(Stock::FANT, $building->info['speedup'])){
			throw new ResponceException(NOT_ENAUGH_MATERIALS);
		}

		Quest::register($building->sID, 1);
		Quest::register(null, 1, 'boost','boost');

		$building->data['crafted'] = time();
		$building->update();
		$stock->update();

		return array('crafted'=>$building->data['crafted']);
	}

}
