<?php
	return array(
	    'name' => _('Крафтовые этажи'),
	    'section' => _('Аукционки'),
	    'properties' => array(
	        ['area'],
	        ['level'],
	        ['price','label' => 'Цена покупки', 'field' => 'materials', 'm' => 'item', 'c' => 'count', 'sids' => [26,27]],     
	        ['base', 'label'=>'Основание'],
	        ['gcount', 'field' => 'order', 'label' => 'Ограничение по кол-ву'],
			['cloudoffset','label'=>'Смещение иконки', 'field' => 'inline-ajax', 'ajax' => '_default-ajax',
				'fields' => [
				  'dx' => ['ajax' => 'textfield-ajax', 'title' => 'x'],
				  'dy' => ['ajax' => 'textfield-ajax', 'title' => 'y'],
				]
			],
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
                            'mhard' => [
                                'title' => 'Сложные материалы', 'ajax' => 'mfields-ajax-list',
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
                            ],
  						]
  					],
  					'option' => [
  						'ajax' => 'irequire2-ajax',
	                    'label' => 'Опции',
	                    'fields' => [
	                        'craft' => [
	                            'ajax' => 'crafting-ajax-list',
	                            'title' => 'Формулы',
	                        ],
	                        'preview' => ['title' => 'Превью', 'ajax' => 'textfield-ajax'],
	                    ],
  					],
	                'req' => [
	                    'ajax' => 'irequire2-ajax',
	                    'label' => 'Требования',
	                    'fields' => [
	                        'kicks' => ['title' => 'Кол-во стуков', 'ajax' => 'textfield-ajax'],
	                    ],
	                ],
					'bonus' => ['label' => 'Бонус уровня', 'ajax' => 'treasure-ajax'],
	  			]
	  		],
	  		['slots',
				'label' => 'Слоты',
				'field' => 'extend-ajax-list',
				'ajax' => '_default-ajax',
				'title' => 'Слот "{ROOT:level}"',
				'start' => 0,
				'fields' => [
					'opened' => ['label' => 'Открытый по умолчанию?', 'ajax' => 'checkbox-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
					'price' => ['label'=>'Цена открытия', 'ajax' => 'slist-ajax'],
				],
			],
			['boostops', 'label'=>'Настройки ускорения', 'field' => 'mfields-ajax', 'ajax' => '_default-ajax',
				'fields' => [
				  's' => ['ajax' => 'storage-ajax', 'label' => 'Материал'],
				  'c' => ['ajax' => 'textfield-ajax', 'label' => 'Кол-во'],
				  'i' => ['ajax' => 'seconds-ajax', 'label' => 'Интервал времени']
				]
			],
	    )
	);
