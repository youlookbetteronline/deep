<?php
 return array('name'=>_('Уникальный ходящий декор'),
					'section'=>_('Декорации'),
					'properties'=>array(
						['area'], 
						['level'],
                        ['currency','label'=>'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
						['price','label'=>'Цена покупки', 'field' => 'materials', 'm' => 'item', 'c' => 'count', 'sids' => [26,27]],
						['velocity', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Скорость'],
						['homeradius', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Радиус обитания'],
						['experience'],
						['shake'],
						['time'],
  						['lifetime'],
						['capacity'],
						['skip'],
						['base', 'label'=>'Основание'],
						['moveable', 'label' => 'Ходящий декор', 'field' => 'atype', 'act' => 'yesNot'],
  						['treasure'],
                        ['getmethod', 'label'=>'Способ получения'],
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