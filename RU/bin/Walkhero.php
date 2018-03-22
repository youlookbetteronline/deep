<?php
	return array(
	    'name' => _('Walkhero'),
	    'section' => _('Декоры'),
	    'properties' => array(
	    	['buttontext','label'=>'Текст кнопки','ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
	    	['desctext','label'=>'Текст описания','ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
	        ['area'],
	        ['level'],
	        ['startlevel','label'=>'Начальний уровень','ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
	        ['currency','label' => 'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
	        ['price','label' => 'Цена покупки', 'field' => 'materials', 'm' => 'item', 'c' => 'count', 'sids' => [26,27]],     
	        ['skip'],
	        ['speedup', 'field' => 'order'],
	        ['base', 'label'=>'Основание'],

			['levels',
				'ajax' => '_default-ajax',
				'field' => 'extend-ajax-list',
				'title' => 'Уровень №{ROOT:level}',
				'label' => 'Уровни',
				'start' => 1,
				'fields' => [
  					'require' => [
	                    'ajax' => 'slist-ajax',
	                    'label' => 'Материалы',
  					],
	                'options' => [
	                    'ajax' => 'irequire2-ajax',
	                    'label' => 'Опции',
	                    'fields' => [
	                        'preview' => ['title' => 'Превью', 'ajax' => 'textfield-ajax'],
	                    ],
	                ],
					'bonus' => ['label' => 'Бонус за достижение уровня', 'ajax' => 'treasure-ajax'],
	  			]
	  		],

			['treasure'],
	  		['time', 'field' => 'seconds-ajax', 'ajax' => '_default-ajax', 'label' => 'Интервал сбора'],
	  		['lifetime', 'field' => 'seconds-ajax', 'ajax' => '_default-ajax', 'label' => 'Время жизни'],
	  		['downgrade', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Сбрасывать до уровня'],
	  		['downgradetext','label'=>'Текст сбрасывания','ajax' => '_default-ajax', 'field' => 'textfield-ajax'],	
	  		['velocity', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Скорость'],
	  		['homeradius', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Радиус обитания'],
	  		['gcount', 'field' => 'order', 'label' => 'Ограничение по кол-ву'],
	  		['cloudoffset','label'=>'Смещение иконки', 'field' => 'inline-ajax', 'ajax' => '_default-ajax',
				'fields' => [
				  'dx' => ['ajax' => 'textfield-ajax', 'title' => 'x'],
				  'dy' => ['ajax' => 'textfield-ajax', 'title' => 'y'],
				]
			],
			['stopfind', 'label' => 'Не участвует в поиске', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
	    )
	);