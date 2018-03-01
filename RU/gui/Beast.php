<?php
 return array('name'=>_('Домашний зверь'),
            'section'=>_('Персонажи'),
                'properties'=>array(
                	['beastname', 'label'=>'Имя животного', 'ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
                	['area'],
                    ['currency', 'label'=>'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
                    ['price', 'label'=>'Цена покупки', 'field' => 'slist-ajax', 'ajax' => '_default-ajax'],
                    ['renameprice','label'=>'Цена переименования', 'field' => 'slist-ajax', 'ajax' => '_default-ajax'],
                    ['time', 'label'=>'Время сбора'],
                    ['moveable', 'label' => 'Ходящий декор', 'field' => 'atype', 'act' => 'yesNot'],
                    ['etime', 'label'=>'Время жизни', 'ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
                    ['maxtime', 'label'=>'Максимальное время', 'ajax' => '_default-ajax', 'field' => 'textfield-ajax'],
 					['velocity', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Скорость'],
  					['homeradius', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Радиус обитания'],
                    ['skip'],
                    ['level'],
                    ['shake'],
  					['throwsimple', 'label' => 'Простое вкидывание', 'field' => 'mfields-ajax-list', 'ajax' => '_default-ajax', 'size' => '47%',
                     	'fields' => [
  							'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
  							'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
  							't' => ['label' => 'Время продолжения', 'ajax' => 'seconds-ajax'],
  							'b' => ['label' => 'Покупка', 'ajax' => 'selectbox-ajax', 'data' => Storage::getKickType()],
						]
                    ],
  					['throwcomplex', 'label' => 'Сложное вкидывание', 'field' => 'mfields-ajax-list', 'ajax' => '_default-ajax', 'size' => '47%',
                     	'fields' => [
  							'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
  							'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
  							't' => ['label' => 'Время продолжения', 'ajax' => 'seconds-ajax'],
  							'b' => ['label' => 'Покупка', 'ajax' => 'selectbox-ajax', 'data' => Storage::getKickType()],
						]
                    ],
  					['throwdonate', 'label' => 'Донатное вкидывание', 'field' => 'mfields-ajax-list', 'ajax' => '_default-ajax', 'size' => '47%',
                     	'fields' => [
  							'm' => ['label' => 'Материал', 'ajax' => 'storage-ajax'],
  							'c' => ['label' => 'Кол-во', 'ajax' => 'textfield-ajax'],
  							't' => ['label' => 'Время продолжения', 'ajax' => 'seconds-ajax'],
  							'b' => ['label' => 'Покупка', 'ajax' => 'selectbox-ajax', 'data' => Storage::getKickType()],
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