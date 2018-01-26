--[[
CREATED:     2017.06.01
PURPOSE:     UE Lua使用PLoop代码规范
AUTHOR:      Qiulei
--]]

----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------1、类声名-------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

--抽象类声名
__DebugAbstract__()
class "AbstractClass" (function(_ENV)
	--加上__DebugRequire__()属性，子类不实现会报错
	__DebugRequire__() 
    function AbstractFuctionName(self, ...)
    end
end)

--普通基类
class "BaseClass" (function(_ENV)

    ----------------------------------------------
    ----------------- Constructor ----------------
    ----------------------------------------------    
    
	__DebugArguments__{ --[[Type]] }
    function BaseClass(self, ...)		
    end

    ----------------------------------------------
    ------------------- Method -------------------
    ----------------------------------------------

    --虚方法，约定重写的标记virtual
    --[[virtual]]
    __DebugArguments__{ --[[Type]] }
    function VirtualFuctionName(self, ...)
    	-- body
    end

end)

--接口
interface "IInterface" (function(_ENV)

	--继承者必须要实现的方法
	__DebugRequire__() 
    function InterfaceName(self, ...)
    end

end)

--标准类
class "StandardClass" (function(_ENV) 	
    --继承基类
	inherit (BaseClass)
	--实现接口
	extend (IInterface)

	--静态方法，加上__DebugStatic__() 属性，用类的实例调用会报错	
	__DebugArguments__{ --[[Type]] }
    __DebugStatic__() function StaticFunctionName(...)
		-- body
	end

    --类中常量定义，常量必须全部大写，_分开
    __DebugType__()
    __DebugStatic__() property "CONST_NAME" { Type = System.Any, Default = System.Any, Set = false }
    
    
    --静态变量，命名必须以s_开头，首字母大写
    __DebugType__()
    __DebugStatic__() property "s_StaticField" { Type = System.Any, Default = System.Any, Set = true}
    
	----------------------------------------------
    ------------------ Property ------------------
    ----------------------------------------------
    
    --公有的成员禁止使用PLoop的property，必须提供Get、Set方法
	function GetPublicField(self) return self._PublicField end
    function SetPublicField(self, val) self._PublicField = val end
    
    ----------------------------------------------
    ----------------- Constructor ----------------
    ----------------------------------------------

    --构造方法，参数根据需求修改，但第一个参数必须是self
    function StandardClass(self, ...)
		Super(self, ...);
		--所有成员变量（包括仅有、私有和保护）都在构造方法里声名和初始化
        --所有成员变量内部约定，都以_开头，首字母大写。禁止外部直接访问，必须封装Get、Set方法
        self._PublicField = {}
		self._ProtectedOrPrivateFieldName = "";	
    end

    ----------------------------------------------
    ------------------- Method -------------------
    ----------------------------------------------

    --公有方法
    __DebugArguments__{ --[[Type]] }
    function PublicFuctionName(self, ...)
    	-- body
    end

    --私有或保护方法，内部约定，一个下划线开头的，是保护方法或私有方法，外部禁止调用
    __DebugArguments__{ --[[Type]] }
    function _PrivateOrProtectedFuctionName(self, ...)
        -- body
    end

    --重写虚方法，约定必须加override注释
	--[[override]]
    __DebugArguments__{ --[[Type]] }
	function VirtualFuctionName(self, ...)
		-- body
	end

	--重写抽象方法，约定必须加override注释
	--[[override]]
	function AbstractFuctionName(self, ...)
		-- body
	end

	--实现接口，约定必须加implement注释
	--[[implement]]
	function InterfaceName(self, ...)
		-- body
	end

end)

--内部类
class "OuterClass" (function(_ENV)
    
    --内部类可以在类内部直接声名，用法和C#一样
    class "InnerClass" (function(_ENV)    

        __DebugArguments__{ }
        function InnerClass(self, ...)
            Super(self, ...);
        end
    
    end)
    
    __DebugArguments__{ }
    function OuterClass(self, ...)
        Super(self, ...);
    end

end)

--使用类
local standClass = StandardClass();
standClass:PublicFuctionName();

----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------2、枚举声名-------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
--所有枚举和常量类必须使用table，禁用PLoop的enum

--所有枚举声名，必须用ENUM_开头

--简单的枚举，和常量一样，全部大写，所有枚举值必须手动写全
ENUM_STANDARD =
{
    ERROR         = - 1,
    NORMAL        = 0,
    FIRST_LOGIN   = 1,
    BACK_SEL_ROLE = 2,
    BACK_TO_LOGIN = 3,
    HOST_GOTO     = 4,
    START_GAME    = 5, 
    CHANGE_LINE   = 6,
};

--复杂枚举用CreateEnumTable来创建，支持自动生成默认值等类C#枚举的写法，并支持ToString方法获取key字符串
ENUM_COMPLEX = LuaUtil.CreateEnumTable
{   
    "DT_NO_COLOR = -1", -- 复杂枚举用单引号定义，才会有上色和跳转
    'DT_INVALID = 0',
    --  1
    'DT_PROPERTY_ADDON',                --  BaseData\附加属性
    'DT_QTE_CONFIG',                    --  BaseData\Config\QTE
    'DT_QTE_PLAYER_MONSTER_INTERACTION_CONFIG', --  BaseData\Config\QTE人怪交互
    'DT_VIP_CONFIG',                    --  BaseData\Config\VIP配置
    'DT_DROP_BY_LEVEL_CONFIG',          --  BaseData\Config\按等级单独掉落配置
    --...
    --...
}
ENUM_COMPLEX.ToString(ENUM_COMPLEX.DT_INVALID); --> DT_INVALID

----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------3、全局Table写法------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
--没有必要用类时(比如提供静态方法的工具类Tool、Util、UEGlobal等)，用普通Table，不要用PLoop提供的Class加一堆静态方法

--用本地_M代替Table名，当需要重命名时，只需做两处改动
--定义时一定要local _M = StandardTable or {}，如果重新加载table，之前的table不会被重定义，原因：
--由于PLoop对它引用的东西都有缓存，用调试命令重新加载文件时，如果不管之前的Table,而是重新生成一个新的，table就不会被重新定义
--所以要在原有的table基础上做修改，而不是重新创建一个新的table
local _M = StandardTable or {}
StandardTable = _M;

_M.member1 = 1;

function _M.GetGame()
end

function _M.GetGameRun()
end

------------------* 注意 *----------------------

--禁止在类内部声名类外部需要访问的普通Table，用类名是访问不到的
class "ClassInnerTable" (function(_ENV)

    InnerTable = { Name = "Mary" }

    function ClassInnerTable(self, ...)
    end

 

end)

--InnerTable是类内部的普通成员，外部无法访问到
print(ClassInnerTable.InterTable.Name); -- error

-- 所以不能直接用C#下习惯的类内部枚举，如果有需求，可以在类外部以类名开头声名枚举，表示与类相关:
-- ENUM_大写类名_大写枚举名
ENUM_CLASS_INNER_TABLE_INNER_TABLE = 
{ 
    NORMAL        = 0,
    FIRST_LOGIN   = 1,
    BACK_SEL_ROLE = 2,
}

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------4、变量名规范-------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
--所有变量名，包括成员变量、局部变量、方法的参数等，要尽量体现参数类型，禁止用首字母缩写

--如果觉得这样写和类名太相近，可酌情缩减，但不允许看到变量名，却不知道这是个什么东西的情况出现
--公有方法名要起的有特色（保证跳转唯一）
--不要都叫Init、GetState等，必须加上自己模块的关键字，比如InitActivity、GetActivityState
function StandardFunction(octetsStream, binaryReader, dlgPanel)
end

-- 基础类型变量名规范：变量名必须要体现变量类型
-- Number : hp, level, windId, 
-- String : playerName, hpDesc, 
-- RawBoolean : isOK, canDo, exist
-- Function : callback, SordFunc

--禁止出现下面这种类型不明确的变量名 : beAttackedAudioMaterial
--要改为
--Number : beAttackedAudioMaterialId or beAttackedAudioMaterialType ...
--String : beAttackedAudioMaterialStr ...

--int64是tolua支持的一个Userdata类型的，这个类型在咱们客户端替换long和ulong等，广泛用于各种Object的ID，对于此类型，约定前缀i64，如下所示：
function CmdAttack(i64Self, i64Target)
end


--禁止这样写，自带混淆
function ForbidFunction(os, br, panel)
end

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------5、数据结构---------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

--数组：普通table
--字典：简单的直接用普通table，如果用普通table满足不了需求，还要进行大量额外处理，（比如GetKeys和GetValues做封装），此时可以用PLoop的Dictionary
--普通列表：PLoop的List
--插入、删除操作非常频繁的列表，考虑用tolua提供的LinkedList（原来是list，但本质是链表，重命名为LinkedList）
--队列和栈：LinkedList

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------6、命名空间---------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
--PLoop提供了命名空间，由于命名空间是用环境实现的，比较复杂，目前只有协议底层、ui底层用到了命名空间，其余跟业务逻辑相关的模块禁用此特性

-- 一、命名空间的声名
--PLoop的命名空间与C#不完全一样，必须要在环境中声名命名空间
--声名一个新环境，后面的空串""是必须的，这样才能引起环境变化(实际是调用了setfenv函数来改变环境)
_ENV = Module     "NameSpace1"    ""
--在新的环境下声名命名空间，命名空间和Module名保持一致（虽然PLoop语法可以让两者不一样，但这样用起来更简单，所以要求一致）
namespace "NameSpace1"

Space1Table = {Msg = "I'm in NameSpace1"}

class "Space1Class" (function(_ENV)

    __DebugArguments__{ }
    function Space1Class(self, ...)
    end
    
    __DebugArguments__{ }
    function XXX(self, ...)
        -- body
    end
    
end)

-- 二、命名空间的使用
-- 1、由PLoop的关键字定义的类型，只要在全局环境_G中import，就可以直接使用
--_G环境下
import "NameSpace1"

local a = Space1Class();
a:XXX();

-- 2、Lua中普通的类型（table、string、number等）在_G中只import，是获取不到的，还需要Module来获取
--_G环境下
local NameSpace1 = Module "NameSpace1"; -- 此处是找到NameSpace1这个table，并不是声名新环境（Module "NameSpace1" ""才是）
print(NameSpace1.Space1Table.Msg);

--可以看到，PLoop的命名空间用法比较奇特，并没有想象中的好用，所以尽量不要用

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------7、__DebugArguments__详解-------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

class "Person" (function(_ENV)

    __DebugArguments__{ }
    function Person(self, ...)
        
    end

end)

class "ClassA" (function(_ENV)

    __DebugArguments__{ }
    function ClassA(self, ...)
    end

    ----------------------------------------------
    ------------------- Method -------------------
    ----------------------------------------------
    --[[
    1、只有用Class等PLoop的关键字定义的类，才可以有__DebugArguments__属性，普通Table的方法不能使用此属性
    2、不用对self规定类型，因此参数类型列表要比实际参数少一个(静态方法除外)
    3、参数类型可以是PLoop的基本类型（见Core.lua 5121行）
    4、参数类型可以是用PLoop的Class定义的类，表示传进来的参数必须是此类型，或此类型的派生类的实例：比如__DebugArguments__{ Person }
    5、如果是由C#注册过来的类，参数类型为_GameObject_（如果没有对应的类型，需要在PLoopArgumentType.lua中定义）
    6、没有原表的table，参数类型为RawTable，比如普通数组
    7、Tolua下定义的类，参数类型为_Vector3、_Color_等（如果没有对应的类型，需要在PLoopArgumentType.lua中定义）
    8、由于加载包时，已经导入PLoop的System，可以直接使用Number，也可以用System.Number
    9、参数检查为bool时，不要用Boolean，要用RawBoolean（Boolean是广义上的bool，false, nil为假，其余全为真；RawBoolean只能是true或false）
    10、参数默认值检查（见【带默认值的方法参数检查】）
    11、可变参数检查（见【变长参数检查】）
    12、（一般用不到）如果需要指定参数是类，而不是对象(类的实例)，可以在类前面加'-'号：比如__DebugArguments__{ -UEDlgPanel }
    --]]
    
    __DebugArguments__{ String, System.Number, Person, _BoxCollider_}
    function Function1(self, name, age, person, boxCollider)
        -- body
    end
    
    --【带默认值的方法参数检查】
    -- Argument(RawBoolean, true)里的'true'表示允许调用方法时，不传第三个参数defaultParam
    __DebugArguments__{String, Argument(RawBoolean, true)}
    function FunctionWithDefaultParam(self, normalParam, defaultParam)        
        defaultParam = LuaUtil.SetDefaultValue(defaultParam, false); --设置参数defaultParam的默认值为false
    end 
    
    --【变长参数检查】
    -- Argument{ Type = Any, Nilable = true, IsList = true } 里Nilable如果为true，允许0个参数;为false，至少要有1个参数
    __DebugArguments__{String, Argument{ Type = Number, Nilable = true, IsList = true }}
    function FunctionWithVariableNumberParam(self, normalParam, ...)    
        local args = {...};
        -- body
    end
    
end)

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------8、结构体定义-------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

-- 结构体也用关键字class声名，但成员变量不用_开头，表示外部可以随意访问
class "StructName" (function(_ENV)

    ----------------------------------------------
    ----------------- Constructor ----------------
    ----------------------------------------------
    
    __DebugArguments__{ }
    function StructName(self)
        
        --这里声名结构体成员（【特殊情况】下可省略）
        self.maleModel = 0; 
        self.femaleModel = 0;
        self.profMask = 0; 
        self.gender = 0; 
        self.dyeingType = 0; 
    end

    ----------------------------------------------
    ------------------- Method -------------------
    ----------------------------------------------
    
    --结构体可以有成员方法，但不会很多
    __DebugArguments__{ }
    function StructFunction(self)
    end
    
    ---------------------------- 【特殊情况】 -------------------
    -- 如果是在一个普通方法中初始化变量，结构体的构造方法里可以不写成员变量的声名
    __DebugArguments__{ _BinaryReader_ }
    function LoadStructData(self, binaryReader)        
        
        self.maleModel = binaryReader:ReadUInt32();
        self.femaleModel = binaryReader:ReadUInt32();
        self.profMask = binaryReader:ReadUInt32();
        self.gender = binaryReader:ReadUInt32();
        self.dyeingType = binaryReader:ReadInt32();
    end
    
end)

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------9、其他注意事项-----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- 1. 禁止用PLoop提供的方法重载，用不同的方法名来代替
-- 2. 正式运行环境中不要使用..来连接字符串（string.contact?），非常低效，调试环境及错误Log时可考虑使用；
-- 3. 数字下标从1开始，尊崇LUA习惯，必要再给table的下标0赋值使用；
-- 4. 任何地方，包括函数内部定义的临时变量，都必须写local标记，不然定义的就是全局变量
-- 5. 禁止对一个变量改变类型
-- 6. 任何一个非Boolean型变量判断真假时，都要显示的写上条件，禁止这样写
    -- 非Boolean型变量禁止此写法， 必须显示的写上判断条件
    if someNotBoolValue then 
    end

-- 7. Boolean判断真假写法推荐：

    --真，推荐写法
    if someBool == true then 
        --do something
    end

    --真，（X）不推荐此写法
    if someBool then 
        --do something
    end

    --假，推荐写法
    if someBool ~= true then 
        --do something
    end

    --假, （X）不推荐此写法
    if not someBool then 
        --do something
    end

    --假, （X）不推荐此写法
    if someBool == false then 
        --do something
    end

-- 8. Lua里没有continue关键字，用if else代替，不要发明各种怪异的写法
-- 9. Lua里没有switch关键字，用if else代替
-- 10. Ploop的Vector3 * 一个系数的方法是vector3在前面，系数在后面，如果倒过来会报错
--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------10、一些解释 -------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- 1、_ENV是5.2声明环境的写法，PLoop为了兼容5.2后面的版本，要求声名类型时，必须加上_ENV，但在5.1下，此变量并不起作用

--[[
sublime text3
自定义代码片断的关键字：
implement
override
abstract - (function),
abstract - (class),
virtual
private
protected
public
super
inherit
extend
static - (function)
static - (property)
const - (property)
System.xxx - (类型定义)
geter
seter
--]]

--------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------ Lua知识库 ---------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- 1、位操作用luajit提供的bit，比如按位与bit.band
-- 2、Lua中Table和C#的Array交互：(Array不用注册到Lua下)
    cs.array = table1 -- 给Array传入table1
    table1 = cs.array:ToTable() -- 读取Array到table1
-- 3、PLoop和C#命名空撞车的问题，如果用C#的System，这样写就好了：_G.System.xx
-- 4、禁止使用local x = ...来取得第一个参数，要用local x = select(1, ...)代替。（因为local x = ...会概率性取到第二个参数，原因未知）
-- 5、参数检查如果不对
-- 6、尾调用不会入栈，一旦有尾调用，栈的信息就不全了，这点不是bug，而是lua的机制
-- 7、userdata判断是否为空不能用userdata ~= nil，应该用tolua.isnull(userdata)

--------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------- Int64转Number -------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
-- 1. 客户端应该避免使用int64类型；
-- 2. 原有的各种Object的int64位的id现在在客户端逻辑中都是Number（值用到了2^52），原有的ObjectState的int64，客户端新写了个BitSet类来标示，更高效；
-- 3. 协议部分，无论是GS还是Del协议，都没有变化，其中的int64字段还是保留不变，后期新增和改动的时候依旧保持原有习惯，服务器需要保证期间所有的int64字段的值（目前除了那个states）都在Number的整数表现范围之内；
-- 4. 具体实现参看OctectsStream和OctectsStreamLE这两个的实现，unmarshal_long等对应接口里做了int64和number之间的转换；
-- 5. 对于有些超过32字节的数值，比如ObjectID，做比特操作的时候原有的bit.band和bit.bor处理不了，新增加了几个C#下的工具接口来处理，参见CSharpUtil中的：BigNumberBitAnd，BigNumberBitOr，BigNumberBitNot
