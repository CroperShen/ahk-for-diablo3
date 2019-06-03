SetKeyDelay -1

global TESTMODE:=1 ;测试模式
;==============================================================================================
;                                   定义全局函数
;================================================================================================
printm(str)
{
    if (WinActive("暗黑破坏神III")==0){
        if (TESTMODE){
            s:="显示字符" str
            msgbox %s%
            return
        }
    }
    clipboard:="/c " str
    send {enter}
    sleep 5
    send ^v
    sleep 5
    send {enter}
    sleep 5
}

debugmsg(sz){
    if (TestMode){
        t:=A_hour ":" A_Min ":" A_Sec "." A_MSec "  " sz "`n"
        fileappend %t%,debugmsg.txt
    }
}

;所有按键首先调用的底层函数
global keymap:={}    ;储存每个按键会调用的函数
Presskey(keyname){
    funclist:=keymap[keyname]
    for key,value in funclist{
        value.call()
    }
}

;为键位注册或删除新功能，o=1注册，o=0删除
RegisterKey(keyname,funcname,o){
    fnlist:=keymap[keyname]
    if (fnlist==""){
        if (o==0){
            return
        }
        keymap[keyname]:={}
        fnlist:=keymap[keyname] 
        fn:=Func("Presskey").bind(keyname)
        hotkey,%keyname%,% fn
    }
    if (o==0){
        fnlist.delete(funcname)
        if (fnlist.count() == 0){
            hotkey,%keyname%,off
        }
    }
    else{
        if (fnlist.count() == 0){
           hotkey,%keyname%,on
        }
        fn:=Func(funcname)
        fnlist[funcname]:=fn
    }
}

donothing(){
    debugmsg("do nothing")
    sleep 10
    send {shift down}
    return
}
;====================================================================================
;                                  测试代码
;====================================================================================
;------------------------
if (TESTMODE==0){      ;|
    goto TESTEND       ;|
}                      ;|
;------------------------
;-------------------以下下为测试代码----------------------------

;---------------------测试代码结束----------------------------
;----------
TESTEND: ;|
;----------
;=====================================================================================
;                                    维尔棒棒糖套
;=====================================================================================
global EX_intrvl:=600        ;默认按1的时间间隔
global EXMode:=-1            ;变身剩余时间
global EXScript_defalutOn:=1 ;默认维尔脚本开启

;判断是否处于变身状态
inEXmode(){
    x:=845
    y:=1014
    pixelgetcolor c,x,y 
    if (c == 0x1E1E1C){
        return 1
    }
    return 0
}

;进入变身状态
EnterEXMode(){
    if (EXMode>0){
        return
    }

    ;在0.5s类判断6次是否处于变身状态
    i:=0
    ret:=inEXmode()
    while (ret == 0 && i<5){
        sleep 100
        ret:=inEXmode()
        i++
    }

    ;如果不是，终止
    if (ret == 0){
        return
    }
    
    debugmsg("进入变身状态")
    ;开启计时器
    fn:=Func("AutoPress1")
    EXmode:=20000-100*i-500
    send 2
    SetTimer,% fn,%EX_intrvl%

    ;注册变身期间左键设置
    EnterAutoLeft() 
    RegisterKey("$LButton","EX_LButtonDown",1)
    RegisterKey("$LButton Up","EX_LButtonUp",1)
    RegisterKey("$+LButton","EX_LButtonDown",1)
    RegisterKey("$+LButton Up","EX_LButtonUp",1)
}

;退出变身状态
QuitEXMode(){
    debugmsg("尝试退出变身状态")
    if (ExMode>=0){
        ExMode:=-1
        debugmsg("退出变身状态")

        ;关闭计时器
        fn:=Func("AutoPress1")
        SetTimer,% fn,Off

        ;注销变身期间左键设置
        RegisterKey("$LButton","EX_LButtonDown",0)
        RegisterKey("$LButton Up","EX_LButtonUp",0)
        RegisterKey("$+LButton","EX_LButtonDown",0)
        RegisterKey("$+LButton Up","EX_LButtonUp",0)     
        sleep 50  
        QuitAutoLeft()
    }
}

;自动按1
AutoPress1(){
    EXmode-=EX_intrvl
    a:="EXMode==" EXMode " keystate=shitf:" GetKeyState("shift") " lbutton:" GetKeyState("Lbutton")
    debugmsg(a)
    if (EXmode<=0){
        EXmode:=0
        QuitEXMode()
        return
    }
    send 1
}

;变身期间自动左键
global autoleftmode:=0
EnterAutoLeft(){
    if (GetKeyState("shift","P")==0){
        debugmsg("虚拟按下shift")
        send {shift down}
    }
    send {Lbutton down}
    RegisterKey("$shift up","donothing",1)

}

;退出变身期间自动左键
QuitAutoLeft(){
    if (GetKeyState("shift","P")==0){
        send {shift up}
    }
    sleep 10
    send {Lbutton up}
    RegisterKey("$shift up","donothing",0)
}

;变身期间鼠标左键事件
EX_LButtonDown(){
    debugmsg("变身期间左键按下")
    QuitAutoLeft()
    sleep 10
    send {Lbutton down}
}

EX_LButtonUp(){
    debugmsg("变身期间左键松开")
    send {Lbutton Up}
    sleep 10
    EnterAutoLeft()
}

;开启维尔脚本
OpenEXFunc(){
    global EXScript_state:=1
    printm("开启维尔脚本")
    RegisterKey("~4","EnterEXMode",1)
    RegisterKey("~m","QuitEXMode",1)
    RegisterKey("~esc","QuitEXMode",1)
    RegisterKey("~alt","QuitEXMode",1)
    RegisterKey("~+m","QuitEXMode",1)
    RegisterKey("~+esc","QuitEXMode",1)
    RegisterKey("~+alt","QuitEXMode",1)

}

;关闭维尔脚本
CloseEXFunc(){
    global EXScript_state:=0
    printm("关闭维尔脚本")
    RegisterKey("~4","EnterEXMode",0)
    RegisterKey("~m","QuitEXMode",0)
    RegisterKey("~esc","QuitEXMode",0)
    RegisterKey("~alt","QuitEXMode",0)
    RegisterKey("~+m","QuitEXMode",0)
    RegisterKey("~+esc","QuitEXMode",0)
    RegisterKey("~+alt","QuitEXMode",0)
}

;切换维尔脚本
ToggleEXFunc(){
    global EXScript_state
    if (EXScript_state==0){
        OpenEXFunc()
    }
    else{
        CloseEXFunc()
    }
}

if (EXScript_defalutOn){
    OpenEXFunc()
}

shiftup1(){
    debugmsg("侦测到shift松开")
}

RegisterKey("~shift up","shiftup1",1)
RegisterKey("f4","ToggleEXFunc",1)
;===============================================
;快速回城，传送和切换
global qs_on:=0      ;快速传送
global qs_num:=4     ;初始窗口数量

;切换至下一个窗口
qswitch(){
    i:=1
    send {alt down}
    RegisterKey("alt up","null",1)
    while (i<qs_num){
        sleep 50
        send {tab}
        i++
    }
    RegisterKey("alt up","null",0)
    send {alt up}

}

;开关快速切换
toggleqswitch(){
    static mymode:=0
    if (mymode==0){
        mymode:=1
        printm("快速切换开启，请注意窗口顺序是否正确")
        RegisterKey("#tab","qswitch",1)
    }
    else{
        mymode:=0
        printm("快速切换关闭")
        RegisterKey("#tab","qswitch",0)
    }
}

;快速传送至玩家2
;队长的头像位置初始时一定是玩家2，但多次进退游戏后可能改变
teleport2player2(){
    mousemove 60,250
    send {Rbutton}
    mousemove 100,400
    send {Lbutton}
}

;快速回城
quicktele2town(){
    i:=1
    while (i<qs_num){
        qswitch()
        sleep 100
        send t
        sleep 50
        i++
    }
    qswitch()
}

;多人快速传送至玩家2
quicktele2player(){
    i:=1
    mousegetpos,x,y
    while (i<qs_num){
        qswitch()
        ;sleep 100
        teleport2player2()
        ;sleep 50
        i++
    }
    qswitch()
    mousemove x,y
}

;重新设置玩家数目
global qs_setmode:=0 ;处于设置状态
qs_num2(){
    qs_setnum(2)
}

qs_num3(){
    qs_setnum(3)
}

qs_num4(){
    qs_setnum(4)
}

qs_setnum(i){
    qs_num:=i
    qs_setmode:=0
    RegisterKey("2","qs_num2",0)
    RegisterKey("3","qs_num3",0)
    RegisterKey("~4","qs_num4",0)  
    str:="当前玩家数目为" qs_num
    printm(str)  
}

Resetqs_num(){
    qs_setmode:=1
    RegisterKey("2","qs_num2",1)
    RegisterKey("3","qs_num3",1)
    RegisterKey("~4","qs_num4",1)  
    printm("请输入新的玩家数目")  
    sleep 3000
    if (qs_setmode==1){
        qs_setnum(qs_num)
    }
}
RegisterKey("^+q","Resetqs_num",1)
RegisterKey("^+tab","toggleqswitch",1)
RegisterKey("^t","quicktele2town",1)
RegisterKey("^f","quicktele2player",1)
;===============================================
;刷新脚本运行状态
return
f5::
    run 暗黑III.ahk
return


