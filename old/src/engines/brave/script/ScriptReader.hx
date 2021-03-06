package engines.brave.script;
import common.script.Instruction2;
import common.ByteArrayUtils;
import common.script.Opcode;
import common.script.ScriptOpcodes;
import haxe.Log;
import flash.errors.Error;

/**
 * ...
 * @author 
 */

class ScriptReader 
{
	public var position:Int;
	public var script:Script;
	private var scriptOpcodes:ScriptOpcodes;

	public function new(script:Script, scriptOpcodes:ScriptOpcodes) 
	{
		this.script = script;
		this.position = 8;
		this.scriptOpcodes = scriptOpcodes;
	}
	
	public function readAllInstructions():Void {
		while (hasMoreInstructions()) {
			var instruction = readInstruction(null);
			Log.trace(instruction);
		}
	}
	
	public function hasMoreInstructions():Bool {
		//return script.data.bytesAvailable > 0;
		return script.data.position < script.data.length;
	}
	
	public function readInstruction(scriptThread:IScriptThread):Instruction2
	{
		script.data.position = position;
		var opcodePosition:Int = position;
		var opcodeId:Int = read2();
		var opcode:Opcode = scriptOpcodes.getOpcodeWithId(opcodeId);
		var parameters:Array<Dynamic> = readFormat(opcode.format, scriptThread);
		position = script.data.position;
		return new Instruction2(script.name, opcode, parameters, opcodePosition, opcodePosition - position);
	}
	
	private function readFormat(format:String, scriptThread:IScriptThread):Array<Dynamic>
	{
		var params = new Array<Dynamic>();

		//Log.trace("readFormat : '" + format + "'");

		for (n in 0 ... format.length) {
			var char:String = format.charAt(n);
			//Log.trace(" : '" + char + "' " + n);
			params.push(readFormatChar(char, scriptThread));
		}
		
		return params;
	}
	
	private function readFormatChar(char:String, scriptThread:IScriptThread):Dynamic
	{
		switch (char) {
			case 's': return readString();
			case 'S': return readStringz();
			case 'L': return read4();
			case '4': return read4();
			case 'v': {
				var index = read2();
				if (scriptThread != null) {
					return scriptThread.getVariable(index);
				} else {
					return 'VARIABLE($index)';
				}
			}
			case 'P': return readParam(scriptThread);
			case '7': return read1();
			case '9': return read1();
			default: {
				throw(new Error('Invalid format \'${char}\''));
			}
		}
	}

	private function readParam(scriptThread:IScriptThread):Dynamic
	{
		var paramType:Int = read1();
		
		switch (paramType) {
			case 0x00: return read1Signed();
			case 0x10: return read1();
			case 0x20: return read2();
			case 0x40: return read4();
			case 0x01:
				var index = read2();
				if (scriptThread != null) {
					return scriptThread.getVariable(index).getValue();
				} else {
					return 'VARIABLE($index)';
				}
			case 0x02:
				var index = read2();
				if (scriptThread != null) {
					return scriptThread.getSpecial(index);
				} else {
					return 'SPECIAL($index)';
				}
			default: throw(new Error('Invalid format ${paramType}'));
		}
	}

	private function readString():String
	{
		var v:Int = read1();
		if (v != 0) throw(new Error("Unimplemented"));
		return readStringz();
	}

	private function readStringz():String
	{
		return StringTools.replace(ByteArrayUtils.readStringz(script.data), "@n;", "\n");
	}

	private function read1():Int
	{
		return script.data.readUnsignedByte();
	}

	private function read1Signed():Int
	{
		//return script.data.readByte();
		var byte:Int = script.data.readUnsignedByte();
		if ((byte & 0x80) != 0) {
			return byte | 0xFFFFFF00;
		} else {
			return byte;
		}
	}

	private function read2():Int
	{
		return script.data.readUnsignedShort();
	}

	private function read4():Int
	{
		return script.data.readUnsignedInt();
	}
}