package engines.tlove.script;
import common.Animation;
import common.Event2;
import common.imaging.BitmapData8;
import common.imaging.Palette;
import common.PathUtils;
import engines.tlove.Game;
import engines.tlove.GameState;
import engines.tlove.mrs.MRS;
import haxe.Log;
import haxe.Timer;
import nme.errors.Error;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.media.Sound;
import nme.utils.ByteArray;

/**
 * XYZ Script Engine
 * 
 * @see T_LOVE95.EXE:00409430
 */
class DAT_OP
{
	var dat:DAT;
	var game:Game;
	var state:GameState;
	
	/**
	 * 
	 * @param	dat
	 */
	public function new(dat:DAT) {
		this.dat = dat;
		this.game = dat.game;
		this.state = dat.game.state;
	}
	
	/**
	 * 
	 */
	@Opcode({ id:0x00, format:"", description:"End of file" })
	@Unimplemented
	function EOF():Void
	{
		throw(new Error("Reached End Of File"));
	}

	/**
	 * 
	 * @param	file
	 * @param	_0
	 */
	@Opcode( { id:0x16, format:"s1", description:"Interface (0x16)" } )
	@Unimplemented
	function INTERFACE1(file:String, unk:Int):Void {
	}

	/**
	 * 
	 * @param	done
	 * @param	leftClickLabel
	 * @param	rightClickLabel
	 */
	@Opcode({ id:0xA6, format:"<22", description:"Wait?" })
	@Unimplemented
	function MOUSE_WAIT_CLICK_EVERYWHERE(done:Void -> Void, leftClickLabel:Int, rightClickLabel:Int):Void {
		var e:MouseEvent;
		
		Event2.registerOnceAny([game.onMouseLeftClick, game.onMouseRightClick], function(e:MouseEvent):Void {
			//e.type = MouseEvent.CLICK;
			if (e.type == MouseEvent.CLICK) {
				dat.jumpLabel(leftClickLabel);
			} else if (e.type == MouseEvent.RIGHT_CLICK) {
				dat.jumpLabel(rightClickLabel);
			} else {
				throw(new Error(Std.format("Invalid event for MOUSE_WAIT_CLICK_EVERYWHERE $e")));
			}
			done();
		});
	}
	
	/**
	 * 
	 * @param	v
	 */
	@Opcode( { id:0x17, format:"<1", description:"Unknown??" } )
	@Unimplemented
	function MOUSE_WAIT_EVENT(done:Void -> Void, v:Int):Void {
		var e:MouseEvent;

		Event2.registerOnceAny([game.onMouseLeftClick, game.onMouseRightClick, game.onMouseMove], function(e:MouseEvent) {
			game.lastMouseEvent = e;
			
			done();
		});
	}
	
	/**
	 * 
	 * @param	leftClickLabel
	 * @param	rightClickLabel
	 * @param	movementLabel
	 * @param	rectCount
	 */
	@Opcode({ id:0xAD, format:"2221", description:"" })
	//@Unimplemented
	function MOUSE_JUMP_IF_EVENT(leftClickLabel:Int, rightClickLabel:Int, missLabel:Int, rectCount:Int):Void {
		if (game.lastMouseEvent.type == MouseEvent.CLICK) {
			dat.jumpLabel(leftClickLabel);
		} else if (game.lastMouseEvent.type == MouseEvent.RIGHT_CLICK) {
			dat.jumpLabel(rightClickLabel);
		} else {
			dat.jumpLabel(missLabel);
		}
		/*
		if (game.mouseRects.length == 0) {
			//done();
			dat.jumpLabel(missLabel);
			done();
		} else {
			done();
		}
		*/
	}
	
	/**
	 * 
	 * @param	x1
	 * @param	y1
	 * @param	x2
	 * @param	y2
	 * @param	label
	 */
	@Opcode({ id:0xA7, format:"22222", description:"" })
	@Unimplemented
	function MOUSE_JUMP_IF_IN(x1:Int, y1:Int, x2:Int, y2:Int, label:Int):Void {
	}

	/**
	 * 
	 * @param	x1
	 * @param	y1
	 * @param	x2
	 * @param	y2
	 * @param	label
	 * @param	flagType
	 * @param	flagIndex
	 */
	@Opcode({ id:0xAE, format:"2222212", description:"" })
	//@Unimplemented
	function MOUSE_JUMP_IF_CLICK_IN_AND_FLAG(x1:Int, y1:Int, x2:Int, y2:Int, label:Int, flagType:Int, flagIndex:Int):Void {
		var rect:Rectangle = new Rectangle(x1, y1, x2 - x1, y2 - y1);
		
		//game.mouseRects.push({ rect: rect, label : label, flagType : flagType, flagIndex : flagIndex });
		
		var pos:Point = new Point(game.lastMouseEvent.localX, game.lastMouseEvent.localY);
		//Log.trace(Std.format("(${rect.x},${rect.y},${rect.width},${rect.height}) // ${pos.x},${pos.y}"));
		if (rect.containsPoint(pos))
		{
			if (game.lastMouseEvent.type == MouseEvent.CLICK)
			{
				//if (state.getFlag(flagType, flagIndex) != 0)
				{
					dat.jumpLabel(label);
				}
		}
		}
	}

	/**
	 * 
	 * @param	v
	 * @param	s
	 * @param	unk
	 */
	@Opcode( { id:0x19, format:"1s1", description:"Set NAME_L" } )
	@Unimplemented
	function NAME_L(v:Int, s:String, unk:Int):Void {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode({ id:0x1B, format:"12", description:"??" })
	@Unimplemented
	function UNKNOWN_1B(a:Int, b:Int):Void {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 */
	@Opcode( { id:0x23, format:"111", description:"??" } )
	@Unimplemented
	function GAME_SAVE(a:Int, b:Int, c:Int):Void {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 */
	@Opcode( { id:0x24, format:"111", description:"??" } )
	@Unimplemented
	function GAME_LOAD(a:Int, b:Int, c:Int):Void {
	}

	/**
	 * 
	 * @param	done
	 * @param	label
	 */
	@Opcode( { id:0x28, format:"<2", description:"Jumps to an address" } )
	//@Unimplemented
	function JUMP(done:Void -> Void, label:Int):Void {
		dat.jumpLabel(label);
		Timer.delay(done, 0);
	}
	
	/**
	 * 
	 * @param	label
	 */
	@Opcode( { id:0x2B, format:"2", description:"Jumps to an address" } )
	//@Unimplemented
	function CALL_LOCAL(label:Int):Void {
		dat.callLabel(label);
	}

	/**
	 * 
	 */
	@Opcode( { id:0x30, format:"", description:"???" } )
	@Unimplemented
	function CLEAR_IMAGE_SCREEN() {
	}

	/**
	 * 
	 */
	@Opcode( { id:0x31, format:"", description:"???" } )
	@Unimplemented
	function COPY_PALETTE() {
	}

	/**
	 * 
	 * @param	done
	 * @param	name
	 * @param	layer
	 */
	@Opcode({ id:0x33, format:"<s1", description:"Loads an image in a buffer" })
	function IMG_LOAD(done:Void -> Void, name:String, layer:Int):Void {
		var mrs:MRS;
		game.getMrsAsync(name, function(mrs:MRS) {
			Palette.copy(mrs.image.palette, game.lastLoadedPalette);
			mrs.image.drawToBitmapData8(game.layers[layer], 0, 0);
			if (layer == 0) game.updateImage();
			done();
		});
	}

	/**
	 * 
	 */
	@Opcode({ id:0x34, format:"", description:"???" })
	@Unimplemented
	function UNKNOWN_34() {
	}

	/**
	 * 
	 * @param	done
	 */
	@Opcode({ id:0x32, format:"<", description:"???" })
	//@Unimplemented
	function FADE_IN(done:Void -> Void):Void {
		// TODO: Perform the fading changing the palette?
		Animation.animate(done, 0.5, { }, { }, Animation.Linear, function(step:Float) {
			game.blackOverlay.alpha = 1 - step;
		});
	}

	/**
	 * 
	 * @param	done
	 */
	@Opcode({ id:0x35, format:"<", description:"???" })
	//@Unimplemented
	function FADE_OUT(done:Void -> Void):Void {
		// TODO: Perform the fading changing the palette?
		Animation.animate(done, 0.5, { }, { }, Animation.Linear, function(step:Float) {
			game.blackOverlay.alpha = step;
		});
	}

	/**
	 * Copy a rect from one layer to other
	 * 
	 * @param	done
	 * @param	effect
	 * @param	transparentColor
	 * @param	srcLayer
	 * @param	srcX
	 * @param	srcY
	 * @param	srcWidth
	 * @param	srcHeight
	 * @param	dstLayer
	 * @param	dstX
	 * @param	dstY
	 */
	@Opcode( { id:0x36, format:"<1112222122", description:"Copy an slice of buffer into another" } )
	//@Unimplemented
	function COPY_RECT(done:Void -> Void, effect:Int, transparentColor:Int, srcLayer:Int, srcX:Int, srcY:Int, srcWidth:Int, srcHeight:Int, dstLayer:Int, dstX:Int = 0, dstY:Int = 0):Void {
		var src:BitmapData8 = dat.game.layers[srcLayer];
		var dst:BitmapData8 = dat.game.layers[dstLayer];
		switch (effect) {
			case 0:
				BitmapData8.copyRect(src, new Rectangle(srcX, srcY, srcWidth, srcHeight), dst, new Point(dstX, dstY));
				if (dstLayer == 0) dat.game.updateImage(new Rectangle(dstX, dstY, srcWidth, srcHeight));
				Timer.delay(done, 0);
			//case 29:
			default:
				Animation.animate(done, 0.4, { }, { }, Animation.Linear, function(step:Float):Void {
					BitmapData8.copyRectTransition(src, new Rectangle(srcX, srcY, srcWidth, srcHeight), dst, new Point(dstX, dstY), step, effect, transparentColor);
					if (dstLayer == 0) dat.game.updateImage(new Rectangle(dstX, dstY, srcWidth, srcHeight));
				});
		}
	}

	/**
	 * 
	 * @param	name
	 * @param	n
	 */
	@Opcode( { id:0x38, format:"s1", description:"Load an animation" } )
	@Unimplemented
	function ANIMATION_START(name, n) {
	}

	/**
	 * 
	 */
	@Opcode( { id:0x39, format:"", description:"???" } )
	@Unimplemented
	function ANIMATION_STOP() {
	}

	/**
	 * 
	 * @param	color
	 * @param	unk
	 * @param	x
	 * @param	y
	 * @param	w
	 * @param	h
	 */
	@Opcode( { id:0x3A, format:"112222", description:"Fills a rect" } )
	//@Unimplemented
	function FILL_RECT(color:Int, unk:Int, x:Int, y:Int, w:Int, h:Int):Void {
		var rect:Rectangle = new Rectangle(x, y, w, h);
		game.layers[0].fillRect(color, rect);
		game.updateImage(rect);
	}

	/**
	 * 
	 * @param	done
	 * @param	mode
	 * @param	index
	 * @param	b
	 * @param	r
	 * @param	g
	 */
	@Opcode( { id:0x3C, format:"<11111", description:"???" } )
	//@Unimplemented
	function PALETTE_ACTION(done:Void -> Void, mode:Int, index:Int, b:Int, r:Int, g:Int) {
		switch (mode) {
			case 0:
				// SET_WORK_PALETTE_COLOR
				game.workPalette.colors[index] = { r : r, g : g, b : b, a : 0xFF };
			case 1:
				// APPLY_PALETTE
				Palette.copy(game.workPalette, game.currentPalette);
				game.updateImage();
			case 2:
				// BACKUP_PALETTE
				Palette.copy(game.workPalette, game.backupPalette);
			case 3:
				// RESTORE_PALETTE
				Palette.copy(game.backupPalette, game.workPalette);
			case 4:
				// ANIMATE_PALETTE
				Log.trace("Not implemented ANIMATE_PALETTE");
				game.updateImage();
			case 5:
				// COPY_PALETTE
				Palette.copy(game.lastLoadedPalette, game.workPalette);
			case 6:
				// FADE_PALETTE
				throw(new Error("FADE_PALETTE"));
			default:
				throw(new Error("PALETTE_ACTION"));
		}
		
		Timer.delay(done, 0);
	}
	
	/**
	 * 
	 */
	@Opcode( { id:0x40, format:"", description:"???" } )
	@Unimplemented
	function JUMP_IF_MENU_VAR() {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 */
	@Opcode({ id:0x41, format:"221", description:"???" })
	@Unimplemented
	function JUMP_IF_REL(a, b, c) {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode({ id:0x42, format:"12", description:"????" })
	@Unimplemented
	function JUMP_CHAIN(a, b) {
	}
	
	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode({ id:0x43, format:"", description:"????" })
	@Unimplemented
	function JUMP_IF_LSB(a, b) {
	}

	/**
	 * 
	 * @param	flag
	 * @param	op
	 * @param	imm
	 * @param	label
	 */
	@Opcode({ id:0x44, format:"1122", description:"Jumps conditionally" })
	@Unimplemented
	function JUMP_IF_LSW(flag, op, imm, label) {
	}
	
	/**
	 * 
	 */
	@Opcode({ id:0x45, format:"", description:"????" })
	@Unimplemented
	function JUMP_SETTINGS() {
	}

	/**
	 * 
	 * @param	index
	 * @param	value
	 */
	@Opcode({ id:0x48, format:"11", description:"???" })
	@Unimplemented
	function SET_MENU_VAR_BITS(index:Int, value:Int) {
		state.menuFlags[index] |= value;
	}

	/**
	 * 
	 * @param	index
	 * @param	value
	 */
	@Opcode({ id:0x49, format:"21", description:"???" })
	@Unimplemented
	function FLAG_SET_BITS(index:Int, value:Int) {
		var byteIndex:Int = Std.int(index / 8);
		var bitIndex:Int = Std.int(index % 8);
		if (value != 0) {
			state.flags[byteIndex] |= (1 << bitIndex);
		} else {
			state.flags[byteIndex] &= ~(1 << bitIndex);
		}
	}
	
	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode({ id:0x4A, format:"21", description:"???" })
	@Unimplemented
	function SET_SEQUENCE(a, b) {
	}
	
	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode({ id:0x4B, format:"21", description:"???" })
	@Unimplemented
	function ADD_OR_RESET_LSB(a, b) {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode( { id:0x4C, format:"21", description:"???" } )
	@Unimplemented
	function ADD_OR_RESET_LSW(a, b) {
	}
	
	/**
	 * 
	 * @param	a
	 * @param	b
	 */
	@Opcode( { id:0x4D, format:"11", description:"???" } )
	@Unimplemented
	function SET_SET(a:Int, b:Int):Void {
	}

	/**
	 * 
	 * @param	done
	 * @param	name
	 * @param	_always_0
	 */
	@Opcode( { id:0x52, format:"<s1", description:"Loads a script and starts executing it" } )
	@Unimplemented
	function SCRIPT(done:Void -> Void, name:String, _always_0:Int) {
		Log.trace("-----------------------------------------------------------------------------");
		dat.loadAsync(name, function():Void {
			done();
		});
	}

	/**
	 * 
	 * @param	y
	 * @param	x
	 * @param	_ff
	 */
	@Opcode({ id:0x53, format:"111", description:"Ani play" })
	@Unimplemented
	function SAVE_SYS_FLAG(y, x, _ff) {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 */
	@Opcode({ id:0x54, format:"212", description:"???" })
	@Unimplemented
	function JUMP_COND_SYS_FLAG(a, b, c) {
	}

	/**
	 * 
	 * @param	done
	 * @param	name
	 * @param	loop
	 */
	@Opcode({ id:0x61, format:"<s2", description:"Plays a midi file" })
	@Unimplemented
	function MUSIC_PLAY(done:Void -> Void, name:String, loop:Int):Void {
		MUSIC_STOP(function():Void {
			game.midi.getBytesAsync(PathUtils.addExtensionIfMissing(name, "mid").toUpperCase(), function(bytes:ByteArray) {
				var sound:Sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes, bytes.length);
				game.musicChannel = sound.play();
				done();
			});
		});
	}

	/**
	 * 
	 */
	@Opcode({ id:0x62, format:"", description:"???" })
	@Unimplemented
	function UNKNOWN_62() {
	}

	/**
	 * 
	 */
	@Opcode( { id:0x63, format:"<", description:"Music stop" } )
	@Unimplemented
	function MUSIC_STOP(done:Void -> Void) {
		if (game.musicChannel != null) {
			game.musicChannel.stop();
			game.musicChannel = null;
		}
		Timer.delay(done, 10);
	}
	
	/**
	 * 
	 * @param	name
	 */
	@Opcode( { id:0x66, format:"s", description:"Plays a sound" } )
	@Unimplemented
	function SOUND_PLAY(name:String):Void {
	}

	/**
	 * 
	 */
	@Opcode( { id:0x67, format:"", description:"???" } )
	@Unimplemented
	function SOUND_STOP():Void {
	}

	/**
	 * 
	 * @param	textBA
	 */
	@Opcode({ id:0x70, format:"?", description:"Put text (dialog)" })
	@Unimplemented
	function PUT_TEXT_DIALOG(textBA:ByteArray) {
		if (state.textVisible) {
			
		}
	}

	/**
	 * 
	 * @param	x
	 * @param	y
	 * @param	color
	 * @param	text
	 */
	@Opcode( { id:0x71, format:"221s", description:"Put text (y, x, ?color?, text, ??)" } )
	@Unimplemented
	function PUT_TEXT_AT_POSITION(x:Int, y:Int, color:Int, text:String) {
	}

	/**
	 * 
	 * @param	visible
	 */
	@Opcode({ id:0x72, format:"b", description:"???" })
	@Unimplemented
	function SET_DIALOG_TEXT_VISIBLE(visible:Bool):Void {
		state.textVisible = visible;
	}

	/**
	 * 
	 * @param	v
	 */
	@Opcode({ id:0x73, format:"1", description:"???" })
	@Unimplemented
	function UNKNOWN_73(v) {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 */
	@Opcode({ id:0x75, format:"111", description:"???" })
	@Unimplemented
	function UNKNOWN_75(a, b, c) {
	}

	/**
	 * 
	 * @param	a
	 * @param	b
	 * @param	c
	 * @param	d
	 * @param	e
	 */
	@Opcode({ id:0x82, format:"22221", description:"????" })
	@Unimplemented
	function SET_TEXT_WINDOW_RECTANGLE(x1:Int, y1:Int, x2:Int, y2:Int, _unk:Int):Void {
		var rect:Rectangle = new Rectangle(x1, y1, x2 - x1, y2 - y1);
	}
	
	/**
	 * 
	 * @param	done
	 * @param	time
	 */
	@Opcode({ id:0x83, format:"<2", description:"????" })
	@Unimplemented
	function DELAY_83(done:Void -> Void, time:Int):Void {
		game.delay(done, time);
	}

	/**
	 * 
	 * @param	file
	 * @param	_0
	 */
	@Opcode({ id:0x84, format:"s1", description:"Interface (0x84)" })
	@Unimplemented
	function INTERFACE2(file:String, _0:Int):Void {
	}
	
	/**
	 * 
	 */
	@Opcode({ id:0x85, format:"", description:"" })
	@Unimplemented
	function UNKNOWN_85():Void {
	}

	/**
	 * 
	 * @param	x
	 * @param	y
	 */
	@Opcode({ id:0x86, format:"22", description:"" })
	@Unimplemented
	function SET_PUSH_BUTTON_POSITION(x:Int, y:Int):Void {
	}

	/**
	 * 
	 * @param	file
	 * @param	_0
	 */
	@Opcode({ id:0x87, format:"s1", description:"Interface (0x87)" })
	@Unimplemented
	function INTERFACE3(file:String, _0:Int):Void {
	}

	/**
	 * 
	 * @param	done
	 * @param	time
	 */
	@Opcode( { id:0x89, format:"<2", description:"Delay" } )
	@Unimplemented
	function DELAY_89(done:Void -> Void, time:Int):Void {
		game.delay(done, time * 1);
	}

	/**
	 * 
	 */
	@Opcode({ id:0x8A, format:"", description:"Updates" })
	@Unimplemented
	function UPDATE():Void {
	}

	/**
	 * 
	 */
	@Opcode({ id:0x91, format:"", description:"Return from a CALL" })
	//@Unimplemented
	function RETURN_LOCAL():Void {
		dat.returnLabel();
	}

	/**
	 * 
	 */
	@Opcode({ id:0x92, format:"", description:"???" })
	@Unimplemented
	function RETURN_SCRIPT():Void {
	}

	/**
	 * 
	 */
	@Opcode({ id:0x94, format:"", description:"???" })
	@Unimplemented
	function SET_LS_RAND():Void {
	}

	/**
	 * 
	 * @param	type
	 * @param	start
	 * @param	count
	 * @param	value
	 */
	@Opcode({ id:0x95, format:"1221", description:"Sets a range of flags" })
	@Unimplemented
	function FLAG_SET_RANGE(type:Int, start:Int, count:Int, value:Int):Void {
		for (flag in start ... start + count) {
			state.setFlag(type, flag, value);
		}
	}

	/**
	 * 
	 * @param	params
	 */
	@Opcode({ id:0x98, format:"?", description:"Sets a flag" })
	//@Unimplemented
	function FLAG_SET(params:ByteArray):Void {
		var flag:Int = params.readUnsignedShort();
		var v1:Int = 0;
		var v2:Int = 0;
		while (params.bytesAvailable > 0) {
			var op:Int = params.readUnsignedByte();
			if (op == 4) break;
			var value:Int = params.readUnsignedShort();
			if (op == 8) value = state.getValR(value);
			if ((params[params.position] & 2) != 0) {
				v1 = switch (op & 7) {
					case 0: value;
					case 1: v1 + value;
					case 2: v1 + value;
					case 3: Std.int(v1 / value);
					case 4: v1;
					default: throw(new Error());
				}
			} else {
				v2 = switch (op & 7) {
					case 0: v2 + value;
					case 1: v2 - value;
					case 2: v2 + v1 * value;
					case 3: v2 + Std.int(v1 / value);
					case 4: v2;
					default: throw(new Error());
				}
			}
		}
		state.setLSW(flag & 0x7FFF, v1 + v2);
	}

	/**
	 * 
	 * @param	s
	 */
	@Opcode({ id:0x99, format:"?", description:"Sets a flag (related)" })
	@Unimplemented
	function JUMP_SET_LSW_ROUTINE(s:ByteArray):Void {
	}

	/**
	 * 
	 * @param	v
	 */
	@Opcode({ id:0x9D, format:"2", description:"????" })
	@Unimplemented
	function UNKNOWN_9D(v:Int):Void {
	}

	/**
	 * 
	 * @param	x1
	 * @param	y1
	 * @param	x2
	 * @param	y2
	 */
	@Opcode({ id:0xAA, format:"2222", description:"????" })
	@Unimplemented
	function DISABLED_SET_AREA_HEIGHT(x1, y1, x2, y2):Void {
	}

	/**
	 * 
	 */
	@Opcode({ id:0xF0, format:"", description:"" })
	@Unimplemented
	function FLASH_IN():Void {
	}

	/**
	 * 
	 */
	@Opcode({ id:0xF1, format:"", description:"" })
	@Unimplemented
	function FLASH_OUT():Void {
	}

	/**
	 * 
	 */
	@Opcode({ id:0xFF, format:"", description:"Exits the game" })
	@Unimplemented
	function GAME_END():Void {
		throw("GAME_END");
	}
}
