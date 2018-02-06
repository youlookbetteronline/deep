/**
 * Created by Andrew on 10.05.2017.
 */
package wins.ggame
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import wins.Window;

	public class StartPanel extends Sprite
	{
		private var locale1:String = Locale.__e("flash:1393581021929");
		private var bttn:Button;

		private var _icon:Bitmap;
		private var _countLabel:TextField;

		public function StartPanel()
		{
			drawBttn();
		}

		private function drawBttn():void
		{
			bttn = new Button( {
				caption:locale1,
				fontSize:34,
				width:200,
				height:70,
				hasDotes:false
			});

			bttn.addEventListener(MouseEvent.CLICK, onClick_handler);

			bttn.x -= bttn.width / 2;
			bttn.y -= bttn.height / 2;
			addChild(bttn);

			Load.loading(Config.getIcon(App.data.storage[GGameModel.instance.startPriceSID].type, App.data.storage[GGameModel.instance.startPriceSID].view), function(data:*):void {
				_icon = new Bitmap(data.bitmapData);

				Size.size(_icon, 45, 45);
				_icon.smoothing = true;

				bttn.addChild(_icon);

				bttn.textLabel.x = bttn.textLabel.x - _icon.width;
				_icon.x = bttn.textLabel.x + bttn.textLabel.width + 5;
				_icon.y = (bttn.height - _icon.height) / 2;

				_countLabel = Window.drawText(GGameModel.instance.startPrice[GGameModel.instance.startPriceSID].toString(), {
					color:		0xfbdb38,
					borderColor:0x682c00,
					textAlign:	'left',
					fontSize:	36
				});

				update();
				bttn.addChild(_countLabel);

				_countLabel.x = _icon.x + _icon.width + 5;
				_countLabel.y = _icon.y + (_icon.height - _countLabel.height) / 2 + 8
			});
		}

		public function update():void
		{
			if(App.user.stock.checkAll(GGameModel.instance.startPrice))
			{
				_countLabel.borderColor = 0x754122;
				_countLabel.textColor = 0xfefefe;
			}
			else
			{
				_countLabel.borderColor = 0x591f0b;
				_countLabel.textColor = 0xff632c;
			}
		}

		private function onClick_handler(e:MouseEvent):void
		{
			dispatchEvent(new GGameEvent(GGameEvent.ON_START_CLICK));
		}

		public function enabled(value:Boolean):void
		{
			bttn.visible = value;
		}

		public function dispose():void
		{
			if(bttn)
			{
				bttn.removeEventListener(MouseEvent.CLICK, onClick_handler);
				bttn.dispose();
			}
		}
	}
}
