package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import models.BankerModel;
	import ui.Hints;
	import units.Banker;
	/**
	 * ...
	 * @author abdurda
	 */
	public class BankerWindow extends Window
	{
		private var _contentContainer:Sprite;
		private var _model:Object;
		private var _description:TextField;
		private var _target:Object;
		private var _timeToBonus:TextField;
		private var _timerCont:LayerX;
		private var _bttn:Button;
		private var _rewardFlag:Boolean;;
		
		public function BankerWindow(settings:Object=null) 
		{
			_model = settings.model;
			_target= settings.target.info
			settings = settingsInit(settings);
			super(settings);
			
		}
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}

			settings["width"]				= 550;
			settings["height"] 				= 400;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			//settings['background	'] 		= 'workerHouseBacking';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x085c10;
			settings['borderColor'] 		= 0x085c10;
			settings['shadowBorderColor']	= 0x085c10;
			settings['fontSize'] 			= 50;
			settings['title'] 				= _target.title//settings.target.info.title;
			
			return settings;
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, 'workerHouseBacking');
				layer.addChild(background);	
			
			var paper:Bitmap = Window.backing(settings.width - 76, settings.height - 76, 40, 'itemBacking');
				paper.x = (background.width - paper.width) / 2;
				paper.y = (background.height - paper.height) / 2;
				layer.addChild(paper);
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawDescription();
			contentChange();
			drawTimer();
			drawBttn();
			build();
		}
		
		private function build():void 
		{
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 30;
			
			_contentContainer.x = (settings.width - _contentContainer.width) / 2;;
			_contentContainer.y = _description.y + _description.height + 5;
			
			_timerCont.x = (settings.width - _timerCont.width) / 2;
			_timerCont.y = _contentContainer.y + _contentContainer.height + 5;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 35 - _bttn.height / 2;
			
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_contentContainer);
			bodyContainer.addChild(_timerCont);
			bodyContainer.addChild(_bttn);
		}
		
		
		private function drawDescription():void 
		{
			var duration:String = TimeConverter.timeToDays(_target.time);
			var name:String 	= _target.title;
			var percent:int 	= _target.rate * 100;
			var params:Array = [duration, name, percent, duration];
			_description = Window.drawText(Locale.__e('flash:1508250037433', params),{
				fontSize		:30,
				textAlign		:'center',
				color			:0x6e411e,
				//borderColor		:0x6e411e,
				borderSize		:0,
				multiline		:true,
				wrap			:true,
				width			:settings.width - 100
			})
		}
		
		
		override public function contentChange():void 
		{
			_contentContainer = new Sprite();
			var shardIcon:Bitmap = new Bitmap(new BitmapData(90, 90));
			//Надпись осталось
			var text:TextField = Window.drawText(Locale.__e('flash:1508252335727') + ' ' + BankerModel.loyalty[_target.madd].count,{	
				fontSize		:30,
				textAlign		:'left',
				color			:0xffffff,
				borderColor		:0x6e411e,
				borderSize		:2,
				autoSize		:'left'
			});
				
			Load.loading(Config.getIcon('Material','diamond'), function (data:Bitmap):void {
				shardIcon.bitmapData = data.bitmapData
				Size.size(shardIcon, 90, 90);
				shardIcon.smoothing = true;	
			})
			
			text.x = shardIcon.width + 10;
			text.y = (shardIcon.height - text.height) / 2;
			
			_contentContainer.addChild(shardIcon);
			_contentContainer.addChild(text);
		}
		
		private function drawTimer():void 
		{
			_timerCont = new LayerX();
			var text:TextField =  Window.drawText(Locale.__e('flash:1393581955601') + ' ', {
				color		:0xffffff,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:34,
				borderSize	:2,
				autoSize	:'left'
			});
			_timeToBonus =  Window.drawText(TimeConverter.timeToDays(_model.storageTime - App.time), {
				color		:0xffdf34,
				borderColor	:0x451c00,
				textAlign	:'left',
				fontSize	:34,
				borderSize	:2,
				autoSize	:'left'
			});
			
			_timeToBonus.x = text.width;
			
			_timerCont.addChild(text);
			_timerCont.addChild(_timeToBonus);
			_timerCont.tip = function():Object{
				return{
					title	:Locale.__e('flash:1474469531767'),
					text	:Locale.__e('flash:1508335763931')
				}
			}
			
			if ((_model.storageTime - App.time) <= 0)
				_timerCont.visible = false;
				
			App.self.setOnTimer(onTick);
		}
		
		private function drawBttn():void 
		{
			
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1393579618588'),
			fontColor	:0xffffff,
			width		:150,
			height		:50,
			fontSize	:23
			};
			
			if (BankerModel.loyalty[_target.madd].count <= 0)
				bttnSettings.caption = Locale.__e('flash:1382952380298');
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onStorageEvent);
			//if (!_model.tribute)
				_bttn.state = Button.DISABLED;
		}
		
		
		private function onStorageEvent(e:MouseEvent):void 
		{
			if (_bttn.mode == Button.NORMAL)
			{
				_model.storageCallback()
			}else{
				Hints.text(Locale.__e('flash:1382952379839') + TimeConverter.timeToDays(_model.storageTime - App.time), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
		}
		
		private function onTick():void
		{
			var timeToBonus:int = _model.storageTime - App.time;	
			if (timeToBonus <= 0)
			{
				_bttn.state = Button.NORMAL;
				_timerCont.visible = false;
				App.self.setOffTimer(onTick);
				return;
			}	
			_timeToBonus.text = TimeConverter.timeToDays(_model.storageTime - App.time);
		}
	}

}