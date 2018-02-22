<?php
 return array(
                'name' => _('Растения'),    
                'section' => _('Ресурсы'),
                'properties' => array(
                    ['area'], 
                    ['currency','label'=>'Альтернативная цена', 'field' => 'materials', 'm' => 'item', 'c' => 'count'],
                    ['price','label'=>'Цена покупки', 'field' => 'materials', 'm' => 'item', 'c' => 'count', 'sids' => [26,27]],
                    ['gcount', 'field' => 'textfield-ajax', 'ajax' => '_default-ajax', 'label' => 'Количество на карте'],
                    ['levels', 'field' => 'order'],
                    ['levelTime'],
                    ['outs','label'=>'Материалы дропа', 'field' => 'materials', 'm'=>'m','c'=>'c', 'cache'=>false],
                    ['level'],
                    ['treasure'],
                    ['skip'],
                    ['speedup', 'field' => 'order'],
                    ['require', 'field' => 'slist-ajax', 'ajax' => '_default-ajax', 'label' => 'Требуется для сбора'],
                    ['experience'],
                ));