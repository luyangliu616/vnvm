package vfs;
import promhx.Promise;
import vfs.utils.ByteArrayUtils;
import flash.errors.Error;
import flash.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class BytesStream extends Stream
{
	var byteArray:ByteArray;
	
	public function new(byteArray:ByteArray) {
		this.byteArray = byteArray;
		this.position = 0;
		this.length = byteArray.length;
	}
	
	override public function readBytesAsync(length:Int):Promise<ByteArray>
	{
		var data:ByteArray;
		byteArray.position = this.position;
		data = ByteArrayUtils.readByteArray(byteArray, length);
		data.position = 0;
		this.position += length;
		return Promise.promise(data);
	}
}