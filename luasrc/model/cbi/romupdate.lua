require("luci.sys")

m = Map("romupdate", translate("ROM在线升级插件"), translate("ROM升级是一个在线升级固件的程序."))
--这里section 是对应配置文件romupdate里的第一个类型 ‘longin’，可以有多个section
s = m:section(TypedSection, "login", "")
s.addremove = false
s.anonymous = true --定是否显示Section的名称，建议为true

--enable对应配置文件里字段名，0就是默认不选，也就是进入luci界面之后checkbox不勾选，1就是默认勾选
o = s:option(Flag, "enable", translate("启用系统升级"), translate("打勾即启用定时更新固件功能"))
o.default = 0
o.optional = false

week = s:option(ListValue, "week", translate("更新时间"))
week:value(7, translate("Everyday"))
week:value(1, translate("Monday"))
week:value(2, translate("Tuesday"))
week:value(3, translate("Wednesday"))
week:value(4, translate("Thursday"))
week:value(5, translate("Friday"))
week:value(6,translate("Saturday"))
week:value(0,translate("Sunday"))
week.default=0

hour=s:option(Value,"hour",translate("小时 [0~23]"))
hour.datatype = "range(0,23)"
hour.rmempty = false

pass=s:option(Value,"minute",translate("分钟 [0~59]"))
pass.datatype = "range(0,59)"
pass.rmempty = false

luci.sys.call("sh /usr/share/Lenyu-version.sh > /dev/null")
local cloud_version = luci.sys.exec("cat /tmp/cloud_ts_version | cut -d _ -f 1")
local current_version = luci.sys.exec("cat /etc/lenyu_version")
local current_model = luci.sys.exec("jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_'")

--local firmware_type = luci.sys.exec("grep 'DISTRIB_ARCH=' /etc/openwrt_release | cut -d \' -f 2")

button_upgrade_firmware = s:option (Button, "_button_upgrade_firmware", translate("固件升级"),
translatef("点击上方 执行升级 后请耐心等待至路由器重启.") .. "<br><br>当前固件版本: <span style='color: green'>" .. current_version .. "</span><br>云端固件版本: <span style='color: red'>" .. cloud_version .. "</span>")
--.."<br>固件类型: " .. firmware_type
button_upgrade_firmware.inputtitle = translate ("执行升级")
button_upgrade_firmware.write = function()
    luci.sys.call("sh /usr/share/Lenyu-auto.sh -u > /dev/null")
end

local e = luci.http.formvalue("cbi.apply")
if e then
    io.popen("/etc/init.d/romupdate restart")
end

m.reset = false
return m
