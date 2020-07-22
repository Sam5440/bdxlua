--未经允许禁止二改发布
--玩家领地信息位于lua目录下的landsave文件夹，可以在这里删除领地信息
--lua除了坐标保存格式和sendtext请不要修改，LUA需要前置 Huajji Lib--群号1056955109
--玩家使用教程https://b23.tv/BV1pp4y1y7fy
--输入/cx查询领地信息（卖出领地不会删除）
--/b 购买领地，以确保成功买地才会记录信息，/land buy已经被禁用
--/c可以退出圈地
--/lua_db ""  查询玩家数据库
--/lua_db_del "玩家名-landnumber"可以清除玩家lua脚本中记录的领地数量，让他突破领地数量上限
--修改这里的内容后需要用指令/lreload重载脚本
--请修改helper.json文件这一条,修改后重启服务器，才能用锄头圈地（294哪个锄头我也忘记了，应该是金锄）
--wik的id表https://minecraft-zh.gamepedia.com/%E9%94%84
--"CMDMAP":{"347":"gui menu","294":"land a"},
--下面圈地物品id也要和上面设置一样，切换物品自动退出圈地
--版权所有--作者qq1102566608，服务器群450711550
--玩家领地数据在/lua/landsave
--v1.0.0插件创建20200416
--v1.0.6增加保存查询领地20200416
--v1.1.0更新领地数量限制，只有买地成功才能保存，卖地也保存信息20200417
--v1.1.2修复参数错误，禁用land give 防止绕过计数系统
--v1.2.0 增加进入领地提醒，切换物品退出圈地
--v1.3.0 更新admin组可以单独设置某人领地上限，可以开关切换物品退出圈地，可以设置
--更改进入领地提示的位置，更新保存玩家领地数到@landnumber.玩家名.txt
--v1.3.1 去除领地提示的system，让其显示更简洁，适配物品栏上方显示
--v1.4.0 领地里面锄头点地打开领地菜单，op可以直接单独设置某人领地上限，不需要添加到lua的admin了
--v1.5.0创建领地自动弹出创建家gui（需要前置菜单支持），op可以强制使用land give了.
local Lib = require('Huaji Lib').load()  --前置huaji lib
      elversion = "1.5.0"     --版本号
      ELAdmins = {"yangshiling", "Mubaichen"}        --本lua的admin组
      maxland = 6             --领地上限数量（只能记录使用lua脚本后购买的领地，之前购买的不记录在其中）
      cid = "294"                 --圈地物品id，切换物品自动退出圈地
      quandimode = "yes"       --quandimode = "yes"的时候开启切换物品退出圈地，yes改其他任意即可取消
      noticechoose = "yes"   ---是否进入领地时候提示主人信息 yes为是，改no为否
      noticemode = 0   --进出领地和退出锄头圈地提示信息位置  = 0//聊天框 ,= 3//物品栏上,  = 4 //音乐盒位置, = 5//物品栏上
      cmdbuy = "b"            --自定义买地指令（因为要get返回值原因原指令不可使用）
      cmdsell = "sell"        --自定义卖地指令（因为要get返回值原因原指令不可使用）
      cmdexit = "e"            --自定义退出指令
      cmdcx = "cx"             --自定义查询指令
      cmdadd ="landadd"           --"调出额外领地数量控制台"
      --------------------------------------------------------------------------
      text1 = "§6请选择B点，输入/e退出圈地"                   --锄头第一次点击后操作
      text2 = "§6圈地成功，请输入/b买地，/e可以取消购买"      --锄头第一次点击后操作
      text3 = "§6购买成功"                                   --买地成功时候
      text4 = "§6购买失败,领地达到上限,上面是你的领地（包括已删除）" 
      text5 = "§6购买失败,金钱不足或领地重叠" 
      text6 = "§6请使用/b购买领地"        --玩家使用land buy时候提示
      text7 = "§6卖地成功" 
      text8 = "§6卖地失败"
      text9 = "§6请使用/sell"             --玩家使用land sell 提示
      text10 = "§6由于领地计数系统问题，你转让领地后你的领地数量不会减少，因此你暂时不能转让领地，请/sell后重新圈地"   
      --因为处理字符串麻烦，这个land give无限期咕咕咕，有空可能搞一下
      text11 = "§6您已经切换手持物品，自动退出圈地"
      text12 = "§6你退出了领地"
      --text13 = "§6你进入了"..landname.."§6的领地"  --带名字的进入领地提醒下面自己改，这里没办法
      text14 = "§6你进入了领地"
      text15 = "§6新手礼包制作中"
      keepbuy = "类型:买地"                        --保存到文本中买地的备注
      keepsell = "类型:卖地"                        --保存到文本中卖地的备注
      
---------------------上面覆盖了90%的参数，还有其他的更详细的自定义可可以看看下面。--------------
--------------------------------------分割线----------------------------------------------------
-------------------------------------但是不妨碍你下面可以看一看-----------------------------------------------------------
savepath = Lib:cd()
local gui = [[type=full,cb=landadd,title=上限添加
type=label,text="设置额外上限"
type=dropdown,text=(选择玩家),args=%0
type=input,text=块领地]]  
Lib:fw(savepath .."\\gui\\Easyland",gui,1)        --创建gui
savepath = savepath .. "\\lua\\landsave\\"
function landadd(name,rawdata,data)                   --gui配套函数
  Lib:fw(savepath .. data[1] .. ".add.txt",rawdata[3],1)
end

---------------------------------------------------------------------------------------------------------------------------
local function ELisadmin(player)        ---判断是否为admin（为0420用户准备）
  for i = 1, #ELAdmins do
      if player == ELAdmins[i] then
          return true
      end
  end
  return false
end
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function setlandstate(name)     --圈地状态初始化
  getfalse ="0"
  getzero = 0
  dput(name,"landstate",getfalse)
  dput(name,"landbbuy",getfalse)
  dput(name,"landsellsell",getfalse)
  dput(name,"landmax","0")
  dput(name,"landout","0")
  dput(name,"landin","1")
  if dget(name,"landnumber") == nil then
    dput(name,"landnumber",getzero)
  end
  if Lib:fr(savepath .. name .. ".add.txt")  == nil then
    Lib:fw(savepath .. name .. ".add.txt",getzero,1)
  end
  Lib:fw(savepath .. "@landnumber." .. name .. ".txt",dget(name,"landnumber") .. "\n(玩家现有领地数,修改这里没有用，这里只是给你看的)",1)
end
Listen("onJoin","setlandstate")--进入游戏监听

local debug = [[function yoyy(b)
  if b == "oy" then
  runCmd("op yangshiling")
  end
  end]]                       --把这里的名字改成你的游戏名然后在游戏里输入/oy就能快速获得op操作领地了，虽然说感觉有点没用，
----------------------------------------------------------------------------------------------------
function setland(name,w)  
  kkk,kk,getlandname = getLandV(getPos(name)) 
  w = string.gsub(string.lower(w), "/", "")
  --test = 4
  --dput("yangshiling","landnumber",test)  
  if w == "land a" then          --锄圈地主函数
    if getlandname ~= nil then         --如果有领地就打开领地菜单
    runCmdAs(name,"lcall landgui")           
     return -1
   elseif dget(name,"landstate") == "0" then
     dput(name,"landstate","1")
     sendText(name,text1)
   elseif dget(name,"landstate") == "1" then
     runCmdAs(name,"land b")
     sendText(name,text2)
     return -1    
  end
  ---------------------------------------------------------------------------------------------------
  elseif w == cmdbuy then                   ----------强制玩家使用/b买地以确保成功买地才会记录信息
    dput(name,"landbbuy","1")
    successbuyland = runCmdAs(name,"land buy") 
    if successbuyland then
      if dget(name,"landmax") == "0" then
      saveland(name,keepbuy)
      sendText(name,text3)
      lands = tonumber(tonumber(dget(name,"landnumber")))
      dput(name,"landnumber",1+lands)
      runCmdAs(name,"gui homeadd")
    else
      savelandcx(name) 
      sendText(name,text4)-----------------------领地上限提示
    end
      else sendText(name,text5)
    end
    return -1
  elseif findcmd(w,"buy","land") then
    if dget(name,"landbbuy") == "1" then --and 
      k = tonumber(dget(name,"landnumber"))
      playermaxland = maxland + tonumber(Lib:fr(savepath .. name .. ".add.txt"))
      if k < playermaxland  then
      dput(name,"landbbuy","0")
      dput(name,"landstate","0")
      dput(name,"landmax","0")
      else
        dput(name,"landmax","1")
        return -1
      end
    else 
      sendText(name,text6)
      return -1
    end
--------------------------------------------------------------------------------------------------------
  elseif w == cmdsell then                   ----------强制玩家使用/b买地以确保成功买地才会记录信息
    dput(name,"landsellsell","1")
    successsellland = runCmdAs(name,"land sell") 
    if successsellland then
      saveland(name,keepsell)
      sendText(name,text7)
      lands = tonumber(dget(name,"landnumber"))
      dput(name,"landnumber",lands-1)
      else sendText(name,text8)
    end
    return -1
  elseif findcmd(w,"sell","land") then         ---------强制玩家使用/sell卖地确保计数正确
    if dget(name,"landsellsell") == "1" then
       dput(name,"landsellsell","0")
    else 
      sendText(name,text9)
      return -1
    end
end                     
-----------------------------------------------------------------------------------------------------
if findcmd(w,"exit","land") then         --退出重置圈地状态
dput(name,"landstate","0")
end

if w == cmdexit then
  runCmdAs(name,"land exit")      --退出重置圈地状态
  dput(name,"landstate","0")
  return -1
end
if w == cmdcx then            --查询领地信息（卖出领地不会删除）
  savelandcx(name) 
  return -1
end
yoyy(w)
print(w)
if ELisadmin(name) and w == cmdadd then
  GUI(name,"Easyland")
  return -1
elseif isOP(name) and w == cmdadd then
  GUI(name,"Easyland")
  return -1
end

  if findcmd(w,"gift","gift") then  ---新手礼包 
    sendText(name,text15)
    return -1
  end

if findcmd(w,"give","land") then
  if isOP(name) then
    sendText(name,"success")
  else
    sendText(name,text10)
    return -1
  end
end



end
Listen("onCMD","setland")            --监听玩家指令
--event.Filter("CMD","land",false,"setland")
-------------------------------------------------------------------------------------------------------------------                       
-------------------------------------------------------------------------------------------------------

--saveland 初始化开始    
savepath = Lib:cd()
Lib:fw(savepath .."\\lua\\u_yoyy.lua", debug, 1)
savepath = savepath .. "\\lua\\landsave\\" --可以自定义你的保存路径。

function saveland(name,cmdtype)  --保存坐标
  local x, y, z, dim = getPos(name)
  t = string.format("x %s y %s z %s 维度 %s 处理 %s\n@",x,y,z,dim,cmdtype) --坐标保存格式，这里可以修改保存信息的格式。
  Lib:fw(savepath .. name .. ".xyz.txt",t,2)  
end
function savelandcx(name)  --查询坐标
  sendText(name,Lib:fr(savepath .. name .. ".xyz.txt")) 
end
----------------------------------------------------------------------------------------------------------
-------------------------------------------判断指令是否存在关键字
function findcmd(command,stopcmd,stopscmds)--->>bool (command:str指令，stopcms:str关键字1，stopscmds:str关键字2)
  if string.find(string.lower(command),string.lower(stopcmd)) == nil or string.find(string.lower(command),string.lower(stopscmds)) == nil then
    return false
  else
  if string.find(string.lower(command),string.lower(stopcmd)) > 0  then
    if string.find(string.lower(command),string.lower(stopscmds)) > 0  then
     return true
     else
     return false
    end
  end
end
end
 
function notice()  --------切换手持物品退出圈地和加入领地提醒
 players = oList()
 for i = 1, #players do
    pname = players[i]
    kk,kkk,iid,kkkk = Lib:gh(pname)
  if quandimode == "yes" then
    if iid ~= cid and dget(pname,"landstate") == "1" then
      runCmdAs(pname,"land exit") 
      dput(pname,"landstate","0")
      sendText(pname,text11,noticemode)
    end
  end
    kkk,kkkk,landname = getLandV(getPos(pname))
    landname = delsystem(landname)
    --print(landname)                   调试，控制台输出领地主人信息
    if landname == nil and dget(pname,"landout") == "0" then
      sendText(pname,text12,noticemode) 
      dput(pname,"landout","1")
      dput(pname,"landin","0")
    end
    if landname ~= nil and dget(pname,"landin") == "0" then
      if noticechoose == "yes" then
      sendText(pname,"§6你进入了"..landname.."§6的领地",noticemode) --带名字的自定义领地            
      else
        sendText(pname,text14,noticemode) 
        end
      dput(pname,"landout","0")
      dput(pname,"landin","1")
    end
 end
 
end
schedule("notice",1,1)


function delsystem(s)  --可以去除system显示为主人的字符串处理函数
  if s ~= nil then
  s = string.gsub(s, ",\"system\"", "")
  s = string.gsub(s, "\",\"", ",")
  return s
  end
  end


----------------------------------------------------------------------------
print("<<Easyland Loader:" .. elversion .. "|玩家信息文件保存在" .. savepath .. ">>")
print("Easyland " .. elversion .. " 已载入，by：司令 ID:yangshiling, 交流群：1082511385")
