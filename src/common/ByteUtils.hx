package common;
import haxe.io.BytesData;
import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * ...
 * @author 
 */

class ByteUtils 
{
	@:noStack static public function BytesToByteArray(bytes:Bytes):ByteArray {
		if (bytes == null) return null;
		//return bytes.getData();
		var byteArray:ByteArray = new ByteArray();
		byteArray.endian = Endian.LITTLE_ENDIAN;
		for (n in 0 ... bytes.length) byteArray.writeByte(bytes.get(n));
		byteArray.position = 0;
		return byteArray;
	}

	//@:noStack static public function ToByteArray(array:Array<Int>):ByteArray { return ArrayToByteArray(array); }
	//@:noStack static public function ToByteArray(array:Bytes):ByteArray { return BytesToByteArray(array); }

	@:noStack static public function ArrayToByteArray(array:Array<Int>):ByteArray {
		if (array == null) return null;
		var byteArray:ByteArray = new ByteArray();
		byteArray.position = 0;
		for (n in 0 ... array.length) byteArray.writeByte(array[n]);
		return byteArray;
	}

	@:noStack static public function ArrayToBytes(array:Array<Int>):Bytes {
		if (array == null) return null;
		var bytes:Bytes = Bytes.alloc(array.length);
		for (n in 0 ... bytes.length) bytes.set(n, array[n]);
		return bytes;
	}

	@:noStack static public function ByteArrayToBytes(byteArray:ByteArray):Bytes {
		#if flash9
			return Bytes.ofData(byteArray);
		#elseif (cpp || neko)
			return byteArray;
		#end
		if (byteArray == null) return null;
		var bytes:Bytes = Bytes.alloc(byteArray.length);
		var initialByteArrayPosition:Int = byteArray.position;
		byteArray.position = 0;
		//for (n in 0 ... bytes.length) bytes.set(n, byteArray.readUnsignedByte());
		byteArray.position = initialByteArrayPosition;
		return bytes;
	}

	@:noStack static public function memset(bytes:Bytes, offset:Int, length:Int, value:Int):Void
	{
		for (n in offset ... offset + length)
		{
			bytes.set(n, value);
		}
	}

}