package tree 
{
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class Missions extends Sprite
	{
		private var quest:Object;
		private var craftz:Object = new Object();
		private var bonusList:BonusList;
		private var needList:BonusList;
		private var missions:Sprite = new Sprite();
		private var bonusBackgroutnd:Bitmap;
		private var backgroutndWidth:int = 450;
		public function Missions(qID:int) 
		{
			quest = App.data.quests[qID];
			var lastY:int = 79;
			var lastX:int = 0;
			for (var mID:String in  quest.missions )
			{
				var mission:MissionItem  = new MissionItem (qID, int(mID));
				addChild(mission);
				mission.y = lastY;
				mission.x = (backgroutndWidth - mission.width)/2;
				lastY += 105;
				lastX = mission.width;
			}
			drawBonus();
			
			drawNeedMaterials();
			
			bonusBackgroutnd = UI.backing(backgroutndWidth, 135 + 35 + Numbers.countProps(quest.missions) * 100 + needList.height, 47, 'questTaskBackingTop');
			bonusBackgroutnd.x = 0;
			bonusBackgroutnd.y = 0;
			addChildAt(bonusBackgroutnd,0);
			
			var updateImg:Bitmap = new Bitmap ();
			if (App.data.quests[qID].update)
			{
				Load.loading(Config.getImageIcon('updates/images', App.data.updates[App.data.quests[qID].update].preview), function(data:Bitmap):void {
					updateImg.bitmapData = data.bitmapData;
					
					//updateImg.scaleY = updateImg.scaleX = .5;
					UI.size(updateImg, bonusBackgroutnd.width - 20, bonusBackgroutnd.height - 20);
					updateImg.alpha = .7;
					updateImg.x = bonusBackgroutnd.x + (bonusBackgroutnd.width - updateImg.width) / 2;//bonusBackgroutnd.width * 0.5 - updateImg.width * 0.5;
					updateImg.y = bonusBackgroutnd.y + (bonusBackgroutnd.height - updateImg.height) / 2;//bonusBackgroutnd.height * 0.5 - updateImg.height * 0.5;
					
					addChildAt(updateImg,1);
				});
			
			}
			relocate();
		}
		
		private function drawBonus():void
		{
			if (bonusList == null)
			{
				var titleLabel:TextField = UI.drawText('Награда:', {
					fontSize:24,
					color:0xffffff,
					borderColor:0x49341e,
					multiline:true,
					borderSize:3,
					textAlign:"center",
					textLeading:-3
				});
				
				titleLabel.x = (backgroutndWidth - titleLabel.width) / 2;
				titleLabel.y = 2;
				addChild(titleLabel);
			
				bonusList = new BonusList(quest.bonus.materials, false, { 
					hasTitle:false,
					backingShort:true,
					width: 1909,
					height: 60,
					bgWidth:5000,
					bgX: -3,
					bgY:5,
					titleColor:0x571b00,
					titleBorderColor:0xfffed7,
					bonusTextColor:0x361a0a,
					bonusBorderColor:0xfffed7
				
				} );
				addChild(bonusList);
				bonusList.x = (backgroutndWidth - bonusList.width) / 2;
				bonusList.y = 25;
			}
			
		}
		
		private function divideNeedMaterials():void
		{
			var countCheck:int = App.self.summLevel;
			var counter:int = 0;
			while(counter < countCheck){
				for (var material:* in needMaterials)
				{
					var newMaterials:Object = new Object();
					if (App.resourcesVector.hasOwnProperty(material))
					{
						for (var mater0:* in App.resourcesVector[material])
						{
							newMaterials[mater0] = int(App.resourcesVector[material][mater0] * needMaterials[material]);
							
						}
						delete needMaterials[material];
						summMaterials(newMaterials);
						continue;
					}
					
					if (App.craftsVector.hasOwnProperty(material))
					{
						for (var mater1:* in App.craftsVector[material])
						{
							newMaterials[mater1] = int(App.craftsVector[material][mater1] * needMaterials[material]);
							craftz[material] = App.craftsVector[material].time;
						}
						delete needMaterials[material];
						summMaterials(newMaterials);
						continue;
					}
					
					if (App.technoVector.hasOwnProperty(material))
					{
						for (var mater2:* in App.technoVector[material])
						{
							newMaterials[mater2] = int(App.technoVector[material][mater2] * needMaterials[material]);
							
						}
						delete needMaterials[material];
						summMaterials(newMaterials);
						continue;
					}
					
					if (App.tableVector.hasOwnProperty(material))
					{
						for (var mater3:* in App.tableVector[material])
						{
							newMaterials[mater3] = int(App.tableVector[material][mater3] * needMaterials[material]);
							
						}
						delete needMaterials[material];
						summMaterials(newMaterials);
						continue;
					}
					
					if (App.feedsVector.hasOwnProperty(material))
					{
						for (var mater4:* in App.feedsVector[material])
						{
							newMaterials[mater4] = int(App.feedsVector[material][mater4] * needMaterials[material]);
							
						}
						delete needMaterials[material];
						summMaterials(newMaterials);
						continue;
					}
				}
				/*if (counter > 0 && materialsArray[counter-1] == needMaterials)
				{
					break;
				}*/
				
				materialsArray[counter] = needMaterials;
				counter++;
			};
		}
		
		private function drawNeedMaterials():void
		{
			//App.technoVector
			//App.feedsVector
			//App.tableVector
			//App.craftsVector
			//App.buildingsVector
			needMaterials = new Object();
			for each(var miss:* in quest.missions)
			{
				switch(miss.event)
				{
					case 'add':
						summMaterials({(miss.target[0]):miss.need});
						break;
					case 'upgrade':
						if (App.buildingsVector.hasOwnProperty(miss.target[0]) == false)
							continue;
						for (var count:int = 1; count <= miss.need; count++)
						{
							summMaterials(App.buildingsVector[miss.target[0]][count]);
						}
						break;
					case 'zone':
						for (var count1:int = 0; count1 < miss.need; count1++)
						{
							summMaterials(App.data.storage[miss.target[count1]].price);
						}
						break;
					case 'crafting':
						summMaterials({(miss.target[0]):miss.need});
						break;
					case 'dress':
						summMaterials({(int(App.data.crafting[App.data.storage[miss.target[0]].dlist[0]].out)):miss.need});
						break;
				}
			}
			divideNeedMaterials();
			materialsArray
				//if (needMaterials.hasOwnProperty('underfind'))
					//return;
			if (needList == null)
			{
				if (Numbers.countProps(needMaterials) > 0)
				{
					var needLabel:TextField = UI.drawText('Для выполнения надо:', {
						fontSize		:24,
						color			:0xffffff,
						borderColor		:0x49341e,
						multiline		:true,
						borderSize		:3,
						textAlign		:"center",
						textLeading		:-3
					});
					
					needLabel.x = (backgroutndWidth - needLabel.width) / 2;
					needLabel.y = 90 + Numbers.countProps(quest.missions) * 100;
					addChild(needLabel);
				}
				//divideNeedMaterials();
				needList = new BonusList(needMaterials, false, {
					hasTitle			:false,
					backingShort		:true,
					width				:1909,
					height				:60,
					bgWidth				:5000,
					bgX					:-3,
					bgY					:5,
					titleColor			:0x571b00,
					titleBorderColor	:0xfffed7,
					bonusTextColor		:0x361a0a,
					bonusBorderColor	:0xfffed7,
					target				:this
				
				} );
				addChild(needList);
				needList.x = (backgroutndWidth - needList.width) / 2;
				needList.y = 120 + Numbers.countProps(quest.missions) * 100;
			}
			
		}
		
		private var needMaterials:Object = new Object();
		public var materialsArray:Vector.<*> = new Vector.<*>();
		private function summMaterials(newMaterials:Object):void
		{
			if (Numbers.countProps(newMaterials) > 0)
			{
				for (var material:* in newMaterials)
				{
					if (needMaterials.hasOwnProperty(material))
					{
						needMaterials[material] += newMaterials[material];
					}else
					{
						needMaterials[material] = newMaterials[material];
					}
				}				
			}
		}
		
		public function relocate():void 
		{
			x = App.self.stage.mouseX + 30;
			y = App.self.stage.mouseY + 0;
			
			if (App.self.stage.stageWidth - App.self.stage.mouseX < bonusBackgroutnd.width)
				x -= bonusBackgroutnd.width;
			
			if (App.self.stage.stageHeight - App.self.stage.mouseY < bonusBackgroutnd.height - 40)
				y -= bonusBackgroutnd.height;
				
			if (y < 0)
				y = 0;
				
			if (y + bonusBackgroutnd.height > App.self.stage.stageHeight)
				y = App.self.stage.stageHeight - bonusBackgroutnd.height;
			//App.treeManeger.mission.x = e.stageX + 20;
			//App.treeManeger.mission.y = e.stageY - (App.treeManeger.mission.height) / 2;
		}
	}

}