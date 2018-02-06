package {
	
	public class Storage 
	{		
		// Инфо объекта
		public static function info(sid:*):Object 
		{
			if (App.data.storage[sid]) 
			{				
				return App.data.storage[sid];
			}
			
			return { };
		}
		
		private static var pricesDifferent:Object;
		
		public static function price(onePiecePrice:int, count:int = 1, sid:int = 0):int
		{
			var percent:int = 100;
			
			if (!pricesDifferent && !App.isSocial('YB', 'AI')) 
			{
				try {
					pricesDifferent = JSON.parse(App.data.options.MaterialPriceDrop);
				}catch(e:Error) {
					pricesDifferent = { };
				}
			}
			
			// Если цена за штуку == 1
			if (sid != Stock.FANT && onePiecePrice == 1) 
			{
				for (var value:* in pricesDifferent)
				{
					if (value <= count && percent > pricesDifferent[value]) percent = pricesDifferent[value];
				}
			}
			
			return Math.round(onePiecePrice * count * percent / 100);
		}
		
		public static function japanFormat(string:String, numberOverNewLine:uint = 30):String {
			var ieroglyphs:Array = ['み','い','の','ね','も','う','フ','テ','ィ','バ','ル','の','は','わ','て','る','わ','こ','で','け','ね','、','し','い','サ','テ','ン','ど','う','や','っ','ケ','ア','す','る','え','あ','げ','る','わ'];
			var position:uint = 0;
			
			while (position + numberOverNewLine < string.length) {
				while (ieroglyphs.indexOf(string.charAt(position + numberOverNewLine)) != -1 && position + numberOverNewLine < string.length) {
					position ++;
				}
				string = string.substring(0, position + numberOverNewLine + 1) + '\n' + string.substring(position + numberOverNewLine + 1);
				position = position + numberOverNewLine + 1;
			}
			
			return string;
		}
		
		/**
		 * Список материалов в кладе
		 * @param	type
		 * @param	view
		 * @return
		 */
		public static function getCollectionItems(type:String, view:String = null):Array {
			// Если нет View, то View = Type
			if (!view) view = type;
			
			var list:Array = [];
			
			if (App.data.treasures[type] && App.data.treasures[type][view]) {
				var treasure:Object = App.data.treasures[type][view];
				if (treasure.hasOwnProperty('item')) {
					list = treasure.item;
				}else if (treasure.hasOwnProperty('materialItem')) {
					list = treasure.materialItem;
				}
			}
			
			return list;
		}
	}	
}