import haxe.crypto.Base64;
import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.system.Capabilities;
import flash.events.ProgressEvent;
import flash.events.NativeProcessExitEvent;
import flash.Vector;
import flash.desktop.NativeProcessStartupInfo;
import flash.desktop.NativeProcess;
import haxe.Json;
import flash.filesystem.FileStream;
import flash.filesystem.File;

class As3Tools {
	/**
	 * EXE的数据
	 */
	private static var exeBytes:String = FileMacro.bindFile("go-xls.exe");

	/**
	 * MAC的数据
	 */
	private static var macBytes:String = FileMacro.bindFile("go-xls");

	static function main() {
		jsonToXlsx([["1", "2", "3"], ["2", "3", "4"]], File.applicationDirectory.resolvePath("testfile.xlsx"), APPEND, () -> {
			trace("执行完成");
		});
	}

	/**
	 * 将执行文件缓存一份到本地
	 * @param data 
	 * @param saveFile 
	 */
	static function saveTemprun(data:String, saveFile:String):Void {
		var bytes = Base64.decode(data);
		var file = new File(File.applicationDirectory.resolvePath(saveFile).nativePath);
		if (file.exists) {
			return;
		}
		var strem:FileStream = new FileStream();
		strem.open(file, WRITE);
		for (i in 0...bytes.length) {
			strem.writeByte(bytes.get(i));
		}
		strem.close();
	}

	/**
	 * 将Json转换为Xlsx
	 * @param data 
	 * @param saveFile 
	 */
	public static function jsonToXlsx(data:Dynamic, saveFile:File, type:WirteType, cb:Void->Void):Void {
		var file = new File(File.applicationDirectory.resolvePath("temp.json").nativePath);
		// var _savefile = new File(File.applicationDirectory.resolvePath(saveFile).nativePath);
		var _savefile = new File(saveFile.nativePath);
		var strem:FileStream = new FileStream();
		trace("save temp.json file:", file.nativePath);
		strem.open(file, WRITE);
		var jsonData = Json.stringify(data);
		strem.writeUTFBytes(jsonData);
		strem.close();
		// 然后调用exe接口
		var native:NativeProcess = new NativeProcess();
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		var command = "temprun_001";
		if (Capabilities.os.indexOf("Win") != -1) {
			saveTemprun(exeBytes, command + ".exe");
			nativeProcessStartupInfo.executable = new File(File.applicationDirectory.resolvePath(command + ".exe").nativePath);
		} else {
			saveTemprun(macBytes, command);
			// 赋能权限
			nativeProcessStartupInfo.executable = new File(File.applicationDirectory.resolvePath(command).nativePath);
		}
		var args = new Vector<String>();
		args.push("--json");
		args.push(file.nativePath);
		args.push("--out");
		args.push(_savefile.nativePath);
		if (type == APPEND) {
			args.push("--append");
		}
		trace("执行参数：", args);
		nativeProcessStartupInfo.arguments = args;
		native.start(nativeProcessStartupInfo);
		native.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, (e) -> {
			trace(native.standardOutput.readUTFBytes(native.standardOutput.bytesAvailable));
		});
		native.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, (e) -> {
			trace(native.standardError.readUTFBytes(native.standardError.bytesAvailable));
		});
		native.addEventListener(NativeProcessExitEvent.EXIT, (e) -> {
			trace("执行结束");
			cb();
		});
	}
}

/**
 * 写入方式
 */
enum WirteType {
	APPEND; // 追加
	WRITE; // 覆盖
}
