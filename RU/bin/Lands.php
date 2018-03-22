<?php
 return array(
                'name'=>_('Территории'),
                'section'=>_('Территории'),
                'properties'=>array(
                    ['started'],
                    //['open'],
                    ['require', 'label'=>'Требуется для открытия', 'field'=>'materials'],
                    ['items', 'label'=>'Переходник', 'field'=>'materials'],
                    ['charge', 'label'=>'Требуется для перехода', 'field'=>'materials'],
  					['lantern'],
                    ['level', 'label'=>'Открывается на уровне'],
  					['reqquest', 'label' => 'Необходимый квест для открытия', 'field' => 'quest-ajax', 'ajax' => '_default-ajax'],
  					['expire', 'label'=>'Открыта до', 'field' => 'tprice'],
  					['visibleitems', 'label' => 'Доступны материалы после обн-ия', 'field' => 'checkbox-ajax', 'ajax' => '_default-ajax', 'yes' => _('Да'), 'no' => _('Нет')],
  					['start', 'label'=>'Открыта от', 'field' => 'tprice'],
  					['duration', 'label' => 'Длительность (ч)', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax'],
                    ['fuel', 'label' => 'Топливо для батискафа', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax'],
  					['available', 'label' => 'Периоды доступности карты (респауны)', 'field' => 'inline-ajax-list', 'ajax' => '_default-ajax',
                     	'fields' => [
  							'day' 	 => ['ajax' => 'textfield-ajax', 'title' => 'День месяца'],
  							'hstart' => ['ajax' => 'textfield-ajax', 'title' => 'С (ч)'],
  							'hend'	 => ['ajax' => 'textfield-ajax', 'title' => 'По (ч)'],
  						]
                    ],
                    ['size', 'field'=>'atype', 'act'=>'getLandSize', 'label'=>'Размер локации'],
					['techno', 'field'=>'mlist', 'types' => ['Techno']],
  					['pet', 'field' => 'storage-ajax', 'ajax' => '_default-ajax'],
					['cookie', 'field'=>'mlist', 'types' => ['Material']],
                    ['shop'],
                    ['treasure'],
  					['maptype', 'label' => 'Тип карты', 'field' => 'selectbox-ajax', 'ajax' => '_default-ajax', 'data' => [0 => 'Обычная', 1 => 'Случайная', 2 => 'Публичная'], 'def' => 0],
  					['randomvars', 'label' => 'Варианты случайной карты', 'field' => 'textfield-ajax-list', 'ajax' => '_default-ajax' /*, 'size' => '45%'*/],
                ));