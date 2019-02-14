package tree 
{
	/**
	 * ...
	 * @author ...
	 */
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;


	public class DaylicItem extends Sprite {
		
		public var qID:int;
		public var mID:int;
		public var bubble:Bitmap;
		public var background:Bitmap;
		public var bitmap:Bitmap = new Bitmap();
		
		public var mission:Object = { };
		public var quest:Object = { };
		
		public var counterLabel:TextField;
		public var titleLabel:TextField;
		
		
		
		private var titleDecor:Bitmap;
		private	var sID:*;
		private var objectSptite:LayerX = new LayerX();
		public function DaylicItem(qID:int, mID:int) {
			
			this.qID = qID;
			this.mID = mID;
			
			
			var bgHeight:int = 100;
			objectSptite.tip = function():Object {
				if (sID)
					return {
						title: 	App.data.storage[sID].title,
						text:	App.data.storage[sID].description
					};
				else
					return { title: "Wait!" };
			}
			
			background = UI.backing(400, bgHeight, 30, 'questTaskBackingTopMini');
			background.y = 7;
			addChild(background);
			
			
			bubble = new Bitmap(Textures.textures.bubbleBackingBig);
			UI.size(bubble, 80, 80);
			bubble.smoothing = true;
			bubble.y = background.y + (background.height - bubble.height) / 2;
			bubble.x = 20;
			addChild(bubble);
			
			
			objectSptite.addChild(bitmap);
			addChild(objectSptite);
			quest = App.data.daylics[qID];
			mission = App.data.daylics[qID].missions[mID];
					
			if(mission.target is Object){
				for each(sID in mission.target) {
					break;
				}
			}else if (mission.map is Object) {
				for each(sID in mission.map) {
					break;
				}
			}
			
			if(sID!= null && App.data.storage[sID] != undefined){
				
				var url:String;
				if (sID == 0 || sID == 1) {
					url = Config.getQuestIcon('missions', mission.preview);
				}else {
					var icon:Object
					if (mission.preview != "" && mission.preview != "1") {
						icon = App.data.storage[mission.preview];
					}else{
						icon = App.data.storage[sID];
					}
					url = Config.getIcon(icon.type, icon.preview);
				}	
				
				loadIcon(url);
			}else if (qID == 30) {
				loadIcon(Config.getQuestIcon("icons", "druid"));
			}
			
			function loadIcon(url:String):void 
			{
				Load.loading(url, function(data:*):void {
					
					
					bitmap.bitmapData = data.bitmapData;
					UI.size(bitmap, 65, 65);
					/*if (bitmap.height > bgHeight-20) {
						
						bitmap.height = bgHeight - 24;
						bitmap.scaleX = bitmap.scaleY;
					}*/
					bitmap.smoothing = true;
					
					bitmap.x = bubble.x + (bubble.width - bitmap.width) / 2;
					bitmap.y = bubble.y + (bubble.height - bitmap.height) / 2;
					
					bitmap.filters = [new GlowFilter(0x00628a, 0.7, 4, 4, 1)];
				});
			}
			
			var text:String;
			
			if (Numbers.countProps(User.daylics.quests) > 0 && User.daylics.quests.hasOwnProperty(qID))
			{
				if(User.daylics.quests[qID].hasOwnProperty(mID))
					text = User.daylics.quests[qID][mID] + '/' + mission.need;
				else
					text = 0 + '/' + mission.need;
			}else{
				//if(mission.func == 'sum'){
				text = 0 + '/' + mission.need;
				/*}else {
					
						text = '0/1';
				}*/
			}
			
			counterLabel = UI.drawText(text, {
				fontSize:24,
				color:0xffffff,
				borderColor:0x2D2D2D,
				autoSize:"left"
			});
			
			counterLabel.x = bubble.x + (bubble.width - counterLabel.width) / 2;
			counterLabel.y = bubble.y + bubble.height - counterLabel.height;
			addChild(counterLabel);
			
			titleLabel = UI.drawText(mission.title, {
				fontSize:18,
				color:0xffffff,
				borderColor:0x49341e,
				multiline:true,
				borderSize:3,
				textAlign:"center",
				textLeading:-3
			});
			titleLabel.wordWrap = true;
			titleLabel.width = 260;
			titleLabel.height = titleLabel.textHeight+10;
			
			titleLabel.x = 110;
			titleLabel.y = (background.height - titleLabel.height) / 2 + 10;
			addChild(titleLabel);
			
			//titleDecor = new Bitmap(Window.textures.diamondsTop, "auto", true);
			//addChild(titleDecor);
			//titleDecor.x = titleLabel.x - titleDecor.width - 5;
			//titleDecor.y = titleLabel.y - 270;


			
			/*if (qID == 36) {	
				App.user.quests.startTrack();
				App.user.quests.currentTarget = helpBttn;
			}*/
		}
		
		

	}

}