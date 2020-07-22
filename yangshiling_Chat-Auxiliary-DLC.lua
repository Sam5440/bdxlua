local Lib = require('Huaji Lib').load()
DLC_CA_version = "1.0.8"
--初始化开始
--依赖前置-聊天与称号管理lua-和前置文件夹内的前置lua，请到群内下载
--插件会在 lua-Auxiliary文件夹内生成一个a_ch.shop.txt,第一行代表的是称号,第二行代表上一行称号的价格，填写数字就好,第三行代表的也是称号,第四行代表的则是第三行的称号价格,以此类推,商店gui会自动生成,请务必保证填写的行数为双数，单数行是称号，双数行请务必填写一个数字的价格。
--/chlist显示所有可用称号，/chshop显示称号商店，/chlistadd添加某个玩家的可用称号，仅限op
DLC_CA_path = Lib:cd()
DLC_CA_luapath = DLC_CA_path .. "\\lua\\Chat-Auxiliary\\"
DLC_CA_guipath = DLC_CA_path .. "\\gui\\DLC_CA_list"
DLC_CA_shopguipath = DLC_CA_path .. "\\gui\\DLC_CA_shop"
------------------------------------------------GUI动态生成以及监听指令---------------------------------------------------------------------
--初始化GUI
DLC_CA_chlistgui = [[type=simple,cb=DLC_CA_list,title=§4称号管理,content=§3你的称号如下\n
]]
DLC_CA_chshopgui = [[type=simple,cb=DLC_CA_chlistshopadd,title=§4称号购买,content=§3可购买的称号如下\n
]]
DLC_CA_chlistaddgui =[[type=full,cb=DLC_CA_chlistadd,title=添加称号
type=label,text="输入颜色时可用 §6& §r代替"
type=dropdown,text=选择玩家,args=%0
type=input,text=设置]]
Lib:fw(DLC_CA_guipath .. "add", DLC_CA_chlistaddgui, 1)

function DLC_CA_command(name,cmd)
   -- print("you write" .. cmd .. ".")
        if cmd == "chlist" then                                        --称号管理gui生成begin
            Lib:fw(DLC_CA_guipath, DLC_CA_chlistgui, 1)
            chlist = Lib:tfr(DLC_CA_luapath .. name .. ".list")
            --print(chlist[1])
            for i = 1, #chlist do
              chlist[i] = "text=".. chlist[i] .."\n"
              Lib:fw(DLC_CA_guipath,chlist[i],2)    
              end
        GUI(name,"DLC_CA_list")
        end                                                           -- 称号管理gui生成end
        if cmd == "chlistadd" and isOP(name) then                     
            GUI(name,"DLC_CA_listadd")
        end 
        if cmd == "chshop" then
            DLC_CA_chlistshop(name)
        end
  end
  Listen("onCMD","DLC_CA_command")
----------------------------------------------GUI动态生成以及监听指令------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
----------------------------------------------称号管理GUI回调函数（把称号设置一下）---------------------------------------------------
function DLC_CA_list(name,selected,text) 
    chlist = Lib:tfr(DLC_CA_luapath .. name .. ".list",2)
    selected = selected + 1
    CA_setPrefix(name, chlist[selected])
    end
------------------------------------------称号管理GUI回调函数（把称号设置一下）------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-------------------------------------------管理员添加称号-------------(待修改）----------------------------
function DLC_CA_chlistadd(name,rawdata,data,mode)
   -- runCmdAs(name,string.format("w \"%s\" %s",data[1],rawdata[3]))
   rawdata[3] = "["..rawdata[3].."]"
   if rawdata[3] == nil then
    sendText(name,"请不要输入空称号")
   else
   Lib:fw(DLC_CA_luapath .. data[1] .. ".list",rawdata[3] .. "\n",2) 
   end
end
----------------------------------------------------------------------
if Lib:fr(DLC_CA_luapath .. "a_ch.shop.txt") == nil then
    Lib:fw(DLC_CA_luapath.. "a_ch.shop.txt","称号\n价格",1)
end
function DLC_CA_chlistshop(name)
    Lib:fw(DLC_CA_shopguipath, DLC_CA_chshopgui, 1)
    chshop = Lib:tfr(DLC_CA_luapath .. "a_ch.shop.txt")
    --print(chlist[1])
    for i = 1, #chshop do
      if i%2 == 1 then
      chshop[i] = "text=称号:".. chshop[i] .."  "
      Lib:fw(DLC_CA_shopguipath,chshop[i],2) 
      end
      if i%2 == 0 then 
        chshop[i] = "  价格:".. chshop[i] .. "\n"
        Lib:fw(DLC_CA_shopguipath,chshop[i],2) 
      end
    end
    GUI(name,"DLC_CA_shop")
end
function DLC_CA_chlistshopadd(name,selected,text)
    -- runCmdAs(name,string.format("w \"%s\" %s",data[1],rawdata[3]))
    chshop = Lib:tfr(DLC_CA_luapath .. "a_ch.shop.txt")
    selected = selected + 1
    selected = selected*2 - 1
    ch = chshop[selected] .. "\n"
    price = tonumber(chshop[selected+1])
    if rdMoney(name,price) then
    Lib:fw(DLC_CA_luapath .. name .. ".list",ch,2) 
    sendText(name,"成功购买称号".. ch .. "欢迎光~临")
    else
    sendText(name,"没钱?想白嫖？爬")
 end
end


    
print("称号管理系统 " .. DLC_CA_version .. "|" .. DLC_CA_path .. ">>")
