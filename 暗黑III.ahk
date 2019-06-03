SetKeyDelay 10

global TESTMODE:=0 ;����ģʽ
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

class Module{
    
}
;=====================================================================================
;                                    ά����������
;=====================================================================================
global EX_timer_intrvl:=600    ;Ĭ�ϰ�1��ʱ����
global EX_remain_time:=-1      ;����ʣ��ʱ��
global EX_AutoleftMode:=0
;���ܰ���
global ������:=4


;�ж��Ƿ��ڱ���״̬,�����Կ��ͷֱ��ʲ�ͬ����Ҫ�Լ��޸�
EX_inEXmode(){
    x:=845
    y:=1014
    pixelgetcolor c,x,y 
    if (c == 0x1E1E1C){
        return 1
    }
    return 0
}

;�������״̬
EX_EnterEXMode(){
    if (EX_remain_time>0){
        return
    }
    ;��0.5s���ж�6���Ƿ��ڱ���״̬
    i:=0
    ret:=EX_inEXmode()
    while (ret == 0 && i<5){
        sleep 100
        ret:=EX_inEXmode()
        i++
    }

    ;������ǣ���ֹ
    if (ret == 0){
        return
    }
    debugmsg("�������״̬")

    ;������ʱ��
    fn:=Func("EX_mainTimer")
    EX_remain_time:=20000-100*i-500
    send 2
    SetTimer,% fn,%EX_timer_intrvl%

    ;ע������ڼ��������
    if (EX_AutoLeftMode){
        debugmsg("�������ע�����°���shift�¼�")
        EX_EnterAutoLeft() 
        RegisterKey("$LButton","EX_LButtonDown",1)
        RegisterKey("$LButton Up","EX_LButtonUp",1)
        RegisterKey("$+LButton","EX_LButtonDown",1)
        RegisterKey("$+LButton Up","EX_LButtonUp",1)
    }
}

;�˳�����״̬
EX_QuitEXMode(){
    debugmsg("�����˳�����״̬")
    if (EX_remain_time>=0){
        EX_remain_time:=-1
        debugmsg("�˳�����״̬")

        ;�رռ�ʱ��
        fn:=Func("EX_mainTimer")
        SetTimer,% fn,Off

        ;ע�������ڼ��������
        if (EX_AutoLeftMode){
            debugmsg("ע�������ڼ��������")
            RegisterKey("$LButton","EX_LButtonDown",0)
            RegisterKey("$LButton Up","EX_LButtonUp",0)
            RegisterKey("$+LButton","EX_LButtonDown",0)
            RegisterKey("$+LButton Up","EX_LButtonUp",0)     
            sleep 50  
            debugmsg("�˳�����ע���Զ��������")
            EX_QuitAutoLeft()
        }
    }
}

;��ѭ��
EX_mainTimer(){
    EX_remain_time-=EX_timer_intrvl
    a:="EX_remain_time==" EX_remain_time " keystate=shitf:" GetKeyState("shift") " lbutton:" GetKeyState("Lbutton")
    debugmsg(a)
    if (EX_remain_time<=0){
        EX_remain_time:=0
        EX_QuitEXMode()
        return
    }
    send 1
}

;�����ڼ��Զ����
;�����飬�޷�����shift up�¼���ֻ���ٴΰ���
EX_shiftUp_Problem(){
    debugmsg("���°���shift")
    sleep 10
    send {shift down}
    return
}

EX_EnterAutoLeft(){
    if (GetKeyState("shift","P")==0){
        debugmsg("���ⰴ��shift")
        send {shift down}
    }
    send {Lbutton down}
    debugmsg("ע��shift���°���shift�¼�")
    RegisterKey("$shift up","EX_shiftUp_Problem",1)

}


;�˳������ڼ��Զ����
EX_QuitAutoLeft(){
    if (GetKeyState("shift","P")==0){
        send {shift up}
    }
    sleep 10
    send {Lbutton up}
    debugmsg("ע��shift���°���shift�¼�")
    RegisterKey("$shift up","EX_shiftUp_Problem",0)
}

;�����ڼ��������¼�
EX_LButtonDown(){
    debugmsg("�����ڼ��������")
    EX_QuitAutoLeft()
    sleep 10
    send {Lbutton down}
}

EX_LButtonUp(){
    debugmsg("�����ڼ�����ɿ�")
    send {Lbutton Up}
    sleep 10
    if (EX_remain_time>300){
        a:="�����ڼ�����ɿ���ע�����°���shift�¼� EX_remain_time=" EX_remain_time
        debugmsg(a)
        EX_EnterAutoLeft()
    }
}

;����ά���ű�
OpenEXFunc(){
    global EXScript_state:=1


}

;�ر�ά���ű�
CloseEXFunc(){

}

;�л�ά���ű�
EX_ToggleScript(){
    static script_state:=0
    exkey:="~" ������
    if (script_state==0){
        script_state:=1
        printm("����ά���ű�")
        if (EX_AutoLeftMode){
            printm("�����ڼ��Զ�����ѿ�������f6�ر�")
        }
        else{
            printm("�����ڼ��Զ�����ѹرգ���f6����")
        }
        RegisterKey(exkey,"EX_EnterEXMode",1)
        RegisterKey("~m","EX_QuitEXMode",1)
        RegisterKey("~esc","EX_QuitEXMode",1)
        RegisterKey("~alt","EX_QuitEXMode",1)
        RegisterKey("~+m","EX_QuitEXMode",1)
        RegisterKey("~+esc","EX_QuitEXMode",1)
        RegisterKey("~+alt","EX_QuitEXMode",1)
    }
    else{
        script_state:=0
        printm("�ر�ά���ű�")
        RegisterKey(exkey,"EX_EnterEXMode",0)
        RegisterKey("~m","EX_QuitEXMode",0)
        RegisterKey("~esc","EX_QuitEXMode",0)
        RegisterKey("~alt","EX_QuitEXMode",0)
        RegisterKey("~+m","EX_QuitEXMode",0)
        RegisterKey("~+esc","EX_QuitEXMode",0)
        RegisterKey("~+alt","EX_QuitEXMode",0)
    }
}

EX_ToggleAutoLeftMode(){
    if (EX_AutoLeftMode){
        EX_AutoLeftMode:=0
        printm("�رձ����ڼ��Զ����")

        debugmsg("ע�������ڼ��������")
        RegisterKey("$LButton","EX_LButtonDown",0)
        RegisterKey("$LButton Up","EX_LButtonUp",0)
        RegisterKey("$+LButton","EX_LButtonDown",0)
        RegisterKey("$+LButton Up","EX_LButtonUp",0)     
        sleep 50  
        debugmsg("�˳�����ע���Զ��������")
        EX_QuitAutoLeft()
    }
    else{
        EX_AutoLeftMode:=1
        printm("���������ڼ��Զ����")
    }
}
EX_ToggleScript()  ;Ĭ�Ͽ���ά���ű�
RegisterKey("f4","EX_ToggleScript",1)
RegisterKey("f6","EX_ToggleAutoLeftMode",1)
;=====================================================================================
;                                    ��ɮ
;=====================================================================================
global hm_timer_intrvl:=1000 ;Ĭ�ϼ�ʱ���

;���ܰ���
global ��������:=2
global 쫷���:=3
global �����:=4

;��ѭ��
hm_mainTimer(){
    static ��������_cooldown:=0
    static 쫷���_cooldown:=0

    ��������_cooldown+=hm_timer_intrvl
    if (��������_cooldown>=3000){
        send %��������%
        ��������_cooldown:=0
    }

    쫷���_cooldown+=hm_timer_intrvl
    if (쫷���_cooldown>=5000){
        send %쫷���%
        쫷���_cooldown:=0
    }

    send %�����%
}


hm_ToggleScript(){
    static Hm_script_state:=0
    fn:=Func("hm_mainTimer")
    if (Hm_script_state==0){
        printm("��ɮ�꿪��")
        Hm_script_state:=1
        SetTimer,% fn,%hm_timer_intrvl%
        send %�����% %��������% %쫷���%
    }
    else{
        printm("��ɮ��ر�")
        Hm_script_state:=0
        SetTimer,% fn,off
    }
}

RegisterKey("f3","hm_ToggleScript",1)
;=====================================================================================
;                               ���ٻسǣ����ͺ��л�
;=====================================================================================

global qs_on:=0      ;���ٴ���
global qs_num:=4     ;��ʼ��������

;�л�����һ������
qswitch(){
    i:=1
    send {alt down}
    RegisterKey("alt up","null",1)
    while (i<qs_num){
        sleep 10
        send {tab}
        sleep 10
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


