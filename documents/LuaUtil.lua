--[[
CREATED:     2017.05.20
PURPOSE:     定义lua里用到的工具函数
AUTHOR:      QiuLei
--]]

local _M = LuaUtil or {}
LuaUtil = _M

_M.IntMaxUpper = 4294967296;

-- 创建枚举
function _M.CreateEnumTable(t)
	local enumtable = {}
	local enumindex = 0
	enumtable._reversetable = {}
	enumtable.ToString = function(key)
		local result = enumtable._reversetable[key]
		if result == nil then
			result = tostring(key)
		end
		return result
	end

	local tmp, key, val
	for _, v in ipairs(t) do
		key, val = string.gmatch(v, "([%w_]+)[%s%c]*=[%s%c]*([%w%p%s]+)%c*")()
		if key then
			tmp = "return " .. string.gsub(val, "([%w_]+)", function(x) return enumtable[x] and enumtable[x] or x end)
			enumindex = loadstring(tmp)()
		else
			key = string.gsub(v, "([%w_]+)", "%1");
		end
		enumtable[key] = enumindex
		enumtable._reversetable[enumindex] = key
		enumindex = enumindex + 1
	end
	return enumtable
end

function _M.NegativeIntToUint(num)
	return num + _M.IntMaxUpper;
end

-- 这部分有bug 先干掉
-- -- 把int的二进制按照uint读成number
-- function _M.ReadByUint(num)
--     local t = LuaUtil.NumberToBinary(num);
--     if t[1] == 1 then
--        t[1] = 0;
--     end
--     local str = table.concat( t, "");

--     local result = tonumber(str,2);



--     result = result + 2147483648; -- 2147483648 = 2^31
--     return result;
-- end

-- --Number 转成二进制，存在table中,t[0]是最高位
-- function _M.NumberToBinary(num)
--     if num == 0 then return {0}; end;
--     local t = {};
--     local temp = 0;
--     local shift = 0;
--     while num ~= 0 do
--         shift = bit.rshift(bit.lshift(num,1),1);
--         temp = bit.bxor(num,shift);
--         if temp == 0 then
--             t[#t+1] = 0;
--         else
--             t[#t+1] = 1;
--         end
--         num = bit.lshift(num,1);
--     end
--     return t;
-- end

--字符串转换为bool型
function _M.GetBooleanFromString(boolstr)
	if nil == boolstr then
		return false;
	end

	if string.lower(boolstr) == "true" then
		return true;
	end

	return false;
end

--UCS2字符串转utf8
function _M.UTF16String2UTF8String(utf16str)
	return UTF8Encoding.Encode(UTF16EncodingLE.Decode(utf16str));
end

--UCS2数组转utf8
function _M.UTF16ByteArray2UTF8String(bytearray)
	local utf16str = tolua.tolstring(bytearray);
	return _M.UTF16String2UTF8String(utf16str);
end

--文件是否存在
function _M.FileExists(filePath)
	local file = io.open(filePath, "r")

	if file then file:close() end

	return file ~= nil
end

--加载文件
function _M.LoadFile(filename)
	local file
	if filename == nil then
		file = io.stdin
	else
		local err
		file, err = io.open(filename, "rb")
		if file == nil then
			error(("Unable to read '%s': %s"):format(filename, err))
		end
	end
	local data = file:read("*a")

	if filename ~= nil then
		file:close()
	end

	if data == nil then
		error("Failed to read " .. filename)
	end

	return data
end

--保存文件
function _M.SaveFile(filename, data)
	local file
	if filename == nil then
		file = io.stdout
	else
		local err
		file, err = io.open(filename, "wb")
		if file == nil then
			error(("Unable to write '%s': %s"):format(filename, err))
		end
	end
	file:write(data)
	if filename ~= nil then
		file:close()
	end
end

-- 三元算子
function _M.TernaryOperation(condition, trueret, falseret)
	if condition then
		return trueret;
	end
	return falseret;
end

-- 设置默认值
function _M.SetDefaultValue(var, defaultValue)
	if var == nil then
		return defaultValue;
	else
		return var;
	end
end

--找到table里面所有元素的个数
function _M.GetTableCount(tableData)
	if tableData == nil then
		return 0;
	end
	local count = 0;
	for k, v in pairs(tableData) do
		count = count + 1;
	end
	return count;
end

-- table浅拷贝
function _M.ShadowCopy(object)

	if type(object) ~= "table" then
		return object;
	end

	local result = {}
	for k, v in pairs(object) do
		result[k] = v;
	end

	setmetatable(result, getmetatable(object));

	return result;
end

-- table深拷贝(注意！并不适用于PLoop的对象Clone)
function _M.DeepCopy(object)
	local searchTable = {}

	local function Func(object)
		if type(object) ~= "table" then
			return object
		end
		local newTable = {}
		searchTable[object] = newTable
		for k, v in pairs(object) do
			newTable[Func(k)] = Func(v)
		end

		return setmetatable(newTable, getmetatable(object))
	end

	return Func(object)
end

-- Object深拷贝, 类里不应该有其他类的引用
function _M.DeepCopyToObject(oriObj, toObj)
	for k, v in pairs(oriObj) do
		toObj[k] = _M.DeepCopy(v);
	end
	return toObj;
end

--去掉文件名的后缀
function _M.TrimExtension(fileName)
	if not StringUtil.Contains(fileName, ".") then
		return fileName;
	end
	return string.sub(fileName, 1, StringUtil.LastIndexOf(fileName, ".") - 1);
end

function _M.GetFileName(fullPath, withExtension)
	withExtension = LuaUtil.SetDefaultValue(withExtension, true);
	if not StringUtil.Contains(fullPath, "&") then
		return fullPath;
	end

	local fileName = string.sub(fullPath, StringUtil.LastIndexOf(fullPath, "&") + 1);
	if not withExtension then
		fileName = _M.TrimExtension(fileName);
	end

	return fileName;
end

_M._UserdataNilCacheDic = {};

-- 判断任何值是不是空，由于tolua.isnull性能差，一帧只做一次判空
function _M.IsNil(val, isUseTolua)
    --isUseTolua默认值为nil
    if val == nil then
        return true;
    else
		if isUseTolua then
			local cachedIsNil = _M._UserdataNilCacheDic[val];
			if cachedIsNil == nil then
				-- Debug.LogValue(val, "tolua.isnull val");
				cachedIsNil = tolua.isnull(val);
				_M._UserdataNilCacheDic[val] = cachedIsNil;
			end
			return cachedIsNil;
		end
		return false;
	end
end

-- 在每帧末LateUpdate时清除缓存
function _M._ClearIsNilCache()
	for k, v in pairs(_M._UserdataNilCacheDic) do
		_M._UserdataNilCacheDic[k] = nil;
	end
end

-- 设置表只读, 禁止修改
function _M.SetTableReadonly(luatable)
	if (luatable ~= nil and type(luatable) == "table" and getmetatable(luatable) == nil) then
		local tmptable = luatable
		luatable = {}
		setmetatable(luatable, {__index = tmptable, __newindex = {}})
		return luatable
	end
	Debug.LogError("LuaUtil.SetTableReadonly : param is error .")
	return nil
end

function _M.GetTableKeys(luatable)
	if (luatable ~= nil and type(luatable) == "table") then
		local relst = {}
		local i = 1
		for k, v in pairs (luatable) do
			relst[i] = k
			i = i + 1
		end
		return relst
	end
	Debug.LogError("LuaUtil.GetTableKeys : param is error .")
	return nil
end

function _M.GetTableValues(luatable)
	if (luatable ~= nil and type(luatable) == "table") then
		local relst = {}
		local i = 1
		for k, v in pairs (luatable) do
			relst[i] = v
			i = i + 1
		end
		return relst
	end
	Debug.LogError("LuaUtil.GetTableValues : param is error .")
	return nil
end

-- 返回字符编码数值
function _M.CharToByte(char)
	if (char ~= nil and type(char) == "string") then
		local t = string.byte(char)
		local tp = type(t)
		if (tp == "number") then
			return t
		elseif (tp == "table") then
			return t[1]
		end
	end
	Debug.LogError("LuaUtil.CharToByte : param is error .")
	return - 1
end

-- hour:minute:second格式字符串计算总秒数
function _M.ConverStringToSeconds(timeStr, showErrorLog)
	showErrorLog = LuaUtil.SetDefaultValue(showErrorLog, false);
	if StringUtil.IsNilOrEmpty(timeStr) then
		return - 1;
	end

	local afterStrs = StringUtil.Split(timeStr, ':');
	if afterStrs ~= nil and #afterStrs == 3 then
		local hour = tonumber(afterStrs[1]);
		local minute = tonumber(afterStrs[2]);
		local second = tonumber(afterStrs[3]);
		return hour * 3600 + minute * 60 + second;
	else
		if showErrorLog then
			Debug.LogError("ConverStringToDateTime error, timeStr == " .. timeStr);
		end
		return - 1;
	end
end

-- "18:00:15" 解析该种格式,返回时、分、秒
function _M.ParseTime(timeStr)
	local result = StringUtil.Split(timeStr, ':');

	for i = 1, #result do
		if tonumber(result[i]) == nil then
			Debug.LogError("Time Format ,Error");
			return 0, 0, 0
		end
	end
	-- Hour, Minute, Second
	return tonumber(result[1]), tonumber(result[2]), tonumber(result[3])

end

function _M.ConvertListToString(list)
	local count = list.Count or list.Length or #list;
	local result = count .. " : " .. "[";
	for i = 1, count do
		local each = list[i];
		result = result .. tostring(each);
		if i ~= count then
			result = result .. ", ";
		end
	end
	result = result .. "]";
	return result;
end

function _M.ReadTextToTable(str, tonum)
	tonum = LuaUtil.SetDefaultValue(tonum, false);
	local bytesdata = StringUtil.SplitToLines(str);
	if bytesdata == nil or #bytesdata == 0 then
		Debug.LogError("ReadTextToTable readtext error: " .. tostring(str));
		return nil;
	end

	local dicstr = {};
	for i = 1, #bytesdata do
		local linestr = bytesdata[i];
		if StringUtil.IsNilOrEmpty(linestr) ~= true then
			if string.find(linestr, "//") == nil then
				local startIndex = StringUtil.IndexOf(linestr, "=");
				if startIndex ~= nil then
					local key = StringUtil.Trim(StringUtil.Substring(linestr, 1, startIndex - 1));
					local val = StringUtil.Trim(StringUtil.Substring(linestr, startIndex + 1, #linestr));
					if tonum == true then
						key = tonumber(key);
					end

					if key ~= nil then
						dicstr[key] = val;
					end
				end
			end
		end
	end

	return dicstr;
end

function _M.IgnoreFloatError(num)
	num = string.format("%0.2f", num + 1e-3)
	return tonumber(num)
end

function _M.IsMeetMask(value, mask)
	return bit.band(value, mask) > 0;
end

function _M.IsMeetMaskPos(value, mask)
	return _M.IsMeetMask(value, bit.lshift(1, mask));
end
