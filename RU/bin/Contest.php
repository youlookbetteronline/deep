<?php
 return array('name'=>_('Соревнование'),
            'section'=>_('Персонажи'),
                'properties'=>array(
                	['area'],
                    ['currency', 'label'=>'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
                    ['price', 'label'=>'Цена покупки', 'field' => 'slist-ajax', 'ajax' => '_default-ajax'],
                    ['time', 'label'=>'Время сбора'],
 					['velocity', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Скорость'],
  					['homeradius', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Радиус обитания'],
                    ['skip'],
                    ['level'],
                    ['shake'],
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
                                              'title' => 'Простое вкидывание', 'ajax' => 'mfields-ajax-list',
                                              'fields' => [
                                                  'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
                                                  'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
                                                  'k' => ['label' => 'Стуки', 'ajax' => 'textfield-ajax'],
                                                  'b' => ['label' => 'Покупка', 'ajax' => 'selectbox-ajax', 'data' => Storage::getKickType()],
                                              ]
                                          ],
                                          'mcomplex' => [
                                              'title' => 'Сложное вкидывание', 'ajax' => 'mfields-ajax-list',
                                              'fields' => [
                                                  'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
                                                  'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
                                                  'k' => ['label' => 'Стуки', 'ajax' => 'textfield-ajax'],
                                                  'b' => ['label' => 'Покупка', 'ajax' => 'selectbox-ajax', 'data' => Storage::getKickType()],
                                              ]
                                          ],
                                          'mdonate' => [
                                              'title' => 'Донатное вкидывание', 'ajax' => 'mfields-ajax-list',
                                              'fields' => [
                                                  'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
                                                  'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
                                                  'k' => ['label' => 'Стуки', 'ajax' => 'textfield-ajax'],
                                                  'b' => ['label' => 'Покупка', 'ajax' => 'selectbox-ajax', 'data' => Storage::getKickType()],
                                              ]
                                          ]
                            ]
                          ],
                                'req' => [
                                    'ajax' => 'irequire2-ajax',
                                    'label' => 'Требования',
                                    'fields' => [
                                        'preview' => ['title' => 'Превью', 'ajax' => 'textfield-ajax'],
                                        'kicks' => ['title' => 'Кол-во стуков', 'ajax' => 'textfield-ajax'],
                                    ],
                                ],
                          'bonus' => ['label' => 'Бонус уровня', 'ajax' => 'treasure-ajax'],
                          'bonusupgrade' => ['label' => 'Бонус за переход', 'ajax' => 'treasure-ajax'],
                      ]
                    ],
                    ['btype'],
                    ['base'],
                    ['cloudoffset','label'=>'Смещение иконки', 'field' => 'inline-ajax', 'ajax' => '_default-ajax',
                       'fields' => [
                          'dx' => ['ajax' => 'textfield-ajax', 'title' => 'x'],
                          'dy' => ['ajax' => 'textfield-ajax', 'title' => 'y'],
                        ]
                    ],
                ));
