package vfs;

import promhx.Promise;
import flash.utils.ByteArray;

/**
 * ...
 * @author 
 */

class Stream extends StreamBase
{
	public function readAllBytesAsync():Promise<ByteArray> {
		return readBytesAsync(length);
	}
}