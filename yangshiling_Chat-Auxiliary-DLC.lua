local Lib = require('Huaji Lib').load()
DLC_CA_version = "1.0.1"
--初始化开始
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
    ch = chshop[selected]
    price = tonumber(chshop[selected+1])
    if rdMoney(name,price) then
    Lib:fw(DLC_CA_luapath .. name .. ".list",ch,2) 
    sendText(name,"成功购买称号".. ch)
    else
    sendText(name,"你没有这么多钱")
 end
end


    
print("称号管理系统 " .. DLC_CA_version .. "|" .. DLC_CA_path .. ">>")