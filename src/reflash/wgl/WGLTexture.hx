package reflash.wgl;

import lang.IDisposable;
import flash.display.BitmapData;

class WGLTexture implements IDisposable
{
	public var textureBase(default, null):WGLTextureBase;
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var width(default, null):Int;
	public var height(default, null):Int;

	public var px1(default, null):Float;
	public var py1(default, null):Float;
	public var px2(default, null):Float;
	public var py2(default, null):Float;

	private function new(textureBase:WGLTextureBase, x:Int, y:Int, width:Int, height:Int)
	{
		textureBase.referenceCounter.increment();
		this.textureBase = textureBase;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;

		this.px1 = (this.x) / textureBase.width;
		this.py1 = (this.y) / textureBase.height;
		this.px2 = (this.x + this.width) / textureBase.width;
		this.py2 = (this.y + this.height) / textureBase.height;
		/*
		this.px1 = (this.x);
		this.py1 = (this.y);
		this.px2 = (this.x + this.width);
		this.py2 = (this.y + this.height);
		*/
	}

	public function slice(x:Int, y:Int, width:Int, height:Int):WGLTexture
	{
		var nx = Std.int(Math.min(this.x + x, this.width));
		var ny = Std.int(Math.min(this.y + y, this.height));
		var nw = Std.int(Math.max(this.width - x - width, 0));
		var nh = Std.int(Math.max(this.height - y - height, 0));
		return new WGLTexture(this.textureBase, nx, ny, nw, nh);
	}

	static public function fromTextureBase(textureBase:WGLTextureBase, width:Int, height:Int):WGLTexture
	{
		return new WGLTexture(textureBase, 0, 0, width, height);
	}

	static public function fromEmpty(width:Int, height:Int):WGLTexture
	{
		return fromTextureBase(WGLTextureBase.createEmpty(width, height), width, height);
	}

	static public function fromBitmapData(bitmapData:BitmapData):WGLTexture
	{
		return fromTextureBase(WGLTextureBase.createWithBitmapData(bitmapData), bitmapData.width, bitmapData.height);
	}

	public function dispose()
	{
		if (textureBase != null)
		{
			textureBase.referenceCounter.decrement();
			textureBase = null;
		}
	}
}
