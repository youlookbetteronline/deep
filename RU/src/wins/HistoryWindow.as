package wins 
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class HistoryWindow extends Window
	{
		
		public var items:Array = [];

		public function HistoryWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}		
			
			settings['width'] = 660;
			settings['height'] = 560;
			
			settings['title'] = Locale.__e("flash:1383227541049");
			settings['hasPaginator'] = true;
			settings['itemsOnPage'] = 8;
			
			var sortedContent:Array = [];
			
			settings['content'] = settings['content'] || [];
			
			for (var i:int = 0; i < settings['content'].length; i++) {
				if (App.isSocial('AI')) 
				{
					settings['content'][i]['itemID']=settings['content'][i].product_code.slice(String(settings['content'][i].product_code).indexOf('_'),settings['content'][i].product_code.length);
					settings['content'][i].status = (settings['content'][i].transaction_end < App.time)?0:1;
					sortedContent.push(settings['content'][i])
				}else{
				var _ids:String = String(settings['content'][i].itemID);
				var typeID:* = _ids.substr(0, 1);
				if (typeID == 1 || typeID == 2) {
					sortedContent.push(settings['content'][i])
				}else {
					continue;
				}
				}
			}
			
			settings.content = sortedContent;
			
			var cont:Array = [];
			var count:int = 0;
			for (var j:int = 0; j < settings.content.length; j++) 
			{
			if (settings.content[j].status) 
				{	
				cont[count] = settings.content[j];
				count++;	
				}
			}
			
				settings.content = cont;
			
			
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "windowBacking");
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			exit.x += 20;
			exit.y -= 22;
			paginator.y += 50;
			
			var amount:TextField;
			var transaction_time:TextField;
			var transaction_end:TextField;
			var txnid:TextField
			
			var textSettings:Object = {
				fontSize	:22,
				color:0xffcc00,
				borderColor:0x705535,
				textAlign	:'center'
			}
		
			textSettings['width'] = 102;
			amount 				= Window.drawText(Locale.__e('flash:1383229186583'), textSettings);
			textSettings['width'] = 140;
			transaction_time 	= Window.drawText(Locale.__e('flash:1383229215303'), textSettings);
			textSettings['width'] = 140;
			transaction_end 	= Window.drawText(Locale.__e('flash:1383229242023'), textSettings);
			//textSettings['width'] = 164;
			//txnid 				= Window.drawText(Locale.__e('flash:1383229266586'), textSettings);
			
			
			amount.height = amount.textHeight;
			transaction_time.height = transaction_time.textHeight;
			transaction_end.height = transaction_end.textHeight;
			//txnid.height = txnid.textHeight;
			
			//bodyContainer.addChild(txnid);
			bodyContainer.addChild(amount);
			bodyContainer.addChild(transaction_time);
			bodyContainer.addChild(transaction_end);
			
			//txnid.x = 34;
			//txnid.y = 55;
			
			amount.x = 208 - 100;
			amount.y = 55;
			
			transaction_time.x = 320 - 100;
			transaction_time.y = 55;
			
			transaction_end.x = 490 - 100;
			transaction_end.y = 55;
			
			contentChange();
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
			}
			items = [];
	
			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < Math.min(paginator.finishCount, settings.content.length); i++){
			//UserInterface.textures
			/*for (var itm:* in settings.content) {*/
				
			
				var item:HistoryItem = new HistoryItem(settings.content[i], this);
				bodyContainer.addChild(item);
				item.x = (settings.width - item.width)/2;
				item.y = item.height * itemNum + 80;
				items.push(item);
				itemNum++;
				bodyContainer.addChild(item);
			
			}
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = -28;
			paginator.arrowLeft.y = y-10;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 28;
			paginator.arrowRight.y = y-10;
		}
		
	}
}

import core.Numbers;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class HistoryItem extends LayerX {
	
	public var amount:TextField;
	public var transaction_time:TextField;
	public var transaction_end:TextField;
	public var txnid:TextField
	public var obj:Object;
	public var moneySID:*;
	public var count:*;
	
	public function HistoryItem(item:Object, window:*) {
		
		var _ids:String = String(item.itemID);
		var _id:* = _ids.slice(1,_ids.length);
		obj = App.data.storage[_id];
		//if (obj == null)
			//return;
		for (moneySID in obj.price){
			count = obj.price[moneySID];
			break;
		}	
		
		var bg:Bitmap = Window.backing(620-100, 48, 10, 'textSmallBacking');
		addChild(bg);
		
		var color:uint = 0x000000;
		if (item.transaction_end < App.time) {
			color = 0x333333;
		}
		
		var textSettings:Object = {
			color:color,
			fontSize:18,
			textAlign:'left',
			border:false
		}
		
		textSettings['width'] = 140;
		transaction_time 	= Window.drawText(TimeConverter.getDatetime("%Y.%m.%d %H:%i",item.transaction_time), textSettings);
		textSettings['width'] = 140;
		transaction_end 	= Window.drawText(TimeConverter.getDatetime("%Y.%m.%d %H:%i",item.transaction_end), textSettings);
		//textSettings['width'] = 164;
		//txnid 				= Window.drawText(String(count), textSettings);
		
		//textSettings['width'] = 102;
		var cont:Sprite = new Sprite();
		var fantsIcon:Bitmap = new Bitmap();
		switch(moneySID) {
			case Stock.COINS:
					fantsIcon.bitmapData = UserInterface.textures.coinsIcon;
				break;	
			case Stock.FANT:
					fantsIcon.bitmapData = UserInterface.textures.fantsIcon;
				break;	
		}
		
		fantsIcon.scaleX = fantsIcon.scaleY = 0.6;
		fantsIcon.smoothing = true;
		cont.addChild(fantsIcon);
		
		textSettings['autoSize'] = 'left';
		amount 				= Window.drawText(Numbers.moneyFormat(count), textSettings);
		cont.addChild(amount);
		amount.x = fantsIcon.width + 4;
		amount.y = 2;
		
		
		
		//txnid.mouseEnabled = true;
		amount.mouseEnabled = true;
		transaction_time.mouseEnabled = true;
		transaction_end.mouseEnabled = true;
		
		//addChild(txnid);
		addChild(cont);
		addChild(transaction_time);
		addChild(transaction_end);
		
		//txnid.x = 14;
		//txnid.y = 12;
		
		cont.x = 10;//188 + (102 - cont.width) / 2;
		cont.y = 12;
		
		transaction_time.x = 300 - 110;
		transaction_time.y = 12;
		
		transaction_end.x = 470 -110;
		transaction_end.y = 12;		
	}
}


