
function notice_wp()
 players = oList()
 for i = 1, #players do
    pname = players[i]
    kkk,kkkk,landname = getLandV(getPos(pname))
    landname = delsystem_2(landname)
    --print(landname)                   调试，控制台输出领地主人信息
    --sendText(pname,"§6你进入了"..landname.."§6的领地",5) --带名字的自定义领地  
    if landname == nil then 
      landname = "无"
    end
    sendText(pname,"§6脚下领地:"..landname.."   §3当前余额:"..getMoney(pname),5)
end
end

schedule("notice_wp",1,3)


function delsystem_2(s)  --可以去除system显示为主人的字符串处理函数
  if s ~= nil then
  s = string.gsub(s, ",\"system\"", "")
  s = string.gsub(s, "\",\"", ",")
  return s
  end
end