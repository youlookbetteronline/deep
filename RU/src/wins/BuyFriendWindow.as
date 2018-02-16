package wins 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import units.AUnit;
	/**
	 * ...
	 * @author ...
	 */
	public class BuyFriendWindow extends Window 
	{
		private var _fakefriend:Fakefriend;
		private var _fakefriendList:Vector.<Fakefriend>;
		private var _fakefriendContainer:Sprite = new Sprite();
		private var _target:AUnit;
		public function BuyFriendWindow(settings:Object=null) 
		{
			_target = settings.target;
			settings["width"]				= 530;
			settings["height"] 				= 350;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= true;
			settings["hasArrows"]			= false;
			settings['exitTexture'] 		= 'closeBttnMetal';
			settings['background']	 		= 'capsuleWindowBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x116011;
			settings['borderColor'] 		= 0x116011;
			settings['shadowBorderColor']	= 0x116011;
			settings['fontSize'] 			= 50;
			settings['content'] 			= _target.info.fakefriends;
			
			super(settings);
			
			
		}
		
		override public function contentChange():void 
		{
			disposeChilds(_fakefriendList);
			var X:int = 0;
			for (var i:int = 0; i < settings.content.length; i++) 
			{
				trace();
				_fakefriend.x = X;
				
				_fakefriendContainer.addChild(_fakefriend);
				_fakefriendList.push(_fakefriend);
				
				X += _fakefriend.SIDE + 10;
			}
		}
		
		
		override public function drawBody():void 
		{
			drawRibbon();
			contentChange()
			build();
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 12;
			titleBackingBmap.y += 6;
		}
	}

}

internal class Fakefriend extends LayerX
{
	private var _settings:Object = {
		side:115
	}
	public function Fakefriend(settings:Object = null)
	{
		for (var property:* in settings)
			_settings[property] = settings[property];
	}
	
	public function get SIDE():int { return _settings.side; }
	
}