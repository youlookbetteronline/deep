package api
{
	public class flashVarsGenerator
	{
		public static function take(userID:String):Object
		{
			var flashVars:Object = new Object();
			
			flashVars['api_id'] = 9490649;//3539072; // 2786285; // 3539072;
			flashVars['viewer_id'] = String(userID);
			
				/*https	*/
			flashVars['social']	= App.SOCIAL;	
			flashVars['sid'] = "5017d3dfa6796033bc0624c2850cdbe3d3074d7d2832eae64b69f383a705243b33c5f51d66f38a839cc8f";
			flashVars['secret'] = "5a4784aaee";
			flashVars['group'] = "http://vk.com/dreams_legends";
			flashVars['blink'] = 'b5950b573da4d8'/*'54f43a416be5d'*/;
			flashVars['profile'] = {
				first_name:"Deepest",
				last_name:"User",
				sex:"f",
				photo: 'http://deep.islandsville.com/resources/icons/avatars/SimpleAvatar.jpg',//Config.getImageIcon('avatars', 'SimpleAvatar', 'jpg'),// 'http://cs316618.userapi.com/u174971289/e_29f86101.jpg',
				lastvisit:'1421960448'
			};
			//DM
			//flashVars['appFriends'] = ["50545195", "162343837","96391814","91134146","5724681","395378840","296701576","26261710","413309776","159185922","376089319","5811664","83730403"]
			//FB
			//flashVars['appFriends'] = ["1","104305380190894","111827119381277","774242479407105","100315980533350","1246733732110408","1254397617991628","973881489414432","1850121798639095","1877339085840506","1884198341793819","1920498268230736","1956515181301348","1977227169174536","272003303206419","640899449454407"]
			//flashVars['appFriends'] = ["1", "1201908849877177", "248619388991797"];
			//FBD
			//flashVars['appFriends'] = ["1", "640899449454407", "774242479407105", "973881489414432", "1850121798639095", "1884198341793819", "830321993812336", "780002282164694", "1246733732110408", "1201908849877177", "100315980533350", "8", "2"];
			//flashVars['appFriends'] = ["1"];
			return flashVars;
		}
	}
}