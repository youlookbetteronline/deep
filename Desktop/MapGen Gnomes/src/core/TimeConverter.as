package core{
		
	//import com.printf;
	
	public class  TimeConverter
	{
		
		public function TimeConverter()
		{
			
		}
		
		/**
		 * Приводит время заданное кол-вом секунд к формату ЧЧ:ММ:СС
		 * @param	time
		 */
		public static function timeToStr(time:int):String
		{
			var hours:int = Math.floor(time / 3600);
			var minutes:int = Math.floor((time - hours * 3600) / 60);
			var seconds:int = Math.floor(time - hours * 3600 - minutes * 60);
			
			if (hours > 120)
			{
				return " " + String(int(hours / 24) + " " + Locale.__e("дн."));
			}
			return toFormat(hours)+ ':' + toFormat(minutes) + ':' + toFormat(seconds);
		}
		
		/**
		 * Приводит время заданное кол-вом секунд к формату ММ:СС
		 * @param	time
		 */
		public static function minutesToStr(time:int):String
		{
			var hours:int = Math.floor(time / 3600);
			var minutes:int = Math.floor((time - hours * 3600) / 60);
			var seconds:int = Math.floor(time - hours * 3600 - minutes * 60);
			
			return toFormat(minutes) + ':' + toFormat(seconds);
		}
		
		/**
		 * Преобразовывает единицу времени (часы, минуты или секунды) в формат XX
		 * @param	time
		 */
		public static function toFormat(time:int):String 
		{
			var str:String = String(time);
			if (str.length == 1) 
			{
				return '0' + str;
			}
			return str;
		}
		
				
	}
	
}