package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class TopListWindow extends Window 
	{
		private var _description:TextField;
		private var _competition:Competition;
		private var _competitions:Vector.<Competition>;
		private var _competitionsContainer:Sprite = new Sprite();
		
		public function TopListWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 365;
			settings["height"] 				= 325;
			settings["hasPaper"] 			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'yellowClose';
			settings['fontColor'] 			= 0x6e411e;
			settings['fontBorderColor'] 	= 0xfdf3cb;
			settings['fontBorderSize']		= 4;
			settings['fontSize'] 			= 28;
			settings['itemsOnPage']			= 3;
			settings["paginatorSettings"] 	= {
				buttonPrev		:"bubbleArrow"
			};
			
			return settings;
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = Window.backing4(settings.width, settings.height, 0, "backingYellowTL", "backingYellowTR", "backingYellowBL", "backingYellowBR");
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawDescription();
			contentChange();
			build();
		}
		
		override public function contentChange():void 
		{
			disposeChilds(_competitions);
			_competitions = new Vector.<Competition>;
			var Y:int = 0;
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				_competition = new Competition({
					tID		: settings.content[i],
					iterator: i
				});
				_competition.y = Y;
				_competitionsContainer.addChild(_competition);
				_competitions.push(_competition);
				Y += _competition.HEIGHT;
			}
		}
		
		private function drawDescription():void 
		{
			_description =  Window.drawText(Locale.__e('flash:1522053468015'), {
				color			:0xffffff,
				borderColor		:0x6e411e,
				borderSize		:3,
				fontSize		:32,
				width			:230,
				textAlign		:'center',
				multiline		:true,
				wrap			:true
			})
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			paginator.arrowLeft.y -= 25;
			paginator.arrowRight.y -= 25;
			paginator.arrowRight.x += 23;
			paginator.arrowLeft.x += 20;
		}
		
		private function build():void 
		{
			exit.x -= 15;
			exit.y += 15;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = -10;
			bodyContainer.addChild(_description);
			
			_competitionsContainer.x = (settings.width - _competitionsContainer.width) / 2;
			_competitionsContainer.y = _description.y + _description.height + 5;
			bodyContainer.addChild(_competitionsContainer);
		}
	}

}
import buttons.Button;
import core.Numbers;
import core.TimeConverter;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.text.TextField;
import utils.TopHelper;
import wins.Window;

internal class Competition extends LayerX 
{
	private var _settings:Object = {
		width	:335,
		height	:60
	}
	private var _background:Shape = new Shape();
	private var _title:TextField;
	private var _timeEndTitle:TextField;
	private var _timeEndText:TextField;
	private var _timeEndContainer:Sprite = new Sprite();
	private var _timeToEnd:int;
	private var _bttn:Button;
	private var _info:Object = new Object();
	
	public function Competition(settings:Object){
		this._info = App.data.top[settings.tID];
		for (var property:* in settings)
			_settings[property] = settings[property]
		drawBackground();
		drawTitle();
		drawTimeEnd();
		drawButton();
		build();
	}
	
	private function drawBackground():void 
	{
		var bgColor:uint = 0xcea162;
		if ((_settings.iterator) % 2 == 0)
			bgColor = 0xe6d8bd;
		_background.graphics.beginFill(bgColor, .9);
		_background.graphics.drawRect(0,0,_settings.width - 54, _settings.height)
		_background.graphics.endFill();
		_background.filters = [new BlurFilter(60, 0)];
	}
	
	private function drawTitle():void 
	{
		_title = Window.drawText(App.data.storage[_info.target].title, {
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:4,
			fontSize		:26,
			width			:110 ,
			textAlign		:'left',
			multiline		:true,
			wrap			:true
		})
	}
	
	private function drawTimeEnd():void 
	{
		_timeEndTitle = Window.drawText(Locale.__e('flash:1486476576457'),{
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:3,
			fontSize		:20,
			width			:130 ,
			textAlign		:'center'
		})
		_timeEndContainer.addChild(_timeEndTitle);
		
		_timeToEnd = _info.expire.e - App.time;
		if (_info.type == TopHelper.WEEKLY)
			_timeToEnd = Math.abs(((App.time - _info.expire.s)  % Numbers.WEEK) - Numbers.WEEK);
		_timeEndText = Window.drawText(TimeConverter.timeToDays(_timeToEnd),{
			color			:0xffe558,
			borderColor		:0x6e411e,
			borderSize		:3,
			fontSize		:26,
			width			:130 ,
			textAlign		:'center'
		})
		
		_timeEndText.x = _timeEndTitle.x + (_timeEndTitle.width - _timeEndText.width) / 2;
		_timeEndText.y = _timeEndTitle.y + _timeEndTitle.textHeight;
		_timeEndContainer.addChild(_timeEndText);
		App.self.setOnTimer(progress)
	}
	
	private function progress():void 
	{
		_timeToEnd = _info.expire.e - App.time;
		if (_info.type == TopHelper.WEEKLY)
			_timeToEnd = Math.abs(((App.time - _info.expire.s)  % Numbers.WEEK) - Numbers.WEEK);
		_timeEndText.text = TimeConverter.timeToDays(_timeToEnd);
		if (_timeToEnd <= 0)
		{
			App.self.setOffTimer(progress);
			Window.closeAll();
		}
	}
	private function drawButton():void 
	{
		_bttn = new Button({
			caption			:Locale.__e('flash:1382952380228'),
			fontColor		:0xffffff,
			width			:95,
			height			:35,
			fontSize		:20,
			bgColor			:[0xfed131, 0xf8ab1a],
			bevelColor		:[0xf7fe9a, 0xcb6b1e],
			fontBorderColor	:0x6e411e
		});
		_bttn.addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):void 
	{
		Window.closeAll();
		TopHelper.showTopWindow(_info.target);
	}
	
	private function build():void 
	{
		_background.y = (_settings.height - _background.height) / 2;
		_background.x = 6;
		addChild(_background);
		
		_title.y = _background.y + (_background.height - _title.height) / 2 + 3;
		addChild(_title);
		
		_bttn.x = 215;
		_bttn.y = _background.y + (_background.height - _bttn.height) / 2;
		addChild(_bttn);	
		
		_timeEndContainer.x = 90;
		_timeEndContainer.y = _background.y + (_background.height - _timeEndContainer.height) / 2 + 3;
		addChild(_timeEndContainer);
	}
	
	public function get HEIGHT():int{return _settings.height}
}