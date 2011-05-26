package net.systemeD.potlatch2.utils {

	import org.vanrijkom.shp.*;
	import org.vanrijkom.dbf.*;
	import net.systemeD.halcyon.Map;
	import net.systemeD.halcyon.connection.Connection;
	import net.systemeD.halcyon.connection.Node;
	import net.systemeD.halcyon.connection.Way;
	import net.systemeD.potlatch2.tools.Simplify;

	public class ShpImporter extends Importer {

		public function ShpImporter(connection:Connection, map:Map, filenames:Array, callback:Function=null, simplify:Boolean=false) {
			super(connection,map,filenames,callback,simplify);
		}

		override protected function doImport(push:Function): void {
			// we load .shp as files[0], .shx as files[1], .dbf as files[2]
			var shp:ShpHeader=new ShpHeader(files[0]);
			var dbf:DbfHeader=new DbfHeader(files[2]);

			if (shp.shapeType==ShpType.SHAPE_POLYGON || shp.shapeType==ShpType.SHAPE_POLYLINE) {

				// Loop through all polylines in the shape
				var polyArray:Array = ShpTools.readRecords(files[0]);
				for (var i:uint=0; i<polyArray.length; i++) {

					// Get attributes like this:
					//		var dr:DbfRecord = DbfTools.getRecord(files[2], dbf, i);
					//		var xsID:String = dr.values[idFieldName];

					// Do each ring in turn, then each point in the ring
					for (var j:int=0; j < polyArray[i].shape.rings.length; j++) {
						var way:Way;
						var nodestring:Array=[];
						var points:Array = polyArray[i].shape.rings[j];
						if (points!=null) {
							for (var k:int=0; k < points.length; k++) {
								var p:ShpPoint = ShpPoint(points[k]);
								nodestring.push(connection.createNode({}, p.y, p.x, push));
							}
						}
						if (nodestring.length>0) {
							way=connection.createWay({}, nodestring, push);
							if (simplify) { Simplify.simplify(way, map, false); }
						}
					}
				}
			}
		}

	}
}
