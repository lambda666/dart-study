import 'dart:io';//文件和标准输入输出
import 'dart:convert';//utf8编码转换、LineSplitter

import 'package:args/args.dart';

const lineNumberFlag = 'line-number';//行号标志

ArgResults argResults;//保存命令行解析结果

void main(List<String> arguments) //命令行参数会传进main函数中
{
  exitCode = 0;//程序退出码，是一个全局变量？
  final parser = ArgParser()
    ..addFlag(lineNumberFlag, negatable:false, abbr:'n');//设置需要解析的参数，注意两个点号，如果是一个点号，则parser得到的是addFlag()返回的结果而不是一个ArgParser对象

  argResults = parser.parse(arguments);

  List<String> paths = argResults.rest;//剩下不解析的参数，作为文件路径

  dcat(paths, argResults[lineNumberFlag]);

}

Future dcat(List<String> paths, bool showLineNumbers) async
{
  if(paths.isEmpty){
    //没有文件路径，则显示终端输入的内容
    await stdin.pipe(stdout);//pipe有方向吗，能否用stdout.pipe(stdin)，不能，stdout没有pipe方法
  }
  else{
    for(var path in paths){
      int lineNumber = 1;
      Stream lines = File(path)
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());//异步调用
      
      try{
        await for(var line in lines){//lines是“流”，对lines的遍历是异步的
          if(showLineNumbers)
          {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      }catch(_){
        await _handleError(path);
      }
    }
  }
}

Future _handleError(String path) async
{
  if(await FileSystemEntity.isDirectory(path))
  {
    stderr.writeln('error: $path is a directory');
  }
  else{
    exitCode = 2;//异常的退出码
  }
}