<?php
set_time_limit(0);

class SaveController extends Controller
{
	public $layout='//layouts/column1';

	private $_locale = '';
    
    public $sections = array(
        'actions'               => 'Акции',
		'auctions' => array(
            'auctions'	=> 'Аукционы',
            'lots'		=> 'Лоты'
        ),
        'banlist'     => array(
            'banlist'           => 'Банлист',
            'uexception'        => 'Исключения'
        ),
        'banner'                => 'Баннер',
        'barter'                => 'Бартер',
        'bestsellers'           => 'Бестселлеры',

        'bonus' => array(
            'bonus'             => 'Бонусы',
            'daylibonus'        => 'Ежедневный бонус',
            'lacks'             => 'Бонус за отсутствие',
            'award'             => 'Награды',
            'blinks'            => 'Рекламные ссылки',
            'bounty'            => 'Халява с достижением по уровню',
            'wakeupbonus'       => 'Бонус "Разбуди друга"'
        ),

        'money' => array(
            'money'             => 'Деньги'
        ),
        'daylics'               => 'Дэйлики',
        'ach'    => array(
            'ach'               => 'Достижения',
            'achIndex'          => 'Индексы'
        ), 
        'inform'                => 'Информеры',
        'calendar'              => 'Календарь',
        'quests'    => array(
            'quests'            => 'Квесты',
            'chapters'          => 'Главы',
            'questsIndex'       => 'Индексы'
        ), 
        'treasures' => array(
            'treasures'         => 'Клады',
            'collectionIndex'   => 'Индексы'
        ),
		'coeff'                 => 'Коэффициенты цен',
        'config'                => 'Конфигурация',
        'crafting'              => 'Крафтинг',
        'news'                  => 'Новости',
        'updates'               => 'Обновления',
        'bulks'     => array(
            'bulks'             => 'Оптовые наборы',
            'bulkset'           => 'Наборы обьектов'
        ),
        'options'               => 'Опции игры', 
        'personages'            => 'Персонажи',
        'paygroups'             => 'Платежные группы',
        'gifts'     => array(
            'gifts'             => 'Подарки',
            'agifts'            => 'Подарки от админов'
        ),
        'updatelist'            => 'Порядок обновлений',
        'sales'                 => 'Распродажи',
        'advers'                => 'Реклама',
        'roulette'     => array(
            'roulette'          => 'Рулетка',
            'category'          => 'Категории'
        ),
        'satellite'             => 'Сателлиты',
        'sets'                  => 'Сэты',
        'bigsale'               => 'Тем. распродажи',
        'notify'                => 'Уведомления',
        'extension'             => 'Расширение',
        'levels'                => 'Уровни',
        'farming'               => 'Ферма',
        'freebie'               => 'Халява',    
        'storage'               => 'Хранилище',
        'gameevents'            => 'Эвенты',
        'bounty'                => 'Халява с уровнем',
        'event'                 => 'Событие',
        'top'                   => 'Рейтинги',
    );

	public function filters()
	{
		return array(
			'accessControl', // perform access control for CRUD operations
		);
	}
    
	/**
	 * Specifies the access control rules.
	 * This method is used by the 'accessControl' filter.
	 * @return array access control rules
	 */
	public function accessRules()
	{
		return array(
			array('allow',
				'actions'=>array('save','index','send', 'sections', 'send2'),
				'expression' => 'Yii::app()->user->isAdmin()'
			),
			array('allow',
				'actions'=>array('save','index','send', 'sections', 'send2'),
				'expression'=>"Yii::app()->user->can(Yii::app()->controller->id) || Yii::app()->user->can(Yii::app()->controller->id.'_'.Yii::app()->controller->action->id)"
			),
			array('deny',  // deny all users
				'users'=>array('*'),
			),
		);
	}

	public function actionIndex() {
        $model = Log::model();
        if(empty($_GET['Log_sort']))
            $_GET['Log_sort'] = '_id.desc';

        $logs = new EMongoDocumentDataProvider($model, ['pagination' => ['pageSize' => 30]]);

		if(!empty($_GET['response'])) {
			$response = $_GET['response'];
		} else $response = array();


		$this->render('index2',array(
			'servers' => Yii::app()->params->servers,
			'response' => $response,
            'logs' => $logs
		));
	}

    private function mc(&$object) {
        //$combine = ['mc'];
        if (!is_array($object))
            return;

        $keys = join(':', array_keys($object));
        switch($keys) {
            case 'c:m':
                $object = array_combine($object['m'], $object['c']);
                break;
            case 's:t':
            case 'm:c':
            case 'item:count':
            case 'i:c':
			case 'm:p':
			case 'c:tr':
                list($k,$v) = explode(':',$keys);
                $object = array_combine($object[$k], $object[$v]);
                break;
            case 't:m:c':
                list($t,$m,$c) = explode(':', $keys);
                $r = array();
                foreach($object[$m] as $_i => $_v) {
                    $r[$object[$t][$_i]][$_v] = $object[$c][$_i];
                }
                $object = $r;
                break;
            case 'm:c:t:b':
            case 'm:c:k:b':
                if (empty($object['m']))
                    return;

                list($m,$c,$t,$b) = explode(':', $keys);

                $r = [];
                foreach ($object[$m] as $_i => $_v) {
                    $item = [];
                    $item[$m] = $object[$m][$_i];
                    $item[$c] = $object[$c][$_i];
                    $item[$t] = $object[$t][$_i];
                    $item[$b] = $object[$b][$_i];
                    $r[] = $item;
                }
                $object = $r;

                //break;
                return $object;
        }

        foreach($object as $_key => &$_value)
            $this->mc($_value);

        return $object; 
    }
    
    public function actionSections() {
        $ssections = array();
        $types = Storage::getTypes();
        foreach($types as $key=>$type) {
            $section = $type['section'];
            if(!isset($ssections[$section]))
                $ssections[$section] = array();
            $ssections[$section][$key] = $type['name'];     
        }        
        Yii::app()->clientScript->corePackages = array(); 
        $this->renderPartial('sections', array('sections' => $this->sections, 'ssections' => $ssections, 'servers' => Yii::app()->request->getPost('server')), false, true);   
    }
	
	
	public function actionSave() {
		$this->redirect(array('index'));
	}

    public function __in($section, $id) {
        if(empty($this->_locale))
            return true;

        return isset($this->_locale[$section]) && isset($this->_locale[$section][$id]);
    }

    ///////////////////////////// addition parse fields
    private function parseInstance(&$value, &$_object = null) {
        //Storage[instance][devel][1][req][1][f]
        //Storage[instance][1][devel][1][obj][c][0]


        $instance = array();
        
        foreach($value as $_fname => $_fvalue) {
            if($_fvalue == null) continue;
            switch($_fname) {
                default:
                    $instance[$_fname] = $_fvalue;
                    break;
            }
        }
        
        

        if (empty($value['devel'])) {
            reset($value);
            $level = current($value);
            //if (isset($level['devel'])) {
                $instance = array();
                $devel = array();
                foreach ($value as $iID => $_instance) {
                    foreach ($_instance as $iField => $iValue) {
                        if($iField == 'devel') {
                            foreach($_instance['devel'] as $dID => $_devel) {
                                foreach($_devel as $field => $_value) {
                                    $devel[$iID][$field][$dID] = $_value;
                                }
                            }
                            $instance[$iField] = $devel;
                        } else {
                            $instance[$iField][$iID] = $iValue;
                        }
                    }
                }
                $this->mc($instance);
            //}
        }

        //Уровни в экземплярах зданий
        /*if(isset($value['devel'])) {
            foreach ($value['devel'] as $ilevel => $obj) {
                if(isset($obj['obj'])) {
                    foreach ($obj['obj'] as $level => $items) {
                        $instance['devel'][$ilevel]['obj'][$level] = array();
                        foreach ($items['m'] as $i => $sID) {
                            $instance['devel'][$ilevel]['obj'][$level][$sID] = $items['c'][$i];
                        }
                    }
                }
                if (isset($obj['req'])) {
                    $instance['devel'][$ilevel]['req'] = array();
                    $instance['devel'][$ilevel]['req'] = $obj['req'];
                }
                if(isset($obj['rew'])) {
                    foreach ($obj['rew'] as $level => $items) {
                        $instance['devel'][$ilevel]['rew'][$level] = array();
                        foreach ($items['m'] as $i => $sID) {
                            $instance['devel'][$ilevel]['rew'][$level][$sID] = $items['c'][$i];
                        }
                    }
                }
            }
        }*/
        $value = $instance;
    }
    
    private function parseThimbles(&$value, &$_object = null) {
        $result = [];
        foreach($value as $level => $data) {
            $result[$level] = [];
            foreach($data['m'] as $index => $sid) {
                $result[$level][$index] = [$sid => $data['c'][$index]];    
            }    
        }
        $value = $result;
    }

    private function parse_Predictions(&$value, &$_object = null) {
        $result = [];
        if(!empty($value['text'])) {
            foreach($value['text'] as $level => $data) {
                $result[$level] = array();
                $result[$level]['p'] = $data['text'];
                $result[$level]['m'] = current($value['out'][$level]['m']);
                $result[$level]['c'] = current($value['out'][$level]['c']);
            }
            $value = $result;
        }
    }
    
    private function parseDevel(&$value, &$_object = null) {
        
        $devel = array();
        
        foreach($value as $_fname => $_fvalue) {
            if($_fvalue == null) continue;
            switch($_fname) {
                case 'exchange':
                    $exchange = array();
                    foreach($_fvalue as $_level => $_info) {
                        $exchange[$_level] = [];
                        foreach($_info['item'] as $index => $sid) {
                            $exchange[$_level][$index] = [
                                'sid' => $sid,
                                'count' => $_info['count'][$index],
                                'price' => $_info['price'][$index],
                            ];    
                        }    
                    }
                    $devel[$_fname] = $exchange;
                    break;
                case 'thimbles':
                    $this->parseThimbles($_fvalue); 
                    $devel[$_fname] = $_fvalue;
                    break;
                default:
                    $devel[$_fname] = $_fvalue;
                    break;
            }
        }

        $value = $devel;
    }
    
    private function parseForm(&$value, &$_object = null) {
        $this->parseDevel($value);
    }
    
    private function parseKicks(&$value, &$_object = null) {

        $kicks = array();
        
        foreach($value['c'] as $i => $count) {
            $kick = array(
                'c' => $value['c'][$i],
                'b' => isset($value['b'])?$value['b'][$i]:'',
                'o' => isset($value['o'])?$value['o'][$i]:0,
            );
            foreach(['k','h','t'] as $_field) {
                if(isset($value[$_field])) {
                    $kick[$_field] = $value[$_field][$i];    
                }  
            } 
            if(isset($value['m'])) {
                $kicks[$value['m'][$i]] = $kick;    
            } else $kicks[] = $kick; 
        }
        $value = $kicks;
    }
    
    private function parsePoints(&$value, &$_object = null) {
        $this->parseKicks($value);
    }    
    
    private function parseMkicks(&$value, &$_object = null) {
        $this->parseKicks($value);
    }
    
    private function parseTower(&$value, &$_object = null) {  
        $tower = array();
        $n=1;
        foreach($value['t'] as $i=>$id) {
            $tower[$n] = array(
                't'=>$id,
                'c'=>$value['c'][$i],
                'm'=>isset($value['m'][$i])?$value['m'][$i]:0,
                'tip'=>isset($value['tip'][$i])?$value['tip'][$i]:0,
                'v'=>isset($value['v'][$i])?$value['v'][$i]:0
            );  
            $n++;
        }
        $value = $tower;        
    }
    
    private function parseItems(&$value, &$_object = null) {        
        $items = array();
        foreach(['item:count', 'm:c'] as $complex) {
            list($m, $c) = explode(':', $complex);
            if(!empty($value[$m])) {
                foreach($value[$m] as $i => $sID)
                    $items[] = array($sID => $value[$c][$i]);
                $value = $items;
                break;
            }
        }
    }    
    
    private function parseSlots(&$value, &$_object = null) {        
        switch($_object['type']) {
            case 'Building':
                $slots = array();
                foreach($value as $index => $slot) {
                    $slots[$index] = array(
                        'req' => isset($slot['m'])?array_combine($slot['m'], $slot['c']):array(),
                        'status' => $slot['s'] 
                    );  
                }
                $value = $slots;
                break;
        }
    }
    
    private function parseIlands(&$value, &$_object = null) {        
        $ilands = [];
        foreach($value['req'] as $index => $land) {
            $ilands[$land['sid']] = ['pos' => $land['pos'], 'req' => [], 'open' => []];
            if(!empty($value['obj'][$index])) {
                $obj = $value['obj'][$index];
                $ilands[$land['sid']]['req'] = array_combine($obj['m'], $obj['c']);
            }    
        }
        $value = $ilands;  
    }    
    
    private function parseExpire(&$value, &$_object = null) {        
        $expire = [];
        
        foreach($value['s'] as $index => $social) {
            $expire[$social] = strtotime( preg_replace('/\./', '/', $value['t'][$index]) );   
        }
        
        $value = $expire; 
    }
    
    public function sectionStorage($data, $filter) { 
        $criteria = array();
        if(!isset($filter['all'])) {
            if(in_array('Collection', $filter)) {
                if(!in_array('Material', $filter)) {
                    $filter[] = 'Material';
                }
            }
            $criteria['type'] = array('$in' => $filter);
        }
                
        $_storage = Storage::model()->getCollection()->find($criteria);    
        /////////////////////////
        $storage = array();
        
        $collections = [];


        foreach($_storage as $id => $value) {
            unset($value['_id']);

            if(!$value['enabled'])
                continue;

            foreach($value as $_field => &$_value) {
                if($_value === null) {
                    unset($value[$_field]);
                    continue;
                }
                $method = 'parse' . ucfirst($_field);
                if(method_exists($this, $method)) {
                    $this->{$method}($_value, $value);
                }
            }

            $this->mc($value);

            if ($value['type'] == 'Building' && !empty($value['skins']))
                $this->mc($value['skins']);

            if ($value['type'] == 'Booster' && !empty($value['target']))
                $this->mc($value['target']);

            // Сохранение поля "available" (тип Lands) в формате: day => ['hstart' => hstart, 'hend' => hend]
            if ($value['type'] == 'Lands') {
                if (!empty($value['available'])) {
                    $available = [];
                    foreach ($value['available']['day'] as $idx => $day) {
                        $available[(int)$day] = ['hstart' => (int)$value['available']['hstart'][$idx], 'hend' => (int)$value['available']['hend'][$idx]];
                    }
                    $value['available'] = $available;
                }

                if (!empty($value['start'])) {
                    foreach ($value['start'] as $net => &$time) {
                        $time = strtotime(str_replace('.', '-', $time));
                    }
                }
            }

            // Box на публ. карте
            if ($value['type'] == 'Publicbox' && !empty($value['reward']))
                $this->mc($value['reward']);

            // Beast или Contest
            if ($value['type'] == 'Beast' || $value['type'] == 'Contest') {
                /*$this->mc($value['throwsimple']);
                $this->mc($value['throwcomplex']);
                $this->mc($value['throwdonate']);*/

                $value['throw'] = ['simple' => $value['throwsimple'], 'complex' => $value['throwcomplex'], 'donate' => $value['throwdonate']];
                unset($value['throwsimple'], $value['throwcomplex'], $value['throwdonate']);
            }

            // Craftfloors
            if ($value['type'] == 'Craftfloors' && !empty($value['levels'])) {
                foreach ($value['levels'] as &$level) {
                    if (!empty($level['option']['craft'])) {
                        $level['option']['craft'] = array_values($level['option']['craft']);
                    }
                }
            }

            unset($value['_id']);
            $this->retranslate('storage:'.$value['ID'], $value);
            $storage[$value['ID']] = $value;
        }
        foreach($collections as $sid => $list) {
            $storage[$sid]['mlist'] = $list;    
        }

        return $storage;                   
    }
    
    public function sectionCategory() {
        $_category = array();
        $categoryModel = new Category;
        $category = $categoryModel->getCollection()->find();

        foreach($category as $id=>$value) {
            unset($value['ID']);

            if (!empty($value['items'])) {
                $items = $value['items'];
                unset($value['items']);
                foreach($items as $index => $data) {
                    if ($index == 'm') {
                        foreach($data as $_index => $sid) {
                            $value['items'][][$sid] = $items['p'][$_index];
                        }
                    }
                }
            }
            $this->retranslate('category:'.$id, $value);
            $_category[$id] = $value;
        }  
        return $_category;
    }

    public function sectionTop() {
        $_top = array();
        $topModel = new Top;
        $top = $topModel->getCollection()->find();

        foreach($top as $id => $value) {
            unset($value['_id']);
            $_expire = [];
            foreach($value['expire']['n'] as $index => $net) {
                $_expire[$net] = [
                    's' => strtotime( str_replace('.', '-', $value['expire']['s'][$index]) ),
                    'e' => strtotime( str_replace('.', '-', $value['expire']['e'][$index]) ),
                ];
            }
            $value['expire'] = $_expire;

            $this->retranslate('top:'.$id, $value);
            $_top[$id] = $value;
        }
        return $_top;
    }

    public function sectionRoulette() {
        $_roulette = array();
        $rouletteModel = new Roulette;
        $roulette = $rouletteModel->getCollection()->find();

        foreach($roulette as $id=>$value) {
            unset($value['ID']);

            if (!empty($value['cost'])) {
                $items = $value['cost']['req'];
                unset($value['cost']);
                foreach($items as $index => $data) {
                    $value['cost'][$index] = $data['c'];
                }
            }
            $this->mc($value);
            $this->retranslate('roulette:'.$id, $value);
            $_roulette[$id] = $value;
        }
        
        return $_roulette;
    }

    public function sectionEvent() {
        $_event = array();
        $eventModel = new Event;
        $event = $eventModel->getCollection()->find();

        foreach($event as $id => $value) {
            unset($value['_id']);
            if (!empty($value['items'])) {
                $items = $value['items'];
                unset($value['items']);
                foreach($items as $index => $data) {
                    if (empty($value['items'][$index])) {
                        $value['items'][$index] = array();
                    }
                    $value['items'][$index]['i'] = !empty($data['i']['m'][0])?$data['i']['m'][0]:0;
                    $value['items'][$index]['t'] = !empty($data['t'])? $data['t'] : '';
                }
            }

            if (!empty($value['expire'])) {
                $expire = $value['expire'];
                $value['expire'] = array();
                foreach ($expire['s'] as $index => $net) {
                    $value['expire'][$net] = !empty($expire['t'][$index])? strtotime(str_replace('.', '-', $expire['t'][$index])) : 0;
                }
            }

            $this->retranslate('event:'.$id, $value);
            $_event[$id] = $value;
        }

        return $_event;
    }


    public function sectionChapters() {
        $chapters = array();
        $_chapters = QuestLegends::model()->getCollection()->find();
        foreach($_chapters as $chapter) {
            unset($chapter['_id']);
            $this->retranslate('chapters:'.$chapter['ID'], $chapter);
            $chapters[$chapter['ID']] = $chapter;            
        }   
        return $chapters;
    }

    //Халява с достижением по уровню
    public function sectionBounty() {
        $bounty = array();
        $_bounty = Bounty::model()->getCollection()->find();

        foreach($_bounty as $id => $value) {
            if (!empty($value['items']['bonus']) && !empty($value['items']['req'])) {
                $bonus = $value['items']['bonus'];
                $players = $value['items']['req'];

                unset($value['items']['bonus']);
                unset($value['items']['req']);

                foreach($bonus as $index => $data) {
                    if(!empty($data['m']) && !empty($data['c'])) {
                        foreach($data['m'] as $i => $sID) {
                            $value['items'][$players[$index]['p']][$sID] = $data['c'][$i];
                        }
                    }
                }
            }
            $bounty[$value['_id']] = $value;
            unset($bounty[$value['_id']]['_id']);
        }
        return $bounty;
    }
    
    public function sectionQuestsIndex() {
        return array();               
    }
    
    public function sectionQuests() {
        $_quests = Quests::model()->getCollection()->find()->sort(array('order' => 1));
        $quests = array();
        
        foreach($_quests as $id => $quest) {            
            if(isset($quest['enable']) && (int)$quest['enable'] == 0) continue;
                        
            unset($quest['_id']);
            ////////////////////////////
            if(!empty($quest['missions'])) {
                foreach($quest['missions'] as $id=>$mission) {
                    $temp = $mission['target'];
                    
                    if(!empty($mission['target'])) {
                        $mission['target'] = array();
                        foreach($temp as $type => $item) {
                            $mission['target'] = array_merge($mission['target'], $item);
                        }
                    }
                    $quest['missions'][$id] = $mission;
                }
            }
            ///////////////////////////bonus
            if(!empty($quest['bonus']['materials'])) {
                $temp = $quest['bonus']['materials'];
                $quest['bonus']['materials'] = array();
                foreach($temp as $item) {
                    foreach($item as $mid=>$count) {
                        $quest['bonus']['materials'][$mid] = $count;
                    }
                }
            }
            $this->retranslate('quests:'.$quest['ID'], $quest);
            //////////////////////////// social
            if(empty($quest['social'])) {
                $quest['social'] = 'DM';
                //die;    
            }
            
            $net = $quest['social'];
            if(!isset( $quests[$net] )) $quests[$net] = array();
            $quests[$net][$quest['ID']] = $quest; 
        }
        return $quests;
    }

    public function sectionActions() {
		//АКЦИИ
        $actions = array();
        $_actions = Actions::model()->getCollection()->find();
        foreach($_actions as $id=>$value) {
            if(!$value['enabled']) {
                continue;
            }
            
            if((int)$value['type'] == 1) {
                $endtime = $value['time']+(int)$value['duration']*60*60;
                if($endtime < time()) {
                    continue;
                } 
            }
                            
            if(!empty($value['items'])) {
                $items = array();
                $iorder = array();
                foreach($value['items']['m'] as $i => $sID) {
                    //$n = empty($value['items']['o'][$i])?0:$value['items']['o'][$i];
                    $items[$sID] = $value['items']['c'][$i];
                    $iorder[$sID] = $i;
                }
                $value['items'] = $items;
                $value['iorder'] = $iorder;
            }
                   
            if(!empty($value['bonus'])) {
                $items = array();
                $border = array();
                foreach($value['bonus']['m'] as $i=>$sID) {
                    $n = empty($value['bonus']['o'][$i])?0:$value['bonus']['o'][$i];
                    $items[$sID] = $value['bonus']['c'][$i];
                    $border[$sID] = $n;
                }
                $value['bonus'] = $items;
                $value['border'] = $border;
            }
            
            if(!empty($value['price'])) {
                $items = array();
                foreach($value['price']['p'] as $i=>$p) {
                    $items[$value['price']['e'][$i]] = $p;
                }
                $value['price'] = $items;
            }
			
			// mprice - price in materials
			if(!empty($value['mprice'])) {
                $mprice = [];
                foreach($value['mprice']['p'] as $i => $price) {
					$social = $value['mprice']['s'][$i];
					$items = [];

					foreach ($price['m'] as $idx => $mID) {
						$items[$mID] = $price['c'][$idx];
					}
                    $mprice[$social] = $items;
                }
                $value['mprice'] = $mprice;
            }
            
            $this->retranslate('actions:'.$value['_id'], $value);
            
            $actions[$value['_id']] = $value;
            unset($actions[$value['_id']]['_id']);
        }     
        return $actions;
    }

	public function sectionAuctions() {
		// Аукционы
		$auctions = [];

		$_tmp = new Auctions();
		$_tmp = $_tmp->getCollection()->find();
		foreach ($_tmp as $_item) {
			foreach ($_item['expire']['n'] as $_index => $_net) {
				$_item['expire'][$_net] = [
					's' => strtotime(str_replace('.', '-', $_item['expire']['s'][$_index])),
					'e' => strtotime(str_replace('.', '-', $_item['expire']['e'][$_index])),
				];
			}

			$_id = $_item['_id'];
			if (!is_scalar($_id) && method_exists($_id, '__toString')) {
				$_id = $_id->__toString();
			}
			unset($_item['_id']);

			$auctions[$_id] = $_item;
		}
		
		return $auctions;
	}

	public function sectionLots() {
		// Лоты
		$lots = [];

		$_tmp = new Lots();
		$_tmp = $_tmp->getCollection()->find();
		foreach ($_tmp as $_item) {
			foreach ($_item['expire']['n'] as $_index => $_net) {
				$_item['expire'][$_net] = [
					's' => strtotime(str_replace('.', '-', $_item['expire']['s'][$_index])),
					'e' => strtotime(str_replace('.', '-', $_item['expire']['e'][$_index])),
				];
			}

			$_id = $_item['_id'];
			if (!is_scalar($_id) && method_exists($_id, '__toString')) {
				$_id = $_id->__toString();
			}
			unset($_item['_id']);

            // Бонусы
            if (!empty($_item['bet_bonus'])) {
                $this->mc($_item['bet_bonus']);
            }
            if (!empty($_item['bonus'])) {
                $this->mc($_item['bonus']);
            }

			$lots[$_id] = $_item;
		}

		return $lots;
	}

    public function sectionSatellite() {
        $_satellite= Satellite::model()->getCollection()->find();
        $satellite = array();
        foreach($_satellite as $id=>$value) {
            $items = array();
            if(!empty($value['reward'])) {
                foreach($value['reward']['m'] as $i=>$sID) {
                    $items[$sID] = $value['reward']['c'][$i];
                }
                $value['reward'] = $items;
            }
            if(empty($satellite[$value['social']])) {
                $satellite[$value['social']] = array();
            }
            unset($value['_id']);
            unset($value['game']);
            $social = $value['social'];
            unset($value['social']);
            $this->retranslate('satellite:'.$value['ID'], $value);
            $satellite[$social][$value['ID']] = $value;
        }
        return $satellite;
    }

    public function sectionBanner() {
        $_banner = IngameBanner::model()->getCollection()->find();
        $banner = array();
        foreach($_banner as $id=>$value) {
            if(empty($banner[$value['social']])) {
                $banner[$value['social']] = array();
            }
            unset($value['_id']);
            unset($value['game']);
            $social = $value['social'];
            unset($value['social']);
            $banner[$social][] = $value;
        }
        $_banner = null;
        return $banner;
    }

    public function sectionSales() {
        $_sales = Sales::model()->getCollection()->find();       
        $sales = array();
        foreach($_sales as $id=>$value) {
            if(!$value['enabled'])
                continue; 
                
            if(!empty($value['social'])) {
                $social = array();
                foreach($value['social'] as $sID) {
                    $social[$sID] = $sID;
                }
                $value['social'] = $social;
            }    
                
            if(!empty($value['items'])) {
                $items = array();
                $iorder = array();
                $n=0;
                foreach($value['items']['m'] as $i=>$sID) {
                    //$n = empty($value['items']['o'][$i])?0:$value['items']['o'][$i];
                    $items[$sID] = [
                        'price' => $value['items']['p'][$i],
                        'decor' => empty($value['items']['d'][$i])?'':$value['items']['d'][$i],
                    ];
                    //$value['items']['p'][$i];
                    $iorder[$sID] = $n;
                    $n++;
                }
                $value['items'] = $items;
                $value['iorder'] = $iorder;
            }
            
            $sales[$value['_id']] = $value;
            unset($sales[$value['_id']]['_id']);
        }
        
        return $sales; 
    } 
    
    public function sectionNotify() {
        //УВЕДОМЛЕНИЯ
        $_notify = Notifications::model()->getCollection()->find();
        $notify = array();
        foreach($_notify as $id=>$value) {
            unset($value['_id']);
            $notify[$value['name']] = array(
				'msg'=>$value['messages'],
				'socials'=>$value['socials'],
				'link'=>isset($value['link'])?$value['link']:''
			);
            //$notify[$value['name']] = $value['messages'];        
        }       
        return $notify;
    }

	public function sectionExtension() {
        //РАСШИРЕНИЕ ДЛЯ БРАУЗЕРА
        $_extension = Extension::model()->getCollection()->find();
        $extension = array();
        foreach($_extension as $id=>$value) {
            unset($value['_id']);
            //$extension[$value['name']] = array(
            $extension[$id] = array(
				'name' => $value['name'],
				'type' => $value['type'],
				'msg'  => $value['messages'],
				'link' => isset($value['link'])? (string)$value['link'] : ''
			);
        }
        return $extension;
    }
           
    
    public function sectionAchIndex() {
        return array();
    }
    
    public function sectionAch() {
        $daylics = array();
        $_daylics = Ach::model()->getCollection()->find()->sort(array('order'=>1));

        foreach($_daylics as $id=>$value) {
            if(isset($value['enable']) && (int)$value['enable'] == 0) continue;
            unset($value['_id']);
            if(!empty($value['missions'])) {
                foreach($value['missions'] as $id=>$mission) {
                    $temp = $mission['target'];
                    if(!empty($mission['target'])) {
                        $mission['target'] = array();
                        foreach($temp as $type => $item) {
                            $mission['target'] = array_merge($mission['target'], $item);
                        }
                    }
                    if(!empty($mission['bonus'])) {
                        $b = $mission['bonus'];
                        $mission['bonus'] = array();
                        foreach($b['i'] as $index => $item) {
                            $mission['bonus'][$item] = $b['c'][$index];
                        }
                    }
                    
                    $value['missions'][$id] = $mission;
                }
            }

            if(!empty($value['bonus'])) {
                $this->mc($value['bonus']);

//                 $temp = $value['bonus'];
//                 $value['bonus'] = array();
//                 foreach($temp as $item) {
//                     $value['bonus'][$item['i']] = $item['c'];
//                 }
            }

            $this->retranslate('ach:'.$value['ID'], $value);
            $daylics[$value['ID']] = $value;        
        }

        return $daylics;   
    }
    
    public function sectionDaylics() {
        $daylics = array();
        $_daylics = Daylics::model()->getCollection()->find()->sort(array('order'=>1));

        foreach($_daylics as $id=>$value) {
            if(isset($value['enable']) && (int)$value['enable'] == 0) continue;
            unset($value['_id']);
            if(!empty($value['missions'])) {
                foreach($value['missions'] as $id=>$mission) {
                    $temp = $mission['target'];

                    if(!empty($mission['target'])) {
                        $mission['target'] = array();
                        foreach($temp as $type => $item) {
                            $mission['target'] = array_merge($mission['target'], $item);
                        }
                    }

                    /*if(!empty($mission['bonus'])) {
                        $b = $mission['bonus'];
                        $mission['bonus'] = array();
                        foreach($b['i'] as $index => $item) {
                            $mission['bonus'][$item] = $b['c'][$index];
                        }
                    }*/

                    if(!empty($mission['bonus'])) {
                        $temp = $mission['bonus'];
                        $mission['bonus'] = array();
                        foreach($temp as $item) {
                            $mission['bonus'][$item['i']] = $item['c'];
                        }
                    }
                    
                    $value['missions'][$id] = $mission;
                }
            }
                
            if(!empty($value['bonus'])) {
                $temp = $value['bonus'];
                $value['bonus'] = array();
                foreach($temp as $item) {
                    $value['bonus'][$item['i']] = $item['c'];
                }
            }
            
            $this->retranslate('daylics:'.$value['ID'], $value);
            $daylics[$value['ID']] = $value;        
        } 
                
        return $daylics;  
    }
    
    public function sectionMoney() {
        //ДЕНЬГИ
        $money = array();
        $_money = Money::model()->getCollection()->find();
        foreach($_money as $id=>$value) {
            $ID = $value['_id'];
            unset($value['_id']);
            try{
                if(!empty($value['date_from']))
                    $value['date_from'] = strtotime($value['date_from']);
                if(!empty($value['date_to']))
                    $value['date_to'] = strtotime($value['date_to']);
            }catch(Exception $e) {
                $value['date_from'] = 0;
                $value['date_to'] = 0;
            } 

            if (!empty($value['sids']))
                $value['sids'] = array_values($value['sids']);

            $this->retranslate('money:'.$ID, $value);
            $money[$ID] = $value;            
        }    
        $_money = null; 
        return $money;
    }
    
    public function sectionStones(&$data) {
        ///////////////////// КАМНИ
        $_stones = Stones::model()->getCollection()->find();
        foreach($_stones as $id => $value) {
            $ID = $value['_id'];
            unset($value['_id']);
            try{
                if(!empty($value['date_from']))
                    $value['date_from'] = strtotime($value['date_from']);
                if(!empty($value['date_to']))
                    $value['date_to'] = strtotime($value['date_to']);
            }catch(Exception $e) {
                $value['date_from'] = 0;
                $value['date_to'] = 0;
            }  
                        
            $this->retranslate('stones:'.$ID, $value);   
            if(!isset($data['money'][$ID]))
                $data['money'][$ID] = array();
            foreach(Stones::$TYPES as $_type) {
                if(empty($value[$_type])) continue;
                $data['money'][$ID][$_type] = $value[$_type];               
            }                       
        }
        $_stones = null;
        //////// у раздела камни есть привязка к сетам 
        $data['sets'] = $this->sectionSets($data);
        return false;
    }
    
    public function sectionSets() {
        $_sets = Sets::model()->getCollection()->find();
        $sets = array();
        
        foreach($_sets as $id=>$value) {
            if(!$value['enabled'])
                continue;
            //unset($value['_id']);
            if(!empty($value['items'])) {
                $items = array();
                $iorder = array();
                foreach($value['items']['m'] as $i=>$sID) {
                    $n = empty($value['items']['o'][$i])?0:$value['items']['o'][$i];
                    $items[$sID] = $value['items']['c'][$i];
                    $iorder[$sID] = $n;
                }
                $value['items'] = $items;
                $value['iorder'] = $iorder;
            }
                           
            if(!empty($value['price'])) {
                $items = array();
                $old = array();
                foreach($value['price']['p'] as $i=>$p) {
                    $items[$value['price']['e'][$i]] = $p;
                    $old[$value['price']['e'][$i]] = $value['price']['o'][$i];
                    
                }
                $value['price'] = $items;
                $value['oldprice'] = $old;
            }
            $social = $value['social'];
            $value['social'] = array();
            foreach ($social['net'] as $i=>$net) {
                $value['social'][$net] = $social['enabled'][$i];
            }

            $this->retranslate('sets:'.$value['_id'], $value);
            
            $sets[$value['_id']] = $value;
            unset($sets[$value['_id']]['_id']);
        }  
        
        return $sets;
    }
    
    public function sectionUpdates() {
        //ОБНОВЛЕНИЯ
        $updatesModel = new Update;
        $_updates = Update::model()->getCollection()->find();
        $updates = array();
        
        foreach($_updates as $id=>$value) {
            /*if(!$value['enabled'])
                continue;  */  
            if(!empty($value['social'])) {
                $social = array();
                foreach($value['social'] as $sID) {
                    $social[$sID] = $sID;
                }
                $value['social'] = $social;
            }    
            
            if(!empty($value['ext'])) {
                $ext = array();
                foreach($value['ext'] as $sID) {
                    $ext[$sID] = $sID;
                }
                $value['ext'] = $ext;
            }    
            
            if(!empty($value['items'])) {
                /*$items = array();
                 
                foreach($value['items'] as $i => $sID) {
                    $items[$sID] = $i;
                }   */
                $value['items'] = array_combine(array_values($value['items']), range(0,count($value['items'])-1));
            }    
            
            if(!empty($value['stay'])) {
                $stay = array();
                foreach($value['stay'] as $i=>$sID) {
                    $stay[$sID] = $i;
                }
                $value['stay'] = $stay;
            }    
            $this->retranslate('updates:'.$value['_id'], $value);
            $updates[$value['_id']] = $value;
            unset($updates[$value['_id']]['_id']); 
        }

        $_updates = null;
        return $updates;
    }
    
    public function sectionUpdatelist() {
        $_updatelist = Updatelist::model()->getCollection()->find();
        $updatelist = array();
        foreach($_updatelist as $id=>$value) {
            //$list = array_values($value['items']);
            foreach($value['items'] as $order=>$update) {
                $updatelist[$value['social']][$update[0]] = $update[1];
            }  
        } 
        $_updatelist = null;
        return $updatelist;   
    }
    
    public function sectionFreebie() {
        //ХАЛЯВА
        $_freebie = Freebie::model()->getCollection()->find();
        $freebie = array();
        
        foreach($_freebie as $id=>$value) {
            if(!empty($value['stage']['bonus'])) {  
                foreach($value['stage']['bonus'] as $level => $_bonus) {
                    $value['stage']['bonus'][$level] = array_combine($_bonus['m'], $_bonus['c']);         
                }
            } else {
                if(!empty($value['bonus'])) {
                    $items = array();
                    foreach($value['bonus']['m'] as $i=>$sID) {
                        $items[$sID] = $value['bonus']['c'][$i];
                    }
                    $value['bonus'] = $items;
                } 
            }
            $this->retranslate('freebie:'.$value['_id'], $value);
            $freebie[$value['_id']] = $value;
            unset($freebie[$value['_id']]['_id']);
        }   
        $_freebie = null;
        return $freebie;
    }
    
    public function sectionGifts() {
        $_gifts = Gifts::model()->getCollection()->find();
        $gifts = array();

        foreach($_gifts as $id=>$value) {
            if(!$value['enabled'])
                continue;
            if(!empty($value['items'])) {
                $items = array();
                $iorder = array();
                foreach($value['items']['m'] as $i=>$sID) {
                    $n = empty($value['items']['o'][$i])?0:$value['items']['o'][$i];
                    $items[$sID] = $value['items']['c'][$i];
                    $iorder[$sID] = $n;
                }
                $value['items'] = $items;
                $value['iorder'] = $iorder;
            }
            $this->retranslate('gifts:'.$value['_id'], $value);
            $gifts[$value['_id']] = $value;
            unset($gifts[$value['_id']]['_id']);
        }   
        $_gifts = null;
        return $gifts;
    }

    public function sectionAgifts() {
        $_gifts = Agifts::model()->getCollection()->find();
        $gifts = array();

        foreach($_gifts as $id=>$value) {
            $gifts[$value['_id']] = $value;
            unset($gifts[$value['_id']]['_id']);
        }
        $_gifts = null;
        return $gifts;
    }

    public function sectionBarter() {
        $_barters = Barter::model()->getCollection()->find();
        $barters = array();

        foreach($_barters as $id=>$value) {
            $barters[$value['ID']] = $value;
            unset($barters[$value['ID']]['_id']);
        }
        $_barters = null;
        return $barters;
    }

    public function sectionGameevents() {
        $_events = GameEvents::model()->getCollection()->find();
        $events = array();
		
		foreach($_events as $id=>$value) {
			unset($value['_id']);
            
            if(!empty($value['expire'])) {
                $_expire = [];
                foreach($value['expire']['n'] as $index => $net) {
                    $_expire[$net] = [
                        's' => strtotime( str_replace('.', '-', $value['expire']['s'][$index]) ),
                        'e' => strtotime( str_replace('.', '-', $value['expire']['e'][$index]) ),
                    ];
                }
                $value['expire'] = $_expire;
            }
            
			if(!empty($value['items'])) {
				$items = array();
				$iorder = array();
				foreach($value['items']['m'] as $i=>$sID) {
					$items[$sID] = [
                        'count' => $value['items']['count'][$i],
                        'x' => $value['items']['x'][$i],
                        'y' => $value['items']['y'][$i],
                        'scale' => $value['items']['scale'][$i],
                        'page' => $value['items']['page'][$i],
                    ];
					$iorder[$sID] = $i;
				}
				$value['items'] = $items;
				$value['iorder'] = $iorder;
			}			
			$events[$id] = $value;
		}
        
        $_events = null;
        return $events;
    }
    
    public function sectionBigsale() {
        $_bigsale = Bigsale::model()->getCollection()->find();
        $bigsale = array();
        
        foreach($_bigsale as $id => $value) {                
            if(!$value['enabled'])
                continue;
                
            if(!empty($value['items'])) {
                $items = array();
                foreach($value['items']['m'] as $i=>$sID) {
                    $items[] = array(
                        'sID'    =>$sID,
                        'pn'    =>$value['items']['pn'][$i],
                        'po'    =>$value['items']['po'][$i],
                        'c'        =>$value['items']['c'][$i],
                        'o'        =>$value['items']['o'][$i],
                        'b'        =>isset($value['items']['b'][$i])?$value['items']['b'][$i]:'',
                        'bc'    =>isset($value['items']['bc'][$i])?$value['items']['bc'][$i]:''
                    );
                }
                $value['items'] = $items;
            }
            
            $this->retranslate('bigsale:'.$value['_id'], $value);
                                    
            $bigsale[$value['_id']] = $value;
            unset($bigsale[$value['_id']]['_id']);
        }   
        $_bigsale = null;
        return $bigsale;
    }
    
    public function sectionCrafting() {
        //ПРОИЗВОДСТВО МАТЕРИАЛОВ В ЗДАНИЯХ
        $_crafting = Crafting::model()->getCollection()->find();
        $crafting = array();

        foreach($_crafting as $id=>$value) {
            unset($value['_id']);
            if((int)$value['enabled'] == 1) {
                $crafting[$value['ID']] = $value;
            }
        }   
        return $crafting;
    }
    
    public function sectionFarming() {
        $_farming = Farm::model()->getCollection()->find();
        $farming = array();
        
        foreach($_farming as $id=>$value) {
            unset($value['_id']);
            $farming[$value['ID']] = $value;
        }   
        $_farming = null;
        return $farming; 
    }
    
    public function sectionPersonages() {
        $_personages = Personages::model()->getCollection()->find();
        $personages = array();

        foreach($_personages as $id=>$value) {
            unset($value['_id']);
            $this->retranslate('personages:'.$value['ID'], $value);
            $personages[$value['ID']] = $value;
        }
        $_personages = null;
        return $personages;
    }
	
	public function sectionPaygroups() {
		// ПЛАТЕЖНЫЕ ГРУППЫ
        return 1;
    }
    
    public function sectionBestsellers() {
        //БЕСТСЕЛЛЕРС
        $bestsellers = array();
        $criteria = new EMongoCriteria();
        $criteria->addCond('items', 'exists', true);
        $_bestsellers = Bestsellers::model()->findAll($criteria);
        foreach($_bestsellers as $bserver) {
            $bestsellers[$bserver['_id']] = $bserver['items'];   
        }  
        $_bestsellers = null;
        return $bestsellers;
    }
    
    public function sectionLevels() {
        //УРОВНИ
        $levels = array();       
        $_levels = Levels::model()->getCollection()->find()->sort(array('ID'=>1));
            foreach($_levels as $id=>$level) {
                unset($level['_id']);
                $ID = $level['ID'];
                unset($level['ID']); 
                $levels['DM'][$ID] = $level;                      
            }  
            $_levels = null; 
        return $levels;
    }
    
    public function sectionCalendar() {
        $_calendar = Calendar::model()->getCollection()->find();
        $calendar = array();
        
        foreach($_calendar as $id=>$value) {
                
            if(!empty($value['items'])) {
                $items = array();
                if(!empty($value['items']['dm'])) {
                    foreach($value['items']['dm'] as $i=>$sID) {                        
                        $items[$i + 1] = array($sID => $value['items']['dc'][$i]);
                    }
                    $value['items'] = $items;
                }  
            }

            $this->retranslate('calendar:'.$value['_id'],$value);

            $calendar[$value['_id']] = $value;
            unset($calendar[$value['_id']]['_id']);
        } 
        $_calendar = null;
        return $calendar;
    }
    
    public function sectionTreasures() {
        //КЛАДЫ
        $_treasures = Treasures::model()->getCollection()->find();
        $treasures = array();

        foreach($_treasures as $id=>$value) {
            unset($value['_id']);
            $ID = $value['ID'];
            unset($value['ID']);

            $value['objects']['items'] = empty($value['items'])?0:$value['items'];
            $value['objects']['random'] = empty($value['random'])?0:$value['random'];
            $value['objects']['rcount'] = empty($value['rcount'])?0:$value['rcount'];
            $value['objects']['mcount'] = empty($value['mcount'])?0:$value['mcount'];

            if(!empty($value['randomMaterial'])) {
                $value['objects']['randomMaterial'] = $value['randomMaterial'];
                $this->mc($value['objects']);
            }
            $treasures[$ID][$value['view']] = $value['objects'];     
        }     
        $_treasures = null;
        return $treasures;
    } 
    
    public function sectionCollectionIndex($data, $val) {
        $objects = Storage::getObjects();
        $treIndex = array();
        
        foreach($data['treasures'] as $ID=>$treasure) {
            foreach($treasure as $view=>$list) {
                if(!isset($list['item'])) continue;
                foreach($list['item'] as $sID) {
                    if(!empty($objects[$sID]) && isset($objects[$sID]['object']['type']) && $objects[$sID]['object']['type'] == 'Collection') {
                        if(empty($treIndex[$ID]))
                            $treIndex[$ID] = array();
                        $treIndex[$ID][] = $sID;
                    }   
                }                        
            }
        }
        $collectionIndex = array();
        foreach($objects as $sID=>$item) {
            if(!empty($item['object']['treasure']) && isset($treIndex[$item['object']['treasure']])) {
                
                foreach($treIndex[$item['object']['treasure']] as $cID) {
                    if(empty($collectionIndex[$cID])) {
                        $collectionIndex[$cID] = array();
                    }
                    $collectionIndex[$cID][$sID] = $sID;
                }
            }
            
            if(!empty($item['object']['shake']) && isset($treIndex[$item['object']['shake']])) {
                
                foreach($treIndex[$item['object']['shake']] as $cID) {
                    if(empty($collectionIndex[$cID])) {
                        $collectionIndex[$cID] = array();
                    }
                    $collectionIndex[$cID][$sID] = $sID;
                }
            }
                
        }
        
        

        return $collectionIndex;   
    }
    
    public function sectionBonus() {
        //Бонусы
        $_bonus = Bonus::model()->getCollection()->find();
        $bonus = array();

        foreach($_bonus as $id=>$value) {
            $this->mc($value);

            switch($value['type']) {
                case 'MPayment':
                    $socials = [];
                    foreach($value['socials'] as $info) {
                        $_social = $info['social'];
                        unset($info['social']);
                        $socials[$_social] = $info;    
                    }
                    $value['socials'] = $socials;
                    break;
				case 'MGift':
					// Expire
					if(!empty($value['expire'])) {
						foreach($value['expire'] as $social => & $time)
							$time = strtotime(str_replace('.', '/', $time));
					}

					// uids
					if(!empty($value['uids'])) {
						$value['uids'] = explode("\r\n", $value['uids']);

						// Сохранение uID как ключи массива
						$uids = [];
						foreach ($value['uids'] as $uID)
							$uids[$uID] = 1;
						$value['uids'] = $uids;
					}

					break;
            }

            $bonus[$id] = $value;   
        }
        
        $_bonus = null;
        return $bonus;
    }
    
    public function sectionLacks() {
        //Бонусы отсутствия в игре
        $lacks = [];
        $lacksCursor = Bonus::model()->getDb()->lacks->find()->sort(['day' => -1]);

        foreach ($lacksCursor as $lack) {
            if (empty($lack['enabled']))
                continue;

            if (isset($lack['social']['p'])) {
                foreach ($lack['social']['p'] as $social) {
                    if (!isset($lacks[$social]))
                        $lacks[$social] = [];

                    $lacks[$social][$lack['day']] = [
                        'items' => array_combine($lack['items']['m'], $lack['items']['c']),
                        'notify' => $lack['notify']
                    ];
                }
            }
        }

        return $lacks;
    }

    public function sectionAward() {
        //Бонусы от 6waves
        $_bonus = Award::model()->getCollection()->find();
        $bonus = array();
        
        foreach($_bonus as $id => $value) {
            unset($value['_id']);
            $this->retranslate('award:'.$id, $value);
            $bonus[$id] = $value;   
             
        }
        $this->mc($bonus);
        $_bonus = null;
        return $bonus;
    }
    
    public function sectionDaylibonus() {
        //Ежедневный бонус
        $_bonus = Daylibonus::model()->getCollection()->find()->sort(array('day'=>1));
        $daylibonus = array();
        
        foreach($_bonus as $id => $value) {
            $this->mc($value);
            
            /*if(!empty($value['bonus'])) {
                $items = array();
                foreach($value['bonus']['m'] as $i=>$sID) {
                    $items[$sID] = $value['bonus']['c'][$i];
                }
                $value['bonus'] = $items;
            } */ 
            unset($value['_id']);
            //$this->retranslate('daylibonus:'., $value);
            $daylibonus[] = $value;            
        } 
        $_bonus = null;
        return $daylibonus;
    }

    public function sectionWakeupbonus() {
        //Бонус "Разбуди друга"
        $_bonus = Wakeupbonus::model()->getCollection()->find();
        $wakeupbonus = [];
        
        foreach($_bonus as $id => $value) {
            unset($value['_id']);
            $this->mc($value);

            $wakeupbonus[] = $value;            
        }

        $_bonus = null;
        return $wakeupbonus;
    }

    public function sectionBanlist() {
        //БАНЛИСТ
        $_banlist = Banlist::model()->getCollection()->find();
        $banlist = array();
        
        foreach($_banlist as $id=>$value)                    
            $banlist[$value['uid']] = $value;
            
        $_banlist = null;
        return $banlist;
    }    
    
    public function sectionUexception() {
        $mongo = new MongoClient("mongodb://5.9.90.73:27017");
        $db = $mongo->dreams;
        $_list = $db->user_exception->find();

        $users = [];
        foreach($_list as $user) {
            $users[$user['social']][$user['uid']] = 1;   
        }

        return $users;
    }
    
    public function sectionConfig() {
        //НАСТРОЙКИ ЮЗЕРА
        $configModel = new Config;
        $config = Config::model()->getCollection()->find();
        $config = iterator_to_array($config);
        
        $config = current($config);
        unset($config['_id']);
        
        if(!empty($config['materials'])) {
            $temp = $config['materials'];
            $config['materials'] = array();
            foreach($temp['i'] as $k=>$sID) {
                $config['materials'][$sID] = $temp['c'][$k];
            }
        }

        return $config;  
    }
	
	public function sectionCoeff() {
        //Коэффициенты цен
        $coeffsDb = Coeff::model()->getCollection()->find();
		$priceRatioDb = Options::model()->getCollection()->findOne(['name' => 'priceRatio'], ['_id' => 0, 'value' => 1]);
		$priceRatio = $priceRatioDb['value'];

		$coeffs = ['priceRatio' => $priceRatio, 'coeffs' => []];
		foreach ($coeffsDb as $id => $coeff)
			$coeffs['coeffs'][$coeff['social']] = round($coeff['coeff'], 2);

        return $coeffs;
    }
    
    public function sectionOptions() {
        //Опции
        $_options = Options::model()->getCollection()->find()->sort(array('name'=>1));
        $options = array();
        
        foreach($_options as $id=>$option)
           $options[$option['name']]=$option['value'];
        
        $_options = null;
        return $options;
    }
    
    public function sectionNews() {
        $_news = News::model()->getCollection()->find();
        $news = array();

        foreach($_news as $id=>$value) {
                                
            if(!$value['enabled'])
                continue;
                
            if(!empty($value['items'])) {
                $items = array();
                foreach($value['items'] as $i=>$sID) {
                    $items[$sID] = $sID;
                }
                $value['items'] = $items;
            }
            $this->retranslate('news:'.$value['_id'], $value);
            $news[$value['_id']] = $value;
            unset($news[$value['_id']]['_id']);
        }  
        $_news = null;
        return $news;
    }
    
    public function sectionInform() {
        $_inform = Inform::model()->getCollection()->find();
        $inform = array();
        
        foreach($_inform as $id=>$value) {
                                
            if(!$value['enabled'])
                continue;
                
            $this->retranslate('inform:'.$value['_id'], $value);
            $inform[$value['_id']] = $value;
            unset($inform[$value['_id']]['_id']);
        }  
        $_inform = null;
        return $inform; 
    }
    
    public function sectionAdvers() {
        $advers = array();
        $_advers = Adverlist::model()->getCollection()->find(array(), array('_id' => 0));       
        foreach($_advers as $adver) {
            $social = $adver['social'];
            unset($adver['social']);
            if(!isset($advers[$social])) 
                $advers[$social] = array();    
            $advers[$social][$adver['ID']] = $adver;    
        }           
        $_advers = null; 
        return $advers;
    }
    
    public function sectionBulks() {
      //АКЦИИ
        $_bulks = Bulks::model()->getCollection()->find();
        $bulks = array();
        
        foreach($_bulks as $id=>$value) {
                                
            if(!$value['enabled'])
                continue;
            
            if(isset($value['comment']))
                unset($value['comment']);
                
            if(!empty($value['social'])) {
                $social = array();
                foreach($value['social'] as $sID) {
                    $social[$sID] = $sID;
                }
                $value['social'] = $social;
            }    
                
            if(!empty($value['items'])) {
                $iorder = array();
                $n=0;
                foreach($value['items'] as $i=>$sID) {
                    $iorder[$sID] = $n;
                    $n++;
                }
                $value['iorder'] = $iorder;
            }
            
            $bulks[$value['_id']] = $value;
            unset($bulks[$value['_id']]['_id']);
        }
        
        $_bulks = null;
        return $bulks;        
    }
    
    public function sectionBulkset() {
        $_bulkset = Bulkset::model()->getCollection()->find();
        $bulkset = array();
        foreach($_bulkset as $id=>$value) {
                                
            if(!empty($value['items'])) {
                $items = array();
                $iorder = array();
                $n=0;
                foreach($value['items']['m'] as $i=>$sID) {
                    $items[$sID] = $value['items']['c'][$i];
                    $iorder[$sID] = $n;
                    $n++;
                }
                $value['items'] = $items;
                $value['iorder'] = $iorder;
            }
            
            $bulkset[$value['_id']] = $value;
            unset($bulkset[$value['_id']]['_id']);
        }
        $_bulkset = null;
        return $bulkset;
    }
    
    public function sectionControllers() {
        $controllers = array();
        $apps = Users::model()->getDb()->app->find();
        foreach($apps as $app)
            $controllers[$app['ID']] = $app;     
        $apps = null;
        return $controllers;   
    }
    
    public function sectionBlinks() {
        $blinks = array();
        $_blinks = Blinks::model()->getCollection()->find(array(), array('url' => 0, '_id' => 0));

       foreach($_blinks as $blink) {
            ////expire 
            $_end = (int)$blink['start'] + (int)$blink['duration']*60*60;
            
            if($_end < time()) {
                continue;
            }

            $social = $blink['social'];
            unset($blink['social']);
            if(!isset($blinks[$social])) 
                $blinks[$social] = array();  

            if(!empty($blink['bonus'])) {
                $bonus = array();
                foreach($blink['bonus']['m'] as $i=>$sID) {
                    $bonus[(int)$sID] = (int)$blink['bonus']['c'][$i];
                }
                $blink['bonus'] = $bonus;
            }

			if(!empty($blink['duration']))
				$blink['duration'] = (int)$blink['duration'];

			if(!empty($blink['group'])) {
				$group = [];
				foreach ($blink['group'] as $groupID)
					$group[] = (string)$groupID;
				$blink['group'] = $group;
			}

            $blinks[$social][$blink['ID']] = $blink;    
        }          
        $_blinks = null;

        return $blinks;
    }
    
    ////////////////////////////////////locale
    private function getLocale() {
        $ru = ELocale::loadOModel('ru');
        /*$ru = array();
        $file = Yii::app()->basePath . '/../locale/ru.csv';

        if (($handle = fopen($file, "r")) !== FALSE) {
            while (($fields = fgetcsv($handle, 10000, ",")) !== FALSE) {
                $ru[$fields[0]] = 1;
            }
            fclose($handle);
        }else{
            throw new CHttpException(404,'The requested page does not exist.');
        }       */
        return $ru;        
    }
    
    private function retranslate($key, &$obj) {
        if($this->getId() == 'locale') return;
        if(is_array($obj)) {
            foreach($obj as $k=>&$v) {
                $this->retranslate($key.":".$k, $v);
            }            
        } else {
            if(isset($this->_locale[$key]))
                $obj = $key;                           
        }       
    }

    ////////////////////////additions function before send
    private function checkRatio($rlist, $obj_level) {
        $obj_level = (int)$obj_level;
        foreach($rlist as $diff) {
            $ratio = explode(':', $diff);
            $levels = explode('-', $ratio[0]);
            if($obj_level >= (int)$levels[0] && $obj_level <= (int)$levels[1]) {
                return round($obj_level*(float)$ratio[1]);
            }                      
        }
        return (int)$obj_level;      
    }
    
    
    private function typeAhappy($storage, &$object, $social) {     
        foreach($object['items'] as $index => $sid) {
            if(empty($storage[$sid])) {
                unset($object['items'][$index]);
                continue;
            }
            if(!empty($storage[$sid]['sdeny'])) {
                if(in_array($social, $storage[$sid]['sdeny'])) {
                    unset($object['items'][$index]);
                    continue;  
                }  
            }
        }
    }
    
    /*private function additionCrafting($data, $social) {
        $result = [];
        foreach($data['crafting'] as $cid => $crafting) { 
            if(!empty($crafting['items'])) {
                if(!$this->excludeItem($crafting['out'], $social)) {
                    $result[$cid] = $crafting;
                } else continue;
                ///////////////////////////
                foreach($crafting['items'] as $sid => $count) {
                    if($this->excludeItem($sid, $social)) {
                        unset($result[$cid]);
                        break;        
                    }
                }
            }
        }   
        return $result;
    }*/
    
    private function additionStorage($data, $social) {
        $config = Yii::app()->params['social'][$social];   
        $group = array();           
        
        foreach($data['storage'] as $sid => $object) {  
            if(empty($object['type'])) {
                continue;
            }    
            
            if(in_array($object['type'], ['Collection', 'Annex'])) {
                if($this->excludeItem($sid, $social)) {
                    continue;   
                }  
            }  

            if(isset($config['ratio']) && $object['type'] != 'Zones') {
                $rlist = explode(',', $config['ratio']);
                /////////////////////// levels
                if(isset($object['level']))
                    $object['level'] = $this->checkRatio($rlist, $object['level']);
                /////////////////////// unlock     
                if(isset($object['unlock']) && isset($object['unlock']['level']))
                    $object['unlock']['level'] = $this->checkRatio($rlist, $object['unlock']['level']);  
            }  
            //////////deny
            if(!empty($object['sdeny'])) {
                if(in_array($social, $object['sdeny'])) {
                    continue;
                }
            }
            
            ///////////////////////////////group
            $type = $object['type'];

            $_func = "type{$type}";
            if(method_exists($this, $_func)) {
                $this->{$_func}($data['storage'], $object, $social);
            }
            
            if(!isset($group[$type]))
                $group[$type] = array();
            $group[$type][$sid] = $object;                                         
        }
        
        return $group;
    }

    private function additionActions($data, $social) {
        foreach ($data['actions'] as $aID => $action) {
            if (empty($action['price'][$social]) && empty($action['mprice'][$social]))
                unset($data['actions'][$aID]);
        }
        return $data['actions'];
    }

    private function additionLevels($data, $social) {
        if(isset($data['levels'][$social]))
            return $data['levels'][$social];
        /*if(empty($data['levels']['DM'])) {
            return 
        }  */
        return $data['levels']['DM'];
    } 

	private function additionPaygroups($data, $social) {
		// ПЛАТЕЖНЫЕ ГРУППЫ
		$paygroupsDB = Paygroups::model()->getCollection()->findOne(['social' => $social]);
		$ranges = [];

		foreach ($paygroupsDB['ranges'] as $rID => &$range) {
			$range['r1'] = round($range['r1'], 1);
			$range['r2'] = round($range['r2'], 1);
		}

		return $paygroupsDB['ranges'];
	}

    private function additionBestsellers($data, $social) {
        if(isset($data['bestsellers'][$social]))
            return $data['bestsellers'][$social];
        return array();
    }

	private function additionAuctions($data, $social) {
        foreach ($data['auctions'] as $sid => &$object) {
            if (!empty($object['expire'])) {
                if (!empty($object['expire'][$social])) {
                    $object['expire'] = $object['expire'][$social];
                } else {
                    unset($data['auctions'][$sid]);
                }
            }
        }

        return $data['auctions'];
    }
	
	private function additionLots($data, $social) {
        foreach ($data['lots'] as $sid => &$object) {
            if (!empty($object['expire'])) {
                if (!empty($object['expire'][$social])) {
                    $object['expire'] = $object['expire'][$social];
                } else {
                    unset($data['lots'][$sid]);
                }
            }
        }

        return $data['lots'];
    }

    private function additionAdvers($data, $social) {
        if(isset($data['advers'][$social])) 
            return $data['advers'][$social];        
        return array();
    }

    private function additionSatellite($data, $social) {
        if(isset($data['satellite'][$social]))
            return $data['satellite'][$social];
        return array();
    }

    private function additionBanner($data, $social) {
        if(isset($data['banner'][$social]))
            return $data['banner'][$social];
        return array();
    }

    private function additionBlinks($data, $social) {
        if(isset($data['blinks'][$social])) 
            return $data['blinks'][$social];        
        return array();
    } 

    private function additionLacks($data, $social) {
        if(isset($data['lacks'][$social])) 
            return $data['lacks'][$social];
        return array();
    }

    private function additionGameevents($data, $social) {
        $result = [];
        foreach($data['gameevents'] as $id => $event) {
            if(empty($event['expire'][$social])) {
                continue;
            }
            $event['expire'] = $event['expire'][$social];
            $result[$id] = $event;
        }
        return $result;
    } 
    
    private function additionStones($data, $social) {
        if(isset($data['stones'][$social])) 
            return $data['stones'][$social];
        return array();
    } 
    
    private function additionQuests($data, $social) {
        $_quests = $data['quests']['DM'];
 
        $result = [];
        if($social != 'DM' && isset($data['quests'][$social])) {
            
            $quests = array();
            $chapters = array();
            foreach($data['quests'][$social] as $qid => $quest) {
                $_quests[$qid] = $quest;
                $chapters[$quest['chapter']] = true;
            }
             
            foreach($_quests as $qid => $quest) {
                if($quest['social'] == 'DM' && isset($chapters[$quest['chapter']])) {
                    continue;
                }             
                $quests[$qid] = $quest;   
            }  
            
            $result = $quests; 
            
        } else $result = $_quests;

        foreach($result as $qid => $info) {
            if(!empty($info['parent'])) {
                $parent = $info['parent'];
                if(!empty($result[$parent])) {
                    $result[$parent]['childs'][] = $qid;    
                }
            }
        }
        
        return $result;
    } 
    
    private function additionQuestsIndex($data, $social) {    
        $index = array();
        foreach($data['quests'] as $ID=>$quest) {
            if(!empty($quest['missions'])) {
                foreach($quest['missions'] as $mission) {
                    $mcontr = $mission['controller'];
                    if(!isset($index[$mcontr])) {
                        $index[$mcontr] = array($mission['event']=>array($ID=>$ID));
                    } else $index[$mcontr][$mission['event']][$ID] = $ID;
                }
            }
        }  
        return $index;     
    }
    
    private function additionAchIndex($data, $social) {    
        $index = array();
        foreach($data['ach'] as $ID=>$quest) {
            if(!empty($quest['missions'])) {
                foreach($quest['missions'] as $mission) {
                    $mcontr = $mission['controller'];
                    if(!isset($index[$mcontr])) {
                        $index[$mcontr] = array($mission['event']=>array($ID=>$ID));
                    } else $index[$mcontr][$mission['event']][$ID] = $ID;
                }
            }
        }
        return $index;     
    }
    
    private function additionTrades($data, $social) {      
        if(!isset($data['updates']))
            $updates = $this->sectionUpdates(); else $updates = $data['updates'];
        $items = array();
        $stay = array();
        foreach($updates as $id=>$update) {
            if(!isset($update['items'])) continue;
            foreach($update['items'] as $sid=>$order) {   
                $sid = (int)$sid;  
                if(!isset($items[$sid]))
                    $items[$sid] = array();
                foreach($update['social'] as $net)
                    $items[$sid][$net] = 1;    
            }
            if(isset($update['stay']) && count($update['stay']) > 0) {
                foreach($update['stay'] as $sid=>$order) {
                    $sid = (int)$sid; 
                    if(!isset($stay[$sid]))
                        $stay[$sid] = array();   
                    foreach($update['social'] as $net)
                        $stay[$sid][$net] = 1;  
                }
            }
        }
        $trades = array();
        foreach($this->trades as $id=>$trade) {        
            if(!isset($trade['items']) || count($trade['items']) == 0) continue;
            $trades[$id] = $trade; 
            foreach($trade['items'] as $sid=>$count) {
                if(isset($stay[$sid][$social]))
                    continue;     
                if(isset($items[$sid]) && !isset($items[$sid][$social]))
                    unset($trades[$id]);
            }
        }
        return $trades;
    } 
    
    private function additionTreasures($data, $social) {
        $result = array();

        foreach($data['treasures'] as $id=>$views) {
            $result[$id] = $views;
            foreach($views as $view => $item) {
                if(!isset($item['item'])) continue;
                
                foreach($item['item'] as $i => $sid) {
                    $sid = (int)$sid;
                    if($this->excludeItem($sid, $social)) {
                        unset($result[$id][$view]['item'][$i]);
                        unset($result[$id][$view]['count'][$i]);
                        unset($result[$id][$view]['probability'][$i]);
                        unset($result[$id][$view]['try'][$i]); 
                    }
                }    
            }
        }

        return $result;     
    }

    private function additionTop($data,$social) {
        $result = [];
        foreach($data['top'] as $id => $top) {
            $_socials = array_keys($top['expire']);
            if(in_array($social, $_socials)) {
                unset($top['socials']);
                $top['expire'] = $top['expire'][$social];
                $result[$id] = $top;
            }
        }

        return $result;
    }    
    
    private function additionUexception($data, $social) {
		// MM to ML
		if ($social == 'MM') {
			$social = 'ML';
		}

        if(!empty($data['uexception'][$social])) {
            $result = [];
            foreach($data['uexception'][$social] as $uid => $_) {
                $result[] = '_' . $uid;
            }
            return $result;
        } else return [];
    }
    
    private $_uitems = null;
    private function excludeItem($sid, $social) {
        ////////////////// load update items
        if(empty($this->_uitems)) {
            $this->_uitems = ['items' => [], 'stay' => []];
            $list = Update::model()->getCollection()->find();
            //Update[items][17]
            foreach($list as $update) {
                if(!empty($update['items']))
                    foreach($update['items'] as $_sid)
                        $this->_uitems['items'][$_sid] = $update['social'];              
                if(!empty($update['stay']))
                    foreach($update['stay'] as $_sid)
                        $this->_uitems['stay'][$_sid] = $update['ext']; 
            }
        }
        //////////////////////  
        if(!empty($this->_uitems['stay'][$sid])) {
            if(in_array($social, $this->_uitems['stay'][$sid])) {
                return false;   
            }
        }
        
        if(!empty($this->_uitems['items'][$sid])) {
            if(!in_array($social, $this->_uitems['items'][$sid])) {
                return true;    
            }    
        }
        return false;
    }
    
    ///////////////////////////////// function SAVE 
    public function actionSend() {
        
        $request = Yii::app()->request;
        $_sections = $request->getParam('section');
        $_servers = $request->getParam('server');
        $_filter = $request->getParam('storage');

        ///////////////////////////// get locale
        $this->_locale = $this->getLocale();
        $data = array();    
        /////////////////////////////// parse sections
        foreach($_sections as $_section => $val) {
            if(isset($data[$_section]))
                continue;

			$section = 'section' . ucfirst($_section);
            if(!method_exists($this, $section))
				throw new CHttpException(404, "method {$section} not exists.");

			$result = $this->{$section}($data, $val);
			if($result !== false)
				$data[$_section] = $this->{$section}($data, $val);
        }
        //////////////////////////// send data for each server
        $response = array();
        $sectionsText = implode(", ", array_keys($_sections));
        $text = array();
        foreach($_servers as $server) {
            $info = $data;
            $text[] = 'Сохранение на сервер с IP: '.$server.':<br />'.$sectionsText;    
            $social = Yii::app()->params->socials[$server];

			//////////////////////addition functions
            foreach($info as $key => &$value) {
                $method = 'addition' . ucfirst($key);
                if(method_exists($this, $method))
                    $value = $this->{$method}($info, $social);
            }

            //if(Yii::app()->user->name !== 'user123') {
                $json_data = json_encode($info);
                $response[$server] = $this->send2($json_data, $server);                   
            //} else $response[$server] = $this->localSend($info, $server);   
        }
        print json_encode($response);
        $time = 'save'.time();
        $this->log('save', '<a class="savetoggle" onclick="$(\'#'.$time.'\').toggle();"><b>Сохранение на сервер</b></a><div class="saveserver" style="display:none;" id="'.$time.'">'.implode('<br /><br />', $text).'</div>'); 
        Yii::app()->end();  
    }
        
    private function localSend($data, $IP) {
        $data = gzcompress(json_encode($data));                     
        $servers = array();        
 
        // URL on which we have to post data
        $url = "http://".$IP."/app/data/receiver3.php";
        
        $post_data['data'] = $data;
        $post_data['crc'] = md5('DE$%^&*U(I)OUFfdigr8y7(*&RDFGHJU(*&^%RFGB');
        $post_data['update'] = 1;

        $post_data['c'] = crc32($data);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_VERBOSE, 1);
        $response = curl_exec($ch);
        
        //$servers[$IP] = $response;
            
        return $response;
    
    }
       

    private function send2($data, $IP) {
                     
        $servers = array();        
 
        // URL on which we have to post data
        if(Yii::app()->user->name == 'user123') {
            $url = "http://".$IP."/app/data/receiver2.php";                        
        } else $url = "http://".$IP."/app/data/receiver2.php";

        $post_data['data'] = $data;
        $post_data['crc'] = md5('DE$%^&*U(I)OUFfdigr8y7(*&RDFGHJU(*&^%RFGB');
        $post_data['update'] = 1;

        $post_data['c'] = crc32($data);
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_VERBOSE, 1);
        $response = curl_exec($ch);
        
        //$servers[$IP] = $response;
            
        return $response;
    
    }
    
	private function send($data, $IP) {
		 			
		$servers = array(); 
					
		// URL on which we have to post data
        if(Yii::app()->user->name == 'user123') {
            $url = "http://".$IP."/app/data/receiver2.php";                        
        } else $url = "http://".$IP."/app/data/receiver2.php";

		// Any other field you might want to post	
		
		
		$post_data['data'] = $data;
		$post_data['crc'] = md5('DE$%^&*U(I)OUFfdigr8y7(*&RDFGHJU(*&^%RFGB');
		$post_data['update'] = 1;
		$post_data['c'] = crc32($data);

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_VERBOSE, 1);
		$response = curl_exec($ch);
		
		//$servers[$IP] = $response;
			
		return $response;
	
	}
	
}
