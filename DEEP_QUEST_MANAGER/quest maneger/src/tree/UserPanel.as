package tree 
{
	
	import core.AvaLoad;
	import core.Post;
	import core.TimeConverter;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.StageDisplayState;

	public class UserPanel extends LayerX
	{
		private var update:Function
		
		public var bttnSearch:ImageButton;
		public var goBttn:ImageButton;
		public var searchField:TextField;
		public var comboBox:ComboBox;
		public var daylicBox:ComboBox;
		public var settings:Object = {
			callback:	null,
			stop:		null,
			caption:	null,
			hasIcon:	true
		};
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "m"; 
		public var email:String = ""; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String = 'http://cs316618.userapi.com/u174971289/e_29f86101.jpg'; 
		public var year:int; 
		public var city:String = "";
		public var country:String = "";
		public var data:Object;
		
		public static var servers:Object = {
			'DM':	{title: 'DM'},
			'FBD':	{title: 'FBD'},
			'MDM':	{title: 'MDM'},
			'AND':	{title: 'AND'},
			'VK':	{title: 'VK'},
			'OK':	{title: 'OK'},
			'MM':	{title: 'MM'},
			'FS':	{title: 'FS'},
			'FB':	{title: 'FB'},
			'YB':	{title: 'YB'},
			'YBD':	{title: 'YBD'},
			'MX':	{title: 'MX'},
			'AM':	{title: 'AM'},
			'AMD':	{title: 'AMD'},
			'SP':	{title: 'SP'}
		};
		
		public function UserPanel(settings:Object = null)
		{
			if (!settings)
				settings = { };
			for (var item:* in settings)
				this.settings[item] = settings[item];
			
			
			settings['target'] = App.treeManeger.currentTree;
			drawSearch();
			
			if(settings.caption)
				text = settings.caption;
		}
			
		public var lampBmap:Bitmap;
		public var searchBg:LayerX;
		public var sprite:LayerX = new LayerX();
		public var avaBg:Shape = new Shape();
		public var avatar:Bitmap = new Bitmap(null, "auto", true);
		private function drawSearch():void 
		{
			App.social = 'VK';
			lampBmap = new Bitmap(new BitmapData(16, 16, true, 0x0));
			var lampShape:Shape = new Shape()
			lampShape.graphics.beginFill(0xff0000, 1);
			lampShape.graphics.drawCircle(8, 8, 8);
			lampShape.graphics.endFill();
			lampBmap.bitmapData.draw(lampShape);
			addChild(lampBmap);
			//lampBmap.x = -16;
			lampBmap.y = 16;
			//daylicBox = new ComboBox({content:{'1':{title: 1},'2':{title: 2},'3':{title: 3}},title: "Daylics"});
			//addChild(daylicBox);
			//daylicBox.visible = false;
			
			sprite.x = 20;
			sprite.visible = false;
			avaBg.graphics.lineStyle(1, 0x6f340a, 1, true);
			avaBg.graphics.beginFill(0xf2d8aa,1);
			avaBg.graphics.drawRoundRect(0, 0, 40, 40, 15, 15);
			avaBg.graphics.endFill();
			
			addChild(sprite);
			sprite.addChild(avaBg);
			sprite.addChild(avatar);
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(0, 0, avaBg.width - 1, avaBg.width - 1, 15, 15);
			shape.graphics.endFill();
			
			shape.cacheAsBitmap = true;
			avatar.mask = shape;
			avatar.cacheAsBitmap = true;
			sprite.addChild(shape);
			
			sprite.y = 5;
			
			comboBox = new ComboBox({content:UserPanel.servers});
			addChild(comboBox);
			
			comboBox.x = sprite.x + sprite.width + 3;
			//comboBox.y = 0;
			
			searchBg = new LayerX();
			searchBg.graphics.lineStyle(2, 0x6f340a, 1, true);
			searchBg.graphics.beginFill(0xf2d8aa,1);
			searchBg.graphics.drawRoundRect(0, 0, 150, 25, 15, 15);
			searchBg.graphics.endFill();
			
			addChild(searchBg);
			searchBg.x = comboBox.x + comboBox.width + 5;
			searchBg.y = 10;
			comboBox.y = searchBg.y +(searchBg.height - 20) / 2;
			//daylicBox.y = searchBg.y +(searchBg.height - 20) / 2;
			
			goBttn = new ImageButton(Textures.textures['arrow'], { scaleX:1, scaleY:1, shadow:true } );
			addChild(goBttn);
			UI.size(goBttn, searchBg.height - 5, searchBg.height - 5);
			goBttn.x = searchBg.x + searchBg.width - goBttn.width - 4;
			goBttn.y = searchBg.y + (searchBg.height - goBttn.height) / 2;
			goBttn.addEventListener(MouseEvent.CLICK, onGoEvent);
			
			searchField = UI.drawText("",{ 
				color:0x502f06,
				borderColor:0xf8f2e0,
				fontSize:16,
				input:true
			});
			
			searchField.x =  searchBg.x + 2;
			searchField.y = 11;
			searchField.width = goBttn.x - 2 - searchField.x;
			searchField.height = searchField.textHeight + 2;
			
			addChild(searchField);
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			searchField.addEventListener(FocusEvent.FOCUS_OUT, onUnFocusEvent);
		}
		
		
		public function onFocusEvent(e:FocusEvent):void {
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
			
			if (text == settings.caption)
				text = "";
		}
		
		public function onUnFocusEvent(e:FocusEvent):void {
			if(settings.caption && text == "")
				text = settings.caption;
		}
		
		private function onInputEvent(e:Event):void {
			
			//search(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void {
			//if (!searchPanel.visible) {
			//	searchField.text = "";
			//}
			//searchPanel.visible = !searchPanel.visible;
		}
		
		public function onGoEvent(e:MouseEvent):void 
		{
			if (comboBox.rootItem.updateTitle.text == 'Server')
			{
				comboBox.rootItem.showGlowing(0xFF0000);
				return;
			}
			
			if (searchField.text == 'ID игрока')
			{
				searchBg.showGlowing(0xFF0000);
				return;
			}
			
			App.userID = searchField.text;
			
			/*var send:Object = {
				"ctr": "user",
				"act": "getinfo",
				"uID": App.userID
			};*/
			
			//if (App.blink.length > 0)
				//send.blink = App.blink;
			if (App.data.hasOwnProperty('questsInfo'))
			{
				delete App.data['questsInfo'];
			}
			//lampBmap = new Bitmap(new BitmapData(16, 16, true, 0x0));
			var lampShape:Shape = new Shape()
			lampShape.graphics.beginFill(0xff0000, 1);
			lampShape.graphics.drawCircle(8, 8, 8);
			lampShape.graphics.endFill();
			lampBmap.bitmapData.draw(lampShape);
			
			Post.send( {
				'ctr':'user',
				'act':'getinfo',
				'uID':App.userID
				//'wID':worldID,
				//'fields':JSON.stringify(['world'])
			}, onLoadData);
			
			Post.send( {
				'ctr':'util',
				'act':'countbyquests',
				'uID':App.userID
			}, onLoadQuestsData);
			
			//searchField.text = "";
			//search();
			//searchPanel.visible = false;
		}
		public var loadedQinfo:Boolean = false;
		private function onLoadQuestsData(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				return;
			}
			
			if (data.hasOwnProperty('byQuests'))
			{
				//lampBmap = new Bitmap(new BitmapData(16, 16, true, 0x0));
				var lampShape:Shape = new Shape()
				lampShape.graphics.beginFill(0x00ff00, 1);
				lampShape.graphics.drawCircle(8, 8, 8);
				lampShape.graphics.endFill();
				lampBmap.bitmapData.draw(lampShape);
				
				loadedQinfo = true;
				App.data['questsInfo'] = {maxPayers:0,maxNotPayers:0}
				for (var _quest:* in data.byQuests)
				{
						
					if (App.data.quests.hasOwnProperty(_quest))
					{
						if (data.byQuests[_quest].pn > App.data.questsInfo.maxPayers)
							App.data.questsInfo.maxPayers = data.byQuests[_quest].pn;
							
						if (data.byQuests[_quest].n > App.data.questsInfo.maxNotPayers)
							App.data.questsInfo.maxNotPayers = data.byQuests[_quest].n;
							
						App.data.quests[_quest]['addInfo'] = {
							complete:data.byQuests[_quest].f,
							not_complete:data.byQuests[_quest].n,
							don_complete:data.byQuests[_quest].pf,
							don_not_complete:data.byQuests[_quest].pn
						}
						App.data.quests[_quest]['description2'] = '\n\nПрошло квест: ' + data.byQuests[_quest].f + '\nНе прошло квест: ' + data.byQuests[_quest].n+'\nДонатеров прошло квест: ' + data.byQuests[_quest].pf + '\nДонатеров не прошло квест: ' + data.byQuests[_quest].pn;
						//App.data.quests[_quest]['nfUsers'] = data.byQuests[_quest].n;
					}
					//else{
						//App.data.quests[_quest].description = 'Ни один не прошел';
					//}
				}
				if (App.treeManeger)
					App.treeManeger.onQuestsChange();
			}
		}
		
		private function onLoadData(error:int, data:Object, params:Object):void 
		{
			if (error){
				sprite.visible = false;
				//daylicBox.visible = false;
				User.clear();
				if (App.treeManeger)
					App.treeManeger.onQuestsChange();
				text = "Ошибка!!!"
				searchBg.showGlowing(0xFF0000);
				
				return;
			}
			
			if (data.hasOwnProperty('userError') || data.hasOwnProperty('questError'))
			{
				sprite.visible = false;
				//daylicBox.visible = false;
				User.clear();
				if (App.treeManeger)
					App.treeManeger.onQuestsChange();
				text = "Ошибка!!!"
				searchBg.showGlowing(0xFF0000);
			}else{
				this.data = data;
				//App.user.data = data;
				//daylicBox.visible = true;
				User.init(data.quests);
				User.initInfo(data.user);
				if (App.treeManeger)
				{
					App.treeManeger.onQuestsChange();
				}
				if (data.user["photo"] != undefined)
				{
					sprite.visible = false;
					//avatar = new Bitmap(null, "auto", true);
					new AvaLoad(data.user.photo, onLoad);
				}
				var tipText:String = 'Уровень: ' + data.user.level + "\nДрузей: " + data.user.friends + "\nДата регистрации:\n" + TimeConverter.getDatetime("%Y.%m.%d %H:%i", data.user.createtime) +"\nПоследний визит:\n" + TimeConverter.getDatetime("%Y.%m.%d %H:%i", data.user.lastvisit);
				
				if (data.user.hasOwnProperty('daylics'))
				{
					tipText += "\n-----------------------";
					tipText += "\nДэйлик доступен до:\n" + TimeConverter.getDatetime("%Y.%m.%d %H:%i", data.user.daylics.expire)
				
				}
				if (data.user.hasOwnProperty('pay') && App.social != 'FB' && App.social != 'AND' && App.social != 'MDM')
				{
					tipText += "\n-----------------------";
					var valute:String = User.getLocalValute(data.user.pay);
					tipText += "\nПлатит! Красава!\nПотрачено " + valute ;
				
				}
				sprite.tip = function():Object
				{
					return { title: data.user.aka, text: tipText};
				}
			}
			/*var arrr:Array = new Array();
			var units:Object = data.units; // тут двигаем ресурсы
			for each(var _unit:Object in units){
				//_unit['z'] -= 16;
				//_unit['x'] += 31;
				if (_unit['z'] >= 175)
					arrr.push(_unit);//trace();
				
				if (_unit['x'] >= 175)
					arrr.push(_unit);//trace();
			}*/
			//trace('!!!!!!!!!!!!!!!!!')
			//trace(JSON.stringify(units));
			//App.self.dispatchEvent(new AppEvent(AppEvent.ON_USERDATA_COMPLETE));
		}
		
		private function onLoad(data:*):void
		{
			if (data is Bitmap)
			{
				avatar.bitmapData = data.bitmapData;
				avatar.scaleX = avatar.scaleY = .8;
				avatar.smoothing = true;
				//avatar.visible = false;
			}
			sprite.visible = true;
			/*var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000, 1);
			shape.graphics.drawRoundRect(4, 4, avaBg.width - 8, avaBg.width - 8, 15, 15);
			shape.graphics.endFill();
			//shape.filters = [new BlurFilter(2, 2)];
			//shape.alpha = .5;
			shape.cacheAsBitmap = true;
			avatar.mask = shape;
			avatar.cacheAsBitmap = true;
			addChild(shape);*/
		}	
		
		public function set text(value:String):void {
			searchField.text = value;
		}
		public function get text():String {
			return searchField.text;
		}
		
		public function search(query:String = "", isCallBack:Boolean = true):Array {
			if ( query == "" )
			{
				App.treeManeger.showFirst();
				//settings.target.y = 0;
				//settings.target.x = 0;
				return null;
			}
			var _point:Point = App.treeManeger.currentTree.getCoordAndGlow(query);
			if (_point.x == 0 && _point.y == 0)
				return null;
			App.treeManeger.currentTree.x = -_point.x * App.treeManeger.currentTree.scaleX + App.self.stage.stageWidth / 2 - 60;
			App.treeManeger.currentTree.y = -_point.y * App.treeManeger.currentTree.scaleY + App.self.stage.stageHeight / 2 - 50;
			return null;
		}
	}
}	