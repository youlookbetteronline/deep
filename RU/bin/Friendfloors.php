<?php
	return array(
	    'name' => _('Бьем в башню друзей'),
	    'section' => _('Аукционки'),
	    'properties' => array(
	    	['fakefriends', 'label'=>'Друзья для покупки', 'field' => 'storage-ajax-list', 'ajax' => '_default-ajax'],
	    	['buttontext','label'=>'Текст кнопки','ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
	        ['area'],
			['base', 'label'=>'Основание'],

	        ['level'],
	        ['currency','label' => 'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
	        ['price','label' => 'Цена покупки', 'field' => 'materials', 'm' => 'item', 'c' => 'count', 'sids' => [26,27]],

	        ['skip'],
	        ['treasure'],

	        //['dostorage', 'label' => 'Выдает награду', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
	        //['makedecor', 'label' => 'Становиться декором', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
			['faction', 'label' => 'Действие на посл. уровне', 'field' => 'selectbox-ajax', 'ajax' => '_default-ajax', 'data' => [0 => 'Работает, как Decor', 1 => 'Работает, как Golden', 2 => 'Превращается в ...', 3 => 'Удаляется'], 'def' => 0],
	        ['emergent', 'label' => 'Превращается в', 'field' => 'storage-ajax', 'ajax' => '_default-ajax'],

			['time', 'label' => 'Время между сборами (as Golden)', 'ajax' => '_default-ajax', 'field' => 'seconds-ajax'],
			['lifetime', 'label' => 'Время жизни (as Golden)', 'ajax' => '_default-ajax', 'field' => 'seconds-ajax'],
			['capacity', 'label' => 'Емкость (as Golden)', 'ajax' => '_default-ajax', 'field' => 'textfield-ajax'],

			['levels',
				'ajax' => '_default-ajax',
				'field' => 'extend-ajax-list',
				'title' => 'Уровень №{ROOT:level}',
				'label' => 'Уровни',
				'start' => 1,
				'fields' => [
  					'throw' => [
	                    'ajax' => 'irequire2-ajax',
	                    'label' => 'Материалы для вкидывания',
	                    'fields' => [
                            'msimple' => [
                                'title' => 'Простые материалы', 'ajax' => 'mfields-ajax-list',
                                'fields' => [
                                    'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
                                    'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
                                    'k' => ['label' => 'Стуки', 'ajax' => 'textfield-ajax'],
                                    'b' => ['label' => 'Бонус', 'ajax' => 'treasure-ajax'],
                                ]
                            ],
                            'mdonate' => [
                                'title' => 'Донатные материалы', 'ajax' => 'mfields-ajax-list',
                                'fields' => [
                                    'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
                                    'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
                                    'k' => ['label' => 'Стуки', 'ajax' => 'textfield-ajax'],
                                    'b' => ['label' => 'Бонус', 'ajax' => 'treasure-ajax'],
                                ]
                            ]
  						]
  					],
	                'req' => [
	                    'ajax' => 'irequire2-ajax',
	                    'label' => 'Требования',
	                    'fields' => [
	                        'preview' => ['title' => 'Превью', 'ajax' => 'textfield-ajax'],
	                        'friends' => ['title' => 'Кол-во друзей', 'ajax' => 'textfield-ajax'],
	                        'kicks' => ['title' => 'Кол-во стуков', 'ajax' => 'textfield-ajax'],
	                    ],
	                ],
					'bonus' => ['label' => 'Бонус уровня', 'ajax' => 'treasure-ajax'],
	  			]
	  		],

			['cloudoffset','label'=>'Смещение иконки', 'field' => 'inline-ajax', 'ajax' => '_default-ajax',
				'fields' => [
				  'dx' => ['ajax' => 'textfield-ajax', 'title' => 'x'],
				  'dy' => ['ajax' => 'textfield-ajax', 'title' => 'y'],
				]
			],
	    )
	);
