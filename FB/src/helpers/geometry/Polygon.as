/**
 * Created by Andrew on 18.04.2017.
 */
package helpers.geometry
{
	import flash.geom.Point;

	public class Polygon
	{
		private var _vertexes:Vector.<Point>;

		/**
		 * Создать полигон
		 *
		 * @param vertexes - список вершин
		 */
		public function Polygon(vertexes:Vector.<Point>)
		{
			_vertexes = vertexes.concat();
		}

		/**
		 * Добавить вершину
		 *
		 * @param vertex - вершина типа Point
		 */
		public function addVertex(vertex:Point):void
		{
			if(isVertexInList(vertex))
				return;

			_vertexes.push(vertex);
		}

		/**
		 * Добавить вершины
		 *
		 * @param vertexes - вершины типа Point
		 */
		public function addVertexexes(vertexes:Vector.<Point>):void
		{
			for each (var vertex:Point in vertexes)
			{
				addVertex(vertex);
			}
		}

		/**
		 * Удалить вершину
		 * Находится вершина у которой x = p.x, y = p.y
		 *
		 * @param vertex - вершина типа Point
		 */
		public function removeVertex(vertex:Point):void
		{
			if(!_vertexes || _vertexes.length <=0)
				return;

			for (var i:int = 0; i < _vertexes.length; i++)
			{
				if(_vertexes[i].x == vertex.x && _vertexes[i].y == vertex.y)
				{
					_vertexes.splice(i, 1);
				}
			}
		}

		/**
		 * Удалить вершины
		 *
		 * @param vertexes - вершины типа Point
		 */
		public function removeVertexes(vertexes:Vector.<Point>):void
		{
			for each (var vertex:Point in vertexes)
			{
				removeVertex(vertex);
			}
		}

		/**
		 * Удалить вершину по индексу
		 * Находится вершина у которой x = p.x, y = p.y
		 *
		 * @param index - индекс удаляемого елемента
		 */
		public function removeVertexAt(index:int):void
		{
			if(!_vertexes || _vertexes.length <=0 || _vertexes.length - 1 < index)
				return;

			_vertexes.splice(index, 1);
		}

		/**
		 * Проверка пренадлежности вершины к полигону, работает только для выпуклых многоугольников
		 *
		 * @param point - точка для проверки на пренадлежность к полигону
		 *
		 * @return - принадлежит полигону или нет
		 */
		public function testPoint(point:Point):Boolean
		{
			var minX:Number = _vertexes[0].x;
			var maxX:Number = _vertexes[0].x;
			var minY:Number = _vertexes[0].y;
			var maxY:Number = _vertexes[0].y;

			var i:int;
			var j:int;

			for (i = 1 ; i < _vertexes.length; i++ )
			{
				var q:Point = _vertexes[i];
				minX = Math.min( q.x, minX );
				maxX = Math.max( q.x, maxX );
				minY = Math.min( q.y, minY );
				maxY = Math.max( q.y, maxY );
			}

			if ( point.x < minX || point.x > maxX || point.y < minY || point.y > maxY )
			{
				//если точка вышла за bound полигона, оно 100% не принадлежит ему
				return false;
			}

			var inside:Boolean = false;

			//в одном for используются 2 счетчика что бы j было на 1 меньше чем i, а когда i == 0 , j == последнему елементу
			//таким образом сравниватся всегда будут, i-я вершина с предыдущей
			for (i = 0, j = _vertexes.length - 1 ; i < _vertexes.length; j = i++ )
			{
				if ((_vertexes[i].y > point.y) != (_vertexes[j].y > point.y) &&
						point.x < ( _vertexes[j].x - _vertexes[i].x ) * ( point.y - _vertexes[i].y ) / ( _vertexes[j].y - _vertexes[i].y ) + _vertexes[i].x )
				{
					inside = !inside;
				}
			}

			return inside;
		}

		/**
		 * Получить список вершин
		 * Возвращает копию списка вершин!
		 *
		 * @return Vector.<Point> - копия вершин полигона
		 */
		public function get vertexes():Vector.<Point> {
			return _vertexes.concat();
		}

		private function isVertexInList(vertex:Point):Boolean
		{
			for (var i:int = 0; i < _vertexes.length; i++)
			{
				if(_vertexes[i].x == vertex.x && _vertexes[i].y == vertex.y)
				{
					return true;
				}
			}

			return false;
		}
	}
}
