<?php
 return array(
                'name'=>_('Денежный дом'),    
                'section'=>_('Постройки'),
                'properties'=>array(
                    ['area'],
                    ['currency','label'=>'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
  					['start', 'field' => 'order'],
                    ['instance',
                        'label' => 'Экземпляры',
                        'ajax' => '_default-ajax',
                        'field' => 'extend-ajax-list',
                        'title' => 'Экземпляр №{ROOT:level}',
                        'start' => 1,
                        'fields' => [
                            'cost' => [
                                'ajax' => 'slist-ajax',
                                'label' => 'Материалы',
                            ],
                            'req' => [
                                'ajax' => 'irequire2-ajax',
                                'label' => 'Требования',
                                'fields' => [
                                    "level" =>  ['ajax' => 'textfield-ajax', 'title' => "Уровень"],
                                    "p" =>  ['ajax' => 'textfield-ajax', 'title' => "Цена пропуска"],
                                    ],
                                ],
                            'devel' => [
                                'ajax' => 'extend-ajax-list',
                                'label' => 'Уровни',
                                'title' => 'Уровень №{ROOT:level}',
                                'start' => 1,
                                'fields' => [
                                    'obj' => [
                                        'ajax' => 'slist-ajax',
                                        'label' => 'Материалы'
                                    ],
                                    'req' => [
                                        'ajax' => 'irequire2-ajax',
                                        'label' => 'Опции',
                                        'fields' => [
                                            "v" =>  ['ajax' => 'textfield-ajax', 'title' => "Вид постройки"],
                                            "s" =>  ['ajax' => 'textfield-ajax', 'title' => "Стадия постройки"],
                                            "l" =>  ['ajax' => 'textfield-ajax', 'title' => "Уровень игрока"],
                                            "t" =>  ['ajax' => 'textfield-ajax', 'title' => "Время улучшения"],
                                            "f" =>  ['ajax' => 'textfield-ajax', 'title' => "Моментальный апгрейд"],
                                            "tm" =>  ['ajax' => 'textfield-ajax', 'title' => "Время добычи"],
                                        ],
                                    ],
                                    'rew' => [
                                        'ajax' => 'slist-ajax',
                                        'label' => 'Награда'
                                    ],
                            ],
                            ],
                        ],
                    ],
                    ['mboost','label'=>'Материал для ускорения', 'field' => 'storage','types' => array('Mboost')],
                    ['time','label'=>'Время прибыли'],
                    ['speedup', 'field' => 'order'],
                    ['base'],
                    ['treasure', 'ajax' => '_default-ajax', 'field' => 'treasure-ajax'],
					['getmethod', 'label'=>'Способ получения'],
  					['lifetime'],
  					['capacity'],
                    ['reset', 'label' => 'Сбрасывать?', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
                    ['resetlevel', 'label'=>'Сбрасывать до уровня:', 'ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
  					['gcount', 'field' => 'order', 'label' => 'Ограничение по кол-ву'],
  					['cloudoffset','label'=>'Смещение иконки', 'field' => 'inline-ajax', 'ajax' => '_default-ajax',
                       'fields' => [
                          'dx' => ['ajax' => 'textfield-ajax', 'title' => 'x'],
                          'dy' => ['ajax' => 'textfield-ajax', 'title' => 'y'],
                        ]
                    ],
                    ['stopfind', 'label' => 'Не участвует в поиске', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
					['usedefdescr', 'label' => 'Использовать стандартное описание', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')]
                ));