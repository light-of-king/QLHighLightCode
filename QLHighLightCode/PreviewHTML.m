//
//  PreviewHTML.m
//  qltest
//
//  Created by King on 2018/12/12.
//  Copyright © 2018 King. All rights reserved.
//

#import "PreviewHTML.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define MAX_SIZE 1024*50
#define MAX_LINE 100
#define MAX_COLUMN 1000
#define bundleID  @"site.xukai.qlhighlightcode"
#define THUMBNAIL_SIZE 1024*10
@implementation PreviewHTML

+ (NSString *)render:(NSURL *)file_url{
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: [file_url path] error: NULL];
    NSString *content = [NSString stringWithContentsOfURL:file_url encoding:NSUTF8StringEncoding error:nil];
    if(attrs.fileSize > MAX_SIZE) {
        NSMutableArray *lines = [NSMutableArray arrayWithArray:[content componentsSeparatedByString:@"\n"]];
        if (lines.count > MAX_LINE) {
            NSArray *thumbnailLines = [lines subarrayWithRange:NSMakeRange(0, MAX_LINE) ];
            content = [thumbnailLines componentsJoinedByString:@"\n"];
        }else{
            //从每行读取前面部分
            for (int i = 0 ; i < lines.count; i++) {
                NSString *line = lines[i];
                lines[i] = [line substringToIndex:MIN(MAX_COLUMN, line.length)];
            }
            content = [lines componentsJoinedByString:@"\n"];
            //从头开始读取少部分数据,thumbnail/preview显示不全,行数较少时,仅显示前面几行
//            NSFileHandle *file= [NSFileHandle fileHandleForReadingAtPath:[file_url path]];
//            NSData *file_data = [file readDataOfLength:MAX_SIZE];
//            _content = [[NSString alloc]initWithData:file_data encoding:NSUTF8StringEncoding];
//            [file closeFile];
        }
    }
    //获取bundle
    NSBundle *bundle = [NSBundle bundleWithIdentifier:bundleID];
    //css文件路径
    NSString *stylePath = [bundle pathForResource:@"style" ofType:@"css"];
    //css样式
    NSString *style = [NSString stringWithContentsOfFile:stylePath encoding:NSUTF8StringEncoding error:nil];
    //js文件路径
    NSString *scriptPath = [bundle pathForResource:@"highlight.pack" ofType:@"js"];
    //js内容
    NSString *script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
    //特殊字符处理
//    content = [content stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
//    content = [content stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
//    content = [content stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
//    content = [content stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
//    content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
//    content = [content stringByRemovingPercentEncoding];
    //创建js上下文
    JSContext *jscontext = [[JSContext alloc]init];
    //执行js
    JSValue *load = [jscontext evaluateScript:script];
    //官方下载的js加载不到全局变量中,这里尝试后发现,JavaScriptCore创建的上下文中,区别于browser和nodejs环境
    //没有window和self之类的全局变量,使用this可以获取全局变量,需要手动打包highlight.pack.js文件
    //或者修改js文件开头的环境判断,修改后如下:
    //typeof window&&window||"object"==typeof self&&self||"object"==typeof this&&this
    //TODO: 加载失败后处理
//    if (![load toBool]) {
//        //没有加载成功
//        return @"";
//    }
//    JSValue *hljs = [[jscontext globalObject] objectForKeyedSubscript:@"hljs"];
//    JSValue *highlightAuto = [hljs objectForKeyedSubscript:@"highlightAuto"];
    //获取自动高亮的js方法
    JSValue *renderTagsFunction = [jscontext evaluateScript:@"hljs.highlightAuto"];
    //对需要处理的文本执行自动高亮操作
    //TODO:根据文件后缀确定code类型,设置语言
    JSValue * renderTagsValue = [renderTagsFunction callWithArguments:@[content]];
    //高亮后的html标签
    NSString *renderString = [[renderTagsValue objectForKeyedSubscript:@"value"] toString];
    //js异常回调
    [jscontext setExceptionHandler:^(JSContext *context, JSValue *exception) {
        NSLog(@"%@",exception.toString);
    }];
    //格式化渲染后的html文件内容
    NSString *html = [NSString stringWithFormat:
                      @"<!DOCTYPE html>\n"
                      "<html lang=\"en\">\n"
                      "<head>\n"
                      "<meta charset=\"utf-8\">\n"
                      "<style>\n"
                      "%@\n"
                      "</style>\n"
                      "</head>\n"
                      "<body>\n"
                      "<pre>\n"
                      "<code>\n"
                      "%@\n"
                      "</code>\n"
                      "</pre>\n"
                      "</body>\n"
                      "</html>",
                       style , renderString];
//    NSLog(@"%@",html);
    return html;
}

@end
