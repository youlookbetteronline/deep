<?php
 return array(
                'name'=>_('Уникальный декор'),
                'section'=>_('Декорации'),
                'properties'=>array(
                    ['area'], 
                    ['level'],
                    ['currency','label'=>'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
                    ['price','label'=>'Цена покупки', 'field' => 'materials', 'm' => 'item', 'c' => 'count', 'sids' => [26,27]],
                    ['experience'],
                    ['shake'],
  					['tostock', 'label' => 'Добавить на склад при покупке', 'ajax' => '_default-ajax', 'field' => 'slist-ajax'],
                    ['time'],
                    ['exclude', 'field' => 'choices'],
                    ['speedup', 'field' => 'order'],
                    ['base', 'label'=>'Основание'],
                    ['treasure'],
                    ['mboost','label'=>'Материал для ускорения', 'field' => 'storage','types' => array('Mboost')],
                    ['stopboost', 'label' => 'Не ускоряемый', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
					['getmethod', 'label'=>'Способ получения'],
                    ['lifetime'],
  					['capacity'],
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