package utils 
{
	/**
	 * ...
	 * @author 
	 */
	public class LocaleHelper 
	{
		
		public function LocaleHelper() 
		{
			
		}
		
		public static function rewriteGoldenDescription(unitData:*):void
		{
			//if (unitData.hasOwnProperty('reset') && unitData.reset == 1)
				//return;
			if ((unitData.hasOwnProperty('reset') && unitData.reset == 1) || (unitData && unitData.ID && unitData.ID == 2587))
				return;
			if (unitData.ID == 2541)
				trace();
			if (unitData.hasOwnProperty('usedefdescr'))
				return;
			if (((unitData.type != 'Tribute' && unitData.shake) || (unitData.type == 'Tribute' && unitData.treasure)) && unitData.time)
			{
				if (unitData.type != 'Tribute' && !App.data.treasures.hasOwnProperty(unitData.shake))
					return;
				var allwaysGives:Array = [];
				var chanceGives:Array = [];
				var treasure:Object;
				
				if(unitData.type == 'Tribute')
					treasure = App.data.treasures[unitData.treasure][unitData.treasure];
				else
					treasure = App.data.treasures[unitData.shake][unitData.shake];
				for (var i:int = 0; i < treasure.item.length; i++)
				{
					if (treasure.probability[i] == 100)
					{
						if (App.data.storage[treasure.item[i]].mtype != 3)
							allwaysGives.unshift(treasure.item[i]);
						else
							allwaysGives.push(treasure.item[i]);
					}
					else{
						if (App.data.storage[treasure.item[i]].mtype != 3)
							chanceGives.unshift(treasure.item[i]);
						else
							chanceGives.push(treasure.item[i]);
					}
				}
				//Locale.__e('flash:1497276975767'); и
				//Locale.__e('flash:1497275730321', []); шансом
				//Locale.__e('flash:1497275423121', []); элементы коллекции:
				var gives:String = "";
				if (allwaysGives.length > 0)
				{
					for each(var _sid:* in allwaysGives)
					{
						//if (App.data.storage[_sid].type == 'Collection')
						//{
							//gives += Locale.__e('flash:1497275423121', [App.data.storage[_sid].title]) + ', ';
						//}else
							gives += (App.data.storage[_sid].title + ', ');
					}
					gives = gives.slice(0, gives.length - 2);
					if (chanceGives.length > 0)
						gives += ' ' + Locale.__e('flash:1497276975767') + ' ';
				}
				var givesChance:String = "";
				if (chanceGives.length > 0)
				{
					for each(var _ch_sid:* in chanceGives)
					{
						//if (App.data.storage[_ch_sid].type == 'Collection')
						//{
							//givesChance += Locale.__e('flash:1497275423121', [App.data.storage[_ch_sid].title]) + ', ';
						//}else
							givesChance += (App.data.storage[_ch_sid].title + ', ');
					}
					givesChance = givesChance.slice(0, givesChance.length - 2);
					gives += Locale.__e('flash:1497275730321', [givesChance]);
				}
				//unitData.shake
				if(unitData.type == 'Tribute')
					unitData['description'] = Locale.__e('flash:1497278594754', [int(unitData.time / 3600), gives]);
				else
					unitData['description'] = Locale.__e('flash:1497271358161', [int(unitData.time / 3600),gives]);
				//trace('unit ' + unitData['description']);
			}
		}
		
	}

}