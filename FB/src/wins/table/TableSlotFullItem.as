package wins.table 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Table;
	import wins.MaterialIcon;
	import wins.Window;
	import wins.WindowEvent;
	
	public class TableSlotFullItem extends TableSlotItem 
	{
		private var _textTimeLeft:TextField
		private var _materialIcon:MaterialIcon;
		private var _rewardIcon:MaterialIcon;
		private var _rewardGramotan:MaterialIcon;		
		private var _progressBar:Sprite;
		private var _progressBG:Bitmap
		private var boostBttn:MoneyButton;
		
		public function TableSlotFullItem(target:Table, slotID:int ) 
		{
			super(target, slotID);
		}
		
		override protected function drawbody():void 
		{
			super.drawbody();
			var iconSize:int = 80;
			
			_materialIcon = new MaterialIcon(_currentSlot.currentMaterial, true, _currentSlot.count, iconSize, 0);
			_materialIcon.x = _bg.x + (_bg.width - 80) * .5 ;
			_materialIcon.y = _bg.y - 80 + 80/2 + 8/*+ _bg.height / 2*/ ;
			addChild(_materialIcon);			
			
			drawProgressBar();
			drawBoostBtth();
			
			_textTimeLeft = Window.drawText(TimeConverter.timeToStr(_currentSlot.finished - App.time), {
				fontSize:18,
				color:0xFFFFFA,
				borderColor:0x844236,
				textAlign:"center"
			});
			
			_textTimeLeft.x = (width - _textTimeLeft.width) * 0.5;
			_textTimeLeft.y = _progressBG.y + 0;
			//addChild(_textTimeLeft);
		}
		
		private function drawBoostBtth():void 
		{			
			boostBttn = new MoneyButton( {
				caption: Locale.__e("flash:1382952380104"),
				countText:String(App.data.storage[_target.sid].skip),
				width:140,
				height:38,
				bgColor:[0xbaf76e,0x68af11],
				borderColor:[0xcefc97, 0x5f9c11],
				fontColor:0xFFFFFF,
				fontBorderColor:0x4d7d0e,
				fontCountBorder:0x4d7d0e,
				bevelColor:[0xcefc97, 0x5f9c11]
			})
			
			addChild(boostBttn);
			boostBttn.x = _bg.x + (_bg.width - boostBttn.width) * 0.5;
			boostBttn.y = _bg.y + _bg.height + 23;//height - boostBttn.height / 2 ;
			boostBttn.addEventListener(MouseEvent.CLICK, onClick)
		}
		
		private  function onClick(e:MouseEvent):void 
		{
			if (boostBttn.mode == Button.DISABLED)
				return;
			
			boostBttn.state = Button.DISABLED;
			var postObject:Object = { };
			postObject["ctr"] = "Table";
			postObject["act"] = "boost";
			postObject["sID"] = _target.sid;
			postObject["uID"] = App.user.id;
			postObject["id"] = _target.id;
			postObject["wID"] = App.user.worldID;
			postObject["mID"] = _currentSlot.currentMaterial;
			postObject["count"] = _currentSlot.count;
			postObject["slot"] =_slotID;
			
			Post.send(postObject, function(error:*, data:*, params:*):void
			{
				if (error) 
				{
					Errors.show(error, data);
					return;
				}
				
				_currentSlot.finished = App.time;
				App.user.stock.take(Stock.FANT, App.data.storage[_target.sid].skip);
				
				var point:Point = new Point(boostBttn.x + (boostBttn.width * 0.5), boostBttn.y + (boostBttn.height * 0.5));
				var xy:Point = localToGlobal(point);
				Hints.minus(Stock.FANT, App.data.storage[_target.sid].skip , xy, false);
				
				SoundsManager.instance.playSFX('bonusBoost');
			});
		}		
		
		private function drawProgressBar():void
		{
			if (_progressBar != null)
			{
				removeChild(_progressBar);
				_progressBar = null;
			}
			
			_progressBar = new Sprite();
			
			_progressBG = new Bitmap(UserInterface.textures.progressBar);
			/*_progressBG.scaleY = .6;
			_progressBG.scaleX = .3;*/
			//addChild(_progressBG);
			
			//App.self.setOnTimer(progress)
			//addChild(_progressBar);
			
			_progressBG.x = (width - _progressBG.width) * 0.5;
			_progressBG.y = height - _progressBG.height - 20;
			_progressBar.x = _progressBG.x + 4;
			_progressBar.y = _progressBG.y + 4;
		}
		
		private function progress(e:WindowEvent = null):void
		{
			var _progress:Number = 100 - ((_currentSlot.finished - App.time) / (_currentSlot.sellTime * _currentSlot.count)) * 100;
			//var progressB:Bitmap = new Bitmap(Window.textures.progressBar)
			UserInterface.slider(_progressBar, _progress, 100, "progressSlider");
			//UserInterface.slider2(_progressBar, _progress, 93, progressB);
			_textTimeLeft.text = TimeConverter.timeToStr(_currentSlot.finished - App.time);
		}
		
		override public function dispose():void 
		{
			//App.self.setOffTimer(updateTimer);
			//App.self.setOffTimer(progress)
			super.dispose();
		}
	}
}