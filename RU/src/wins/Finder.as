package wins
{
	import flash.events.*;
	import flash.events.MouseEvent;
	import gifts.GiftManager;
	
	public class Finder
	{
		public static var defaultText = Locale.__e("flash:1382952380106")
		
		public function Finder()
		{
			
		}
		
		/**
		 * Событие наведения на текстовое поле
		 * @param	e
		 */
		public static function onTextOver(e:MouseEvent) 
		{
			//Mouse.cursor = "hand";
			//Mouse.hide();
		}
		
		/**
		 * Событие получения фокуса
		 * @param	e
		 */
		public static function onFocusIn(e:FocusEvent)
		{
			//userNamePrevValue = e.target.text;
			//e.target.embedFonts = false
			
			if(e.target.text == defaultText){
				e.target.text = "";
			}
			ISLANDS.instance.mc.backToNormalScreen();
		}
		
		/**
		 * Событие потери фокуса
		 * @param	e
		 */
		public static function onFocusOut(e:FocusEvent)
		{
			//e.target.embedFonts = true
			if(e.target.text == ""){
				e.target.text = defaultText;
			}
		}
		
		
		
		
		public static function find(str, iconMode:String ="", sortOnGift:Boolean = false)
		{
			var param = 0
			
			if (iconMode == "FREE")
			{
				param = 0
			}
			else
			{
				param = 999999999999999999999
			}	
			
			var L:int = str.length
			var nameStr
			var namePart
			var razdelArray:Array = []
			
				for (var item in Connection.MAIN_CONTAINER.friends.FRIENDS)
				{
					var friend = Connection.MAIN_CONTAINER.friends.FRIENDS[item]
					
					if (friend.lastGift <= param)
					{
						if (sortOnGift == true)
						{
							for (var mID in friend.wlist)
							{
								if (mID == GiftManager.GIFT)
								{
									nameStr = friend.first_name
									namePart = nameStr.slice(0, L)
									
									if (namePart.toLowerCase() == str.toLowerCase())
									{
										razdelArray.push(friend.uid)
									}	
								}
							}
						}
						else
						{
							nameStr = friend.first_name
							namePart = nameStr.slice(0, L)
									 
							if (namePart.toLowerCase() == str.toLowerCase())
							{
								razdelArray.push(friend.uid)
							}
							else
							{
								nameStr = String(friend.uid)
								namePart = nameStr.slice(0, L)
								if (namePart == str)
								{
									razdelArray.push(friend.uid)
								}
							}
						}
					}
				}
				
				if ((str == "" || str == " " || str == null) && sortOnGift == false && iconMode != "FREE")
				{
					return ISLANDS.instance.mc.friends.FRIENDS_UIDs
				}	
				
			return razdelArray
		}
	}
}