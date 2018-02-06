/**
 * Created by Andrew on 16.05.2017.
 */
package wins.ggame.result {
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.GGame;
	import wins.Paginator;
	import wins.Window;
	import wins.ggame.GGameModel;
	import wins.ggame.GGameWindow;

	public class ResultWindow extends Window
	{
		private const LABEL_OFFSET:int = 30;

		private var _items:Array = new Array();


		private var _maska:Shape;
		private var _itemsContainer:Sprite;
		private var _model:ResultModel;
		private var _modelGame:GGameModel;
		private var _itemsList:Array;
		private var _ggamewin:GGameWindow;

		private var _labelSettings:Object = {
			color		:0xffdf34,
			borderColor	:0x451c00,
			width		:175,
			fontSize	:35,
			multiline	:false,
			textAlign	:"left",
			wrap		:false,
			background	: false
		};

		public function ResultWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}

			_model = ResultModel.instance;
			_modelGame = GGameModel.instance;
			//_model.gained = {2400:3, 2398:1, 2397:4, 2393:4, 2391:1, 2365:4, 2364:1, 2326:4, 2314:1 , 2318:1, 2320:4, 2308:3, 2307:3, 2304:3, 2292:1} //Контент для теста
			/*_model.gainedText = 'Получили';
			_model.wastedText = 'Потратили';*/
			settings['width'] = 570;
			settings['height'] = 510;
			
			settings['title'] = _model.title || 'Результат';
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 55;
			settings['fontBorderColor'] = 0x492103;
			settings['borderColor'] = 0x492103;
			settings['shadowColor'] = 0x492103;
			settings['fontBorderSize'] = 3;
			
			settings['ribbon'] = 'actionRibbonBg',
			
			settings["page"] = 0; 
			settings["hasPaginator"] = true;
			settings["hasButtons"] = false;
			settings["paginatorSettings"] = {hasArrow: true, hasButtons: false};
			settings["hasArrows"] = true;
			settings["itemsOnPage"] = 12;
			
			settings['hasExit'] = true;
			settings['exitTexture'] =  'closeBttnMetal';
			settings['popup'] = true;
			super(settings);
			_ggamewin = settings.ggamewin;
			createContent();
		}
		
		private function createContent():void 
		{
			var tempContent:Array = Numbers.objectToArraySidCount(_model.gained);
			//settings.content = Numbers.objectToArraySidCount(_model.gained)
			
			for (var i:int = 0; i < tempContent.length; i++)
			{
				for each(var itm:* in _modelGame.uniqItems)
				{
					if (itm.count && itm.sid == Numbers.firstProp(tempContent[i]).key)
					{
						settings.content.push(tempContent[i]);
						break;
					}
				}
			}
			/*for (var item:* in settings.content)
			{
				for each(var itm:* in _modelGame.uniqItems)
				{
					if (!itm.count && itm.sid == Numbers.firstProp(settings.content[item]).key)
					{
						settings.content.splice(item, 1);
						break;
					}
				}
			}*/
		}
		override public function drawBackground():void 
		{;
			var seawheatLB:Bitmap = new Bitmap(Window.textures.seawheatLB);
			seawheatLB.x = -75;
			seawheatLB.y = settings.height - seawheatLB.height - 35;
			layer.addChild(seawheatLB);
			
			var seawheatRB:Bitmap = new Bitmap(Window.textures.seawheatRB);
			seawheatRB.x = settings.width - 66;
			seawheatRB.y = settings.height - seawheatRB.height - 28;
			layer.addChild(seawheatRB);
			
			super.drawBackground()
			var paper:Bitmap = Window.backing(settings.width - 70, settings.height - 70, 20, 'paperClear');
			paper.x = (settings.width - paper.width) / 2;
			paper.y = (settings.height - paper.height) / 2;
			layer.addChild(paper);
		}

		override public function drawBody():void {
			drawRibbon();
			titleLabel.y += 11;
			titleBackingBmap.width -= 80;
			titleBackingBmap.x = titleLabel.x - (titleBackingBmap.width - titleLabel.width) / 2; 
			exit.y -= 20
			drawItemsContainer();
			drawLabels();
			drawButton();
			contentChange();
		}
		
		private function drawButton():void 
		{
			var bttn:Button = new Button( {
				width			:150,
				height			:60,
				radius			:19,
				fontSize		:36,
				textAlign		:'center',
				caption			:Locale.__e('flash:1382952380298'),
				fontBorderColor	:0x762e00,	
				bgColor			:[0xfed131,0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xf8ab1a]
			});
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 25;
			bodyContainer.addChild(bttn);
			bttn.addEventListener(MouseEvent.CLICK, okEvent)
		}
		
		private function okEvent(e:*):void 
		{
			close();
			//_ggamewin.panel3.update(_modelGame.canCatch - _modelGame.catchedCount);
		}
		

		override public function close(e:MouseEvent = null):void {
			super.close(e);
			_ggamewin.panel3.update(_modelGame.canCatch - _modelGame.catchedCount);
			if(_model.onClose != null)
			{
				_model.onClose();
			}
		}

		override public function contentChange():void {
			
			for each(var item:ResultItem in _itemsList) {
				_itemsContainer.removeChild(item);
				item.dispose();
				item= null;
			}
			_itemsList = [];
			var sid:String;
			//var item:ResultItem;

			var offsetY:int = 0;
			var X:int = 0;
			var Y:int = 0;
			var i:int = 0
			var itemCount:int = 1;
			for (var j:int = paginator.startCount; j < paginator.finishCount; j++) 
			{
				item = new ResultItem(Numbers.getProp(settings.content[j]).key, Numbers.getProp(settings.content[j]).val, {borderColor:0x754122, textColor:0xfefefe});
				item.x = X;
				item.y = Y;
				
				_itemsContainer.addChild(item);
				_itemsList.push(item);
				
				X += item.width + 5;
				if (itemCount % 4 == 0)
				{
					X = 0;
					Y += item.height + 5;
				}
				itemCount++
				settings.page = paginator.page;
			}
		}
		private function drawLabels():void {
			var wastedText:TextField;
			var wastadeCont:TextField;
			
			wastedText = Window.drawText(Locale.__e('flash:1476192070661'), _labelSettings);
			_labelSettings.fontSize = 30
			_labelSettings.color = 0xffffff
			wastadeCont = Window.drawText(String(_model.gainedCount), _labelSettings); _model.wastedText;

			wastedText.x = 80;
			wastedText.y = 50;
			wastadeCont.x = wastedText.x + wastedText.textWidth + 10;
			wastadeCont.y = 55;
			
			bodyContainer.addChild(wastadeCont);
			bodyContainer.addChild(wastedText)
			if (Numbers.countProps(_model.wasted) > 0)
			{
				Load.loading(Config.getIcon(App.data.storage[Numbers.firstProp(_model.wasted).key].type, App.data.storage[Numbers.firstProp(_model.wasted).key].preview),
				function(data:*):void{
					var wastedIcon:Bitmap = new Bitmap();
					wastedIcon.bitmapData = data.bitmapData;
					Size.size(wastedIcon, 40, 40);
					wastedIcon.smoothing = true;
					wastedIcon.y = wastadeCont.y + (wastadeCont.height - wastedIcon.height) / 2 - 4;
					wastedIcon.x = wastadeCont.x + wastadeCont.textWidth + 10;
					bodyContainer.addChild(wastedIcon);
					
					var succesText:TextField = Window.drawText(Locale.__e('flash:1505138034023', _model.successGainedCount), _labelSettings);
					succesText.y = wastadeCont.y;
					succesText.x = wastedIcon.x + wastedIcon.width + 10;
					bodyContainer.addChild(succesText);
				}) 
			}
		}

		private function drawItemsContainer():void {
			_itemsContainer = new Sprite();
			_itemsContainer.x = 70;
			_itemsContainer.y = 105;
			bodyContainer.addChild(_itemsContainer);
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 76;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 10;
			paginator.arrowRight.y = y;
			
		}
		
		override public function dispose():void {
			super.dispose();


			for each (var item:ResultItem in _items)
			{
				item.dispose();
			}
		}
	}
}
