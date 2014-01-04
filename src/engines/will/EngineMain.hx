package engines.will;

import lang.DisposableHolder;
import reflash.display.TransitionImage2;
import reflash.display.HtmlColors;
import reflash.display.Stage2;
import reflash.display.Quad2;
import reflash.display.Color2;
import reflash.wgl.WGLFrameBuffer;
import reflash.display.DisplayObject2;
import reflash.wgl.WGLTexture;
import reflash.display.Image2;
import reflash.display.Sprite2;
import common.GameInput;
import flash.display.DisplayObject;
import engines.will.formats.anm.TBL;
import engines.will.formats.anm.ANM;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.geom.Rectangle;
import common.geom.Anchor;
import flash.errors.Error;
import common.tween.Tween;
import flash.geom.Point;
import flash.display.BitmapData;
import common.PathUtils;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.media.Sound;
import flash.display.PixelSnapping;
import engines.will.formats.wip.WIP;
import promhx.Promise;
import haxe.Log;
import common.GameScalerSprite;
import common.BitmapDataUtils;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.utils.ByteArray;
//import sys.io.File;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends Sprite2 implements IScene
{
	private var gameSprite:Sprite2;
	private var fs:VirtualFileSystem;
	private var initScript:String;
	private var initScriptPos:Int;
	private var willResourceManager:WillResourceManager;

	public function getMaskValueAt(point:Point):Int
	{
		var x = Std.int(point.x);
		var y = Std.int(point.y);

		if (tblMask != null)
		{
			if (x < 0 || y < 0 || x >= tblMask.width || y >= tblMask.height) return 0;
			return tblMask.getPixel(x, y) & 0xFF;
		}
		return 0;
	}

	public function getMousePosition():Point
	{
		return gameSprite.globalToLocal(GameInput.mouseCurrent);
	}

	private var previousBitmap:WGLFrameBuffer;
	private var renderedBitmap:WGLFrameBuffer;
	private var currentBitmap:WGLFrameBuffer;

	private var previousBitmapImage:Image2;
	private var currentBitmapImage:Image2;

	private var contentContainer:Sprite2;

	//private var textLayer:TextField;
	private var menuLayer:Sprite2;
	private var objectsLayer:GameLayer;
	private var layer1Layer:GameLayer;
	private var layer2Layer:GameLayer;
	private var backgroundLayer:GameLayer;

	private var screenRect:Rectangle;

	private var gameState:GameState;

	private var transitionMask:BitmapData;
	private var transitionMaskTexture:DisposableHolder<WGLTexture>;

	public function new(fs:VirtualFileSystem, subpath:String, script:String, scriptPos:Int = 0)
	{
		super();

		transitionMaskTexture = new DisposableHolder<WGLTexture>();

//if (script == null) script = 'PW0001';
		if (script == null) script = 'START';

		this.initScript = script;
		this.initScriptPos = scriptPos;
		this.fs = SubVirtualFileSystem.fromSubPath(fs, subpath);

		init();
	}

	private function init()
	{
		WillResourceManager.createFromFileSystemAsync(fs).then(init2);
	}

	private function init2(willResourceManager:WillResourceManager)
	{
		this.willResourceManager = willResourceManager;
		this.gameSprite = new Sprite2();

		this.contentContainer = new Sprite2();

		screenRect = new Rectangle(0, 0, 800, 600);

		//var centerPoint = Anchor.centerCenter.getPointInRect(screenRect);
		//var zeroPoint = Anchor.topLeft.getPointInRect(screenRect);

		this.contentContainer.addChild(this.backgroundLayer = new GameLayer(willResourceManager, Anchor.centerCenter));
		this.contentContainer.addChild(this.layer1Layer = new GameLayer(willResourceManager, Anchor.topLeft));
		this.contentContainer.addChild(this.layer2Layer = new GameLayer(willResourceManager, Anchor.topLeft));
		this.contentContainer.addChild(this.objectsLayer = new GameLayer(willResourceManager, Anchor.topLeft));
		this.contentContainer.addChild(this.menuLayer = new Sprite2());

		this.previousBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();
		this.renderedBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();
		this.currentBitmap = WGLFrameBuffer.create(800, 600).clear(HtmlColors.black).finish();

		//this.previousBitmap = WGLFrameBuffer.create(1024, 1024);
		//this.currentBitmap = WGLFrameBuffer.create(1024, 1024);

		/*
		var test = WGLFrameBuffer.create(512, 512);
		test.clear(HtmlColors.blue);
		//test.draw(new Quad2(200, 200, HtmlColors.red));
		Stage2.instance.addChild(new Image2(test.texture).setZIndex(1));
		*/

		//test.drawElement();
		//test.draw(new Quad2(200, 200, HtmlColors.red));
		//Stage2.instance.addChild(new Image2(test.texture).setAnchor(0, 0).setZIndex(1));

		this.gameSprite.addChild(previousBitmapImage = new Image2(previousBitmap.texture));
		this.gameSprite.addChild(currentBitmapImage = new Image2(currentBitmap.texture));

		//this.gameSprite.addChild(this.textLayer = new TextField());
		//textLayer.selectable = false;

		//addChild(new GameScalerSprite(800, 600, this.gameSprite));
		addChild(this.gameSprite);

		gameState = new GameState();
		var rio = new RIO(this, willResourceManager, gameState);

		rio.loadAsync(initScript).then(function(e)
		{
			rio.jumpAbsolute(initScriptPos);
			rio.executeAsync().then(function(e)
			{
				Log.trace('END!');
			});
		});
	}

	public function setTransitionMaskAsync(name:String):Promise<Dynamic>
	{
		return getBtyeArrayAsync('$name.MSK').then(function(data:ByteArray)
		{
			var wip = WIP.fromByteArray(data);
			transitionMask = wip.get(0).bitmapData;
			//transitionMaskTexture.set(WGLTexture.fromBitmapData(transitionMask));
		});
	}

	public function performTransitionAsync(kind:Int, time:Int):Promise<Dynamic>
	{
		/*
		previousBitmap.clear(HtmlColors.black).draw(renderedBitmap).finish();
		renderedBitmap.clear(HtmlColors.black).draw(contentContainer).finish();
		currentBitmap.clear(HtmlColors.black).draw(renderedBitmap).finish();
		*/

		previousBitmap.clear(HtmlColors.black).draw(currentBitmap).finish();
		currentBitmap.clear(HtmlColors.black).draw(contentContainer).finish();

		//gameSprite.addChild(contentContainer).setZIndex(100);

		//var bitmapData = new BitmapData(800, 600); bitmapData.noise(0);
		//currentBitmap.draw(new Image2(WGLTexture.createWithBitmapData(bitmapData)));
		//currentBitmap.draw(new Quad2(100, 100, Color.create(1, 0, 0, 1)));

		//gameSprite.addChild(new Quad2(100, 100, Color.create(1, 0, 0, 1)));

		//Stage2.instance.addChild(new Quad2(100, 100, Color.create(1, 0, 0, 1)));

		return Tween.forTime(time / 1000).onStep(function(ratio:Float)
		{
			switch (kind) {
				case 42, 44: // TRANSITION MASK (blend) (42: normal, 44: reverse)
					//BitmapDataUtils.applyBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind != 44));
					//currentBitmap.alpha = 1;
					//currentBitmap.clear(HtmlColors.black).draw(new TransitionImage2(renderedBitmap.texture, transitionMaskTexture, ratio)).finish();
					currentBitmapImage.alpha = ratio;
				case 23, 24: // TRANSITION MASK (no blend) (42: normal, 44: reverse)
					//BitmapDataUtils.applyNoBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind == 24));
					//currentBitmap.alpha = 1;
					//currentBitmap.clear(HtmlColors.black).draw(new TransitionImage2(renderedBitmap.texture, transitionMaskTexture, ratio)).finish();
					currentBitmapImage.alpha = ratio;
				default:
					currentBitmapImage.alpha = ratio;
			}
		}).animateAsync();
		/*
		var rect = previousBitmap.bitmapData.rect;
		var previousBitmapData = previousBitmap.bitmapData;
		var currentBitmapData = currentBitmap.bitmapData;

		previousBitmapData.copyPixels(currentBitmapData, rect, new Point(0, 0));

		previousBitmap.alpha = 1;
		currentBitmap.alpha = 0;

		currentBitmapData.lock();
		currentBitmapData.fillRect(rect, 0x00000000);
		currentBitmapData.draw(contentContainer);
		currentBitmapData.unlock();

		//var outputBitmapData = previousBitmap.bitmapData;
		//
		//var previous = renderPrev();
		//var next = renderNext();
		//var temp1 = renderTemp1();
		//var temp2 = renderTemp2();

		//return new Promise<Dynamic>();

		return Tween.forTime(time / 1000).onStep(function(ratio:Float)
		{
			switch (kind) {
				case 42, 44: // TRANSITION MASK (blend) (42: normal, 44: reverse)
					{
						BitmapDataUtils.applyBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind != 44));
						currentBitmap.alpha = 1;
					}
				case 23, 24: // TRANSITION MASK (no blend) (42: normal, 44: reverse)
					{
						BitmapDataUtils.applyNoBlendMaskWithOffset(currentBitmapData, transitionMask, ratio, (kind == 24));
						currentBitmap.alpha = 1;
					}
				default:
					{
						currentBitmap.alpha = ratio;
					}
			}
		}).animateAsync();
		*/
	}

	public function getLayerWithName(name:String):GameLayer
	{
		return switch (name) {
			case 'layer2': layer2Layer;
			case 'layer1': layer1Layer;
			case 'objects': objectsLayer;
			case 'background': backgroundLayer;
			default: throw('Can\'t find layer $name');
		}
	}

	public function getBtyeArrayAsync(name:String):Promise<ByteArray>
	{
		return willResourceManager.readAllBytesAsync(name);
	}

	private var channels:Map<String, SoundChannel>;

	private function getChannelVolume(name:String):Float
	{
		return switch (name) {
			case 'music': 0.5;
			default: 1.0;
		}
	}

	public function setText(text:String):Void
	{
		/*
		textLayer.defaultTextFormat = new TextFormat("Arial", 16, 0xFFFFFFFF);
		textLayer.selectable = false;
		textLayer.width = 800;
		textLayer.height = 600;
		textLayer.text = StringTools.replace(text, '\\n', '\n');
		*/
	}

	public function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):Promise<Dynamic>
	{
		//return Promise.promise(null);

		if (channels == null) channels = new Map<String, SoundChannel>();

		if (channels.exists(channelName))
		{
			channels[channelName].stop();
			channels.remove(channelName);
		}

		if (name == null || name.length == 0)
		{
			return Promise.promise(null);
		}
		else
		{
			return getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'ogg')).then(function(data:ByteArray)
			{
				var sound = new Sound();
				var playAsMusic = (channelName == 'music');
				sound.loadCompressedDataFromByteArray(data, data.length, playAsMusic);
				var channel:SoundChannel = channels[channelName] = sound.play();
				channel.soundTransform = new SoundTransform(getChannelVolume(channelName));
			});
		}
	}

	private var menuItems:Array<DisplayObject2>;

	public function animLoadAsync(name:String):Promise<Dynamic>
	{
		if (menuItems == null) menuItems = [];

		var promise = new Promise<Dynamic>();
		getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'anm')).then(function(data:ByteArray)
		{
			var anm = ANM.fromByteArray(data);
			willResourceManager.getWipWithMaskAsync(anm.wipName).then(function(wip:WIP)
			{
				menuLayer.removeChildren();
				for (n in 0 ... wip.getLength())
				{
					var wipEntry = wip.get(n);
					var bitmap = new Image2(WGLTexture.fromBitmapData(wipEntry.bitmapData));
					bitmap.x = wipEntry.x;
					bitmap.y = wipEntry.y;
					bitmap.visible = false;
					bitmap.zIndex = 0;
					menuItems.push(bitmap);
					menuLayer.addChild(bitmap);
				}
				promise.resolve(null);
			});
		});
		return promise;
	}

	private function updateMenuEnable()
	{
		menuLayer.getChildAt(0).visible = true;
		for (n in 0 ... tbl.count)
		{
			var enableFlag = tbl.enable_flags[n];
			var enable = gameState.getFlag(enableFlag) != 0;
//Log.trace(enableFlag);
//menuLayer.getChildAt(n + 1).visible = enable;
		}
	}

	private var tbl:TBL;

	private var tblMask:BitmapData;

	public function tableLoadAsync(name:String):Promise<Dynamic>
	{
		var promise = new Promise<Dynamic>();
		getBtyeArrayAsync(PathUtils.addExtensionIfMissing(name, 'TBL')).then(function(data:ByteArray)
		{
			tbl = TBL.fromByteArray(data);

			willResourceManager.getWipAsync(tbl.mskName + '.MSK').then(function(msk:WIP):Void
			{
				tblMask = msk.get(0).bitmapData;
//File.saveBytes('c:/temp/lol2.png', msk.get(0).bitmapData.encode('png'));
				updateMenuEnable();
				promise.resolve(null);
			});
		});
		return promise;
	}

	public function setDirectMode(directMode:Bool):Void
	{
		if (gameSprite.contains(contentContainer) == directMode) return;

		if (gameSprite.contains(contentContainer)) gameSprite.removeChild(contentContainer);
		if (directMode) gameSprite.addChild(contentContainer);
		if (!directMode) menuLayer.removeChildren();
	}

	public function setAnimObjectVisibility(index:Int, visible:Bool):Promise<Dynamic>
	{
		var index1 = index + 1;
		menuItems[index1].visible = visible;
//Log.trace('@@@@@@@@@@@ index: $index1 -> $visible');
//menuLayer.getChildAt(index1).visible = visible;
//return new Promise<Dynamic>();
		return Promise.promise(null);
	}
}