SetKeyDelay -1

global TESTMODE:=1 ;����ģʽ
;==============================================================================================
;                                   ����ȫ�ֺ���
;================================================================================================
printm(str)
{
    if (WinActive("�����ƻ���III")==0){
        if (TESTMODE){
            s:="��ʾ�ַ�" str
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

;���а������ȵ��õĵײ㺯��
global keymap:={}    ;����ÿ����������õĺ���
Presskey(keyname){
    funclist:=keymap[keyname]
    for key,value in funclist{
        value.call()
    }
}

;Ϊ��λע���ɾ���¹��ܣ�o=1ע�ᣬo=0ɾ��
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
;                                  ���Դ���
;====================================================================================
;------------------------
if (TESTMODE==0){      ;|
    goto TESTEND       ;|
}                      ;|
;------------------------
;-------------------������Ϊ���Դ���----------------------------

;---------------------���Դ������----------------------------
;----------
TESTEND: ;|
;----------
;=====================================================================================
;                                    ά����������
;=====================================================================================
global EX_intrvl:=600        ;Ĭ�ϰ�1��ʱ����
global EXMode:=-1            ;����ʣ��ʱ��
global EXScript_defalutOn:=1 ;Ĭ��ά���ű�����

;�ж��Ƿ��ڱ���״̬
inEXmode(){
    x:=845
    y:=1014
    pixelgetcolor c,x,y 
    if (c == 0x1E1E1C){
        return 1
    }
    return 0
}

;�������״̬
EnterEXMode(){
    if (EXMode>0){
        return
    }

    ;��0.5s���ж�6���Ƿ��ڱ���״̬
    i:=0
    ret:=inEXmode()
    while (ret == 0 && i<5){
        sleep 100
        ret:=inEXmode()
        i++
    }

    ;������ǣ���ֹ
    if (ret == 0){
        return
    }
    
    debugmsg("�������״̬")
    ;������ʱ��
    fn:=Func("AutoPress1")
    EXmode:=20000-100*i-500
    send 2
    SetTimer,% fn,%EX_intrvl%

    ;ע������ڼ��������
    EnterAutoLeft() 
    RegisterKey("$LButton","EX_LButtonDown",1)
    RegisterKey("$LButton Up","EX_LButtonUp",1)
    RegisterKey("$+LButton","EX_LButtonDown",1)
    RegisterKey("$+LButton Up","EX_LButtonUp",1)
}

;�˳�����״̬
QuitEXMode(){
    debugmsg("�����˳�����״̬")
    if (ExMode>=0){
        ExMode:=-1
        debugmsg("�˳�����״̬")

        ;�رռ�ʱ��
        fn:=Func("AutoPress1")
        SetTimer,% fn,Off

        ;ע�������ڼ��������
        RegisterKey("$LButton","EX_LButtonDown",0)
        RegisterKey("$LButton Up","EX_LButtonUp",0)
        RegisterKey("$+LButton","EX_LButtonDown",0)
        RegisterKey("$+LButton Up","EX_LButtonUp",0)     
        sleep 50  
        QuitAutoLeft()
    }
}

;�Զ���1
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

;�����ڼ��Զ����
global autoleftmode:=0
EnterAutoLeft(){
    if (GetKeyState("shift","P")==0){
        debugmsg("���ⰴ��shift")
        send {shift down}
    }
    send {Lbutton down}
    RegisterKey("$shift up","donothing",1)

}

;�˳������ڼ��Զ����
QuitAutoLeft(){
    if (GetKeyState("shift","P")==0){
        send {shift up}
    }
    sleep 10
    send {Lbutton up}
    RegisterKey("$shift up","donothing",0)
}

;�����ڼ��������¼�
EX_LButtonDown(){
    debugmsg("�����ڼ��������")
    QuitAutoLeft()
    sleep 10
    send {Lbutton down}
}

EX_LButtonUp(){
    debugmsg("�����ڼ�����ɿ�")
    send {Lbutton Up}
    sleep 10
    EnterAutoLeft()
}

;����ά���ű�
OpenEXFunc(){
    global EXScript_state:=1
    printm("����ά���ű�")
    RegisterKey("~4","EnterEXMode",1)
    RegisterKey("~m","QuitEXMode",1)
    RegisterKey("~esc","QuitEXMode",1)
    RegisterKey("~alt","QuitEXMode",1)
    RegisterKey("~+m","QuitEXMode",1)
    RegisterKey("~+esc","QuitEXMode",1)
    RegisterKey("~+alt","QuitEXMode",1)

}

;�ر�ά���ű�
CloseEXFunc(){
    global EXScript_state:=0
    printm("�ر�ά���ű�")
    RegisterKey("~4","EnterEXMode",0)
    RegisterKey("~m","QuitEXMode",0)
    RegisterKey("~esc","QuitEXMode",0)
    RegisterKey("~alt","QuitEXMode",0)
    RegisterKey("~+m","QuitEXMode",0)
    RegisterKey("~+esc","QuitEXMode",0)
    RegisterKey("~+alt","QuitEXMode",0)
}

;�л�ά���ű�
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
    debugmsg("��⵽shift�ɿ�")
}

RegisterKey("~shift up","shiftup1",1)
RegisterKey("f4","ToggleEXFunc",1)
;===============================================
;���ٻسǣ����ͺ��л�
global qs_on:=0      ;���ٴ���
global qs_num:=4     ;��ʼ��������

;�л�����һ������
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

;���ؿ����л�
toggleqswitch(){
    static mymode:=0
    if (mymode==0){
        mymode:=1
        printm("�����л���������ע�ⴰ��˳���Ƿ���ȷ")
        RegisterKey("#tab","qswitch",1)
    }
    else{
        mymode:=0
        printm("�����л��ر�")
        RegisterKey("#tab","qswitch",0)
    }
}

;���ٴ��������2
;�ӳ���ͷ��λ�ó�ʼʱһ�������2������ν�����Ϸ����ܸı�
teleport2player2(){
    mousemove 60,250
    send {Rbutton}
    mousemove 100,400
    send {Lbutton}
}

;���ٻس�
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

;���˿��ٴ��������2
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

;�������������Ŀ
global qs_setmode:=0 ;��������״̬
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
    str:="��ǰ�����ĿΪ" qs_num
    printm(str)  
}

Resetqs_num(){
    qs_setmode:=1
    RegisterKey("2","qs_num2",1)
    RegisterKey("3","qs_num3",1)
    RegisterKey("~4","qs_num4",1)  
    printm("�������µ������Ŀ")  
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
;ˢ�½ű�����״̬
return
f5::
    run ����III.ahk
return


