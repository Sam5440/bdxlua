local Lib = require('Huaji Lib').load()
cdk_path_a = Lib:cd()
cdk_gui = [[type=full,title=CDK使用,cb=cdk_main
type=dropdown,text=礼包,args=[yourcdktable]
type=input,text=输入兑换CDK,placeholder=CDK]]
cdk_path = cdk_path_a .. "\\lua\\cdk\\"
Lib:fw(cdk_path.. "whatcdk.txt","example", 1)
--初始化完成
--qq1102566608
--看说明，不会用群里找我，有空重新写什么
-- 请在群里面下载前置huaji lib
--初始化的时候,请打开随便输入一个cdkey， 初始化哪个就输入哪个
--会在lua/cdk目录下创建一个txt文件，cdk1对应的是gui的第一个选项，cdk2对应的是gui的第2个选项，以此类推
--在文件内复制入你的cdk即可，一行对应一个，每个cdk可以使用一次。

cdkcmd = "c"            --调出cdkgui的指令
yourcdktable = [["cdk1","cdk2","cdk3","cdk4"]]
--像这样，每多一个就是多一行
--cdk给的东西第34行开始改

function cdk_main(name,raw,data)
  --dput(name,"cdkstate","0")
  cdk = raw[2]
  raw[1] = raw[1] + 1
  if cdk == "example" or cdk == "" then 
    cdk = "防止空cdk无限领取"
  sendText(name,"cdk破解成功,牢底坐穿")
  return -1
  end
  cdk_id = "cdk" .. string.format("%d", raw[1])
 -- print(cdk_id)
 ------------Main--------------------------------------------------------------
 --cdkid对应文件，比如第一行就是对应cdk1.txt的文件，以此类推
 --比如你选择第一行，就会搜索cdk1.txt的文件
 if raw[1] == 1 then               --第一行(就是第一个选项)
  cdk_use(cdk_id,name,cdk,"give","clock 1")    --给物品示范
 end
 if raw[1] == 2 then                --第二行(就是第2个选项)
  cdk_use(cdk_id,name,cdk,"money",10000)       --给钱示范
 end

 if raw[1] == 3 then               --第3行(就是第3个选项)
  cdk_use(cdk_id,name,cdk,"give","clock 1")    --给物品示范
 end
 if raw[1] == 4 then                --第4行(就是第4个选项)
  cdk_use(cdk_id,name,cdk,"money",10000)       --给钱示范
 end
 
-----------------------------------------------------------------------------------------
--dput(name,"cdkstate","0")
end























--指令部分
function cdk_command(name,cmd)
  if cmd == cdkcmd then
    
    cdk_gui = string.gsub(cdk_gui, "yourcdktable", yourcdktable)
    Lib:fw(cdk_path_a .. "\\gui\\cdk", cdk_gui, 1)
    GUI(name,"cdk")

    return -1
  end
end
Listen("onCMD","cdk_command")

















function cdk_find(what_cdk,cdk_w)
  cdks = Lib:tfr(cdk_path .. what_cdk .. ".txt")
  for i = 1, #cdks do
    --print(cdks[i])
      if cdk_w == cdks[i] then
          return true
      end
  end
  return false
end
function cdk_use(cdk_id,username,usecdk,cdkmode,cdkthing)
  whatcdk = cdk_id
    if Lib:fr(cdk_path .. whatcdk .. ".txt") == nil then
       Lib:fw(cdk_path .. whatcdk .. ".txt","example",1)
    end
    cdk_r = Lib:fr(cdk_path .. whatcdk .. ".txt")
    if  cdk_find(whatcdk,cdk) then
    cdk_r = string.gsub(cdk_r,usecdk.."\n","")
	  cdk_r = string.gsub(cdk_r,usecdk,"")
    Lib:fw(cdk_path .. whatcdk .. ".txt",cdk_r,1)  
    

    if cdkmode == "money" then
    addMoney(username,cdkthing)          
    elseif cdkmode == "give" then
    runCmd("give ".. username .. " " .. cdkthing)
    end

    sendText(username,"§eCDK使用成功")
    else--if dget(username,"cdkstate") == "0" then
    sendText(username,"§e没有发现该CDK或该CDK已被使用")
    dput(username,"cdkstate","1")
    end
  end
print("Cdk_use  v2.0 Beta 已载入，by：司令 ID:yangshiling, 交流群：1082511385")
