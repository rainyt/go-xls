import haxe.crypto.Base64;
#if macro
import sys.io.File;
#end
import haxe.io.Bytes;

class FileMacro {
	macro public static function bindFile(file:String) {
		var bytes = File.getBytes(file);
		var base = Base64.encode(bytes);
		return macro $v{base};
	}
}
