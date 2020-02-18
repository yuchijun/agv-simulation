local M3D = Create3DWorld("test", true, 1, 3)
Add3DRect(M3D, 1000, 1000)
AddLight(M3D, -1000,1000,-1000, 3000)
SetCamera(M3D, -50, 30, -50)

local dis = 50          --初始位置
local arrivernd = CreateRandEng(os.time(), "exponential", 20/3600)
local servernd = CreateRandEng(os.time()*2, "exponential", 24/3600)



function NewRMG()
    local rmg = {}
    rmg.frame = LoadObject(M3D, "rmg.3ds", true)--框架
    rmg.trolley = LoadObject(M3D, "trolley.3ds", true)--横梁
    rmg.spreader  = LoadObject(M3D, "spreader.3ds", true)--爪子
    rmg.wirerope  = LoadObject(M3D, "wirerope.3ds", true)--线
    SetParent(rmg.wirerope, rmg.spreader)--线跟着爪子走
    SetParent(rmg.spreader, rmg.trolley)--爪子跟着横梁走
    SetParent(rmg.trolley, rmg.frame)--线，爪子，横梁，框架一起走
    SetPosition(rmg.spreader, 0, 2.42+2.08, 0)
    SetScale(rmg.wirerope, 1, 17.58-2.42-2.08-1.1, 1)--设置线长度
    SetPosition(rmg.wirerope, 0, 1.1, 0)
    
    rmg.state = "idle"--空闲
    rmg.queue = {}--货物队列
    rmg.qmin = 1
    rmg.qmax = 0
    rmg.t0 = GetSimTime()
    rmg.pos = function(t) end
    function rmg.load()--抓取货物
    
        if rmg.queue[rmg.qmin].state == "waiting" then--如果当前有小车停下
            rmg.t0 = GetSimTime()
            --从小车上抓取货物
            --钩子向上，向左，向下
            rmg.pos = function (t)
                rmg.state = "busy"--忙碌状态
                local ds = (t - rmg.t0)*1
                SetPosition(rmg.spreader, 0, 2.42+2.08+ds/20, 0)
                SetScale(rmg.wirerope, 1, 17.58-2.42-2.08-1.1-ds/20, 1)
                if ds>=30 then
                    CreateEvent(t, rmg.leftmove)
                end
            end
                --SetPosition(rmg.spreader, 0, 8, 0)
                --SetPosition(rmg.trolley, -16, 0, 0)
                --SetPosition(rmg.spreader, 0, 2.42+2.08, 0)
                --rmg.ctn = rmg.queue[rmg.qmin].ctn --获取小车上的货物
                --SetParent(rmg.ctn.frame, rmg.spreader)
                --SetPosition(rmg.ctn.frame,0,-2,0)
                --trolley向右
                --SetPosition(rmg.trolley, -8+2.5*(rmg.qmin-1), 0, 0)
            

            
            --抓取货物操作应该在此进行
            
            
            --local t = GetSimTime()--记录当前时间
            --local ts = GetNextRandom(servernd)--获取一个随机时间
            
			
            Print("RMG load at time: ", t)
        end
    end
        
    function rmg.leftmove()
        rmg.t0 = GetSimTime()
        rmg.pos = function (t)
            local ds = (t - rmg.t0)*1
            SetPosition(rmg.trolley, -ds/10, 0, 0)
            if ds>=160 then
                    CreateEvent(t, rmg.down)
            end
        end
    end
    
    function rmg.down()
        rmg.t0 = GetSimTime()
        rmg.pos = function (t)
            local ds = (t - rmg.t0)*1
            SetPosition(rmg.spreader, 0, 6-ds/20, 0)
            SetScale(rmg.wirerope, 1, 17.58-2.42-2.08-1.1-1.5+ds/20, 1)
            if ds>=30 then
                    CreateEvent(t, rmg.rightmove)
            end
        end
    end
    
    function rmg.rightmove()
        rmg.t0 = GetSimTime()
        rmg.ctn = rmg.queue[rmg.qmin].ctn --获取小车上的货物
        SetParent(rmg.ctn.frame, rmg.spreader)
        SetPosition(rmg.ctn.frame,0,-2,0)
        
        --trolley向右
        rmg.pos = function (t)
            local ds = (t - rmg.t0)*1--间隔时间
            SetPosition(rmg.trolley, -17+ds/10, 0, 0)
            
            if ds>=90+(25*(rmg.qmin-1)) then
                rmg.queue[rmg.qmin].leave()--让小车离开
                rmg.queue[rmg.qmin] = nil--清空当前小车位置
                rmg.qmin = rmg.qmin + 1--已运送货物+1
                CreateEvent(t, rmg.unload_down)
            end
        end
    end
    
    --function rmg.unload()
        
        --钩子向下
        --SetPosition(rmg.spreader, 0, 3, 0)
        --SetScale(rmg.wirerope, 1, 17.58-2.42-2.08, 1)
        --SetPosition(rmg.ctn.frame, -8+2.5*(rmg.qmin-2),1,0)
        --SetParent(rmg.ctn.frame, nil)
        
        
        --钩子复位
        --SetPosition(rmg.spreader, 0, 2.42+2.08, 0)
        --SetPosition(rmg.trolley, 0, 0, 0)
        
        --rmg.state = "idle"--设置为空闲状态
        --local t = GetSimTime()--获取当前时间
		--放下货物操作应该在此进行
        --if rmg.qmax >= rmg.qmin then--如果还有小车
        --    CreateEvent(t, rmg.load)--进行下一次抓取
        --end
    --end
    
    function rmg.unload_down()
    
        rmg.t0 = GetSimTime()
        rmg.pos = function (t)
            local ds = (t - rmg.t0)*1
            SetPosition(rmg.spreader, 0, 4.5-ds/20, 0)
            SetScale(rmg.wirerope, 1, 17.58-2.42-2.08-1.1+ds/20, 1)
            if ds>=30 then
                    SetPosition(rmg.ctn.frame, -8+2.5*(rmg.qmin-2),1,0)
                    SetParent(rmg.ctn.frame, nil)
                    CreateEvent(t, rmg.reset_spreader)
            end
        end
        
        
    end
    
    function rmg.reset_spreader()
        rmg.t0 = GetSimTime()
        rmg.pos = function (t)
            local ds = (t - rmg.t0)*1
            SetPosition(rmg.spreader, 0, 3.0+ds/20, 0)
            SetScale(rmg.wirerope, 1, 17.58-2.42-2.08-1.1-1.5+ds/20, 1)
            if ds>=30 then
                    CreateEvent(t, rmg.reset_trolley)
            end
        end
    end
    
    function rmg.reset_trolley()
        rmg.t0 = GetSimTime()
        rmg.pos = function (t)
            local ds = (t - rmg.t0)*1
            SetPosition(rmg.trolley, -9+2.5*(rmg.qmin-1)+ds/10, 0, 0)
            --恢复原来位置
            if ds>=90-25*(rmg.qmin-1) then
                rmg.state = "idle"--设置为空闲状态
                --rmg静止
                rmg.pos = function(t) end
                local t = GetSimTime()--获取当前时间
                if rmg.qmax >= rmg.qmin then--如果还有小车
                    CreateEvent(t, rmg.load)--进行下一次抓取
                end
            end
        end
    end

    
    return rmg--记得返回对象
end--记得加上end语句

local agvs = {}--小车序列
local imin = 1
local imax = 0

function NewAGV(rmg)--新建一个agv，用rmg做参数
    local agv = {}--定义变量
    agv.vehicle = LoadObject(M3D, "agv.3ds", true)
    agv.t0 = GetSimTime()--小车创建时间
    agv.s0 = -dis
    agv.state = "arriving"--到达中状态
    SetPosition(agv.vehicle, -16, 0, agv.s0)
    function agv.arrive()--小车到达的方法
        rmg.qmax = rmg.qmax + 1 --货物+1
        agv.iq = rmg.qmax --iq表示当前货物
        rmg.queue[rmg.qmax] = agv --把小车添加进rmg队列
        Print("AGV arrive at time: ", agv.t0)
        agv.pos = function (t)
            local ds = (t - agv.t0)*1
            local nq = agv.iq - rmg.qmin
            agv.s0 = math.min(agv.s0 + ds, -10*nq)
            SetPosition(agv.vehicle, -16, 0, agv.s0)
            if agv.s0 == 0 then
                agv.state = "waiting"
                agv.pos = function (t) end
                if rmg.state == "idle" then
                    CreateEvent(t, rmg.load)
                end
            end
            agv.t0 = t
        end
    end
    
    function agv.leave()
        agv.state = "leaving"
        agv.t0 = GetSimTime()
        agv.pos = function (t)
            local s = (t - agv.t0)*1
            if s <= dis then
                SetPosition(agv.vehicle, -16, 0, s)
            else
                DelObject(agv.vehicle)
                agvs[imin] = nil
                imin = imin + 1
            end
        end

    end
    
    agv.arrive()
    return agv
end

local rmg1 = NewRMG()

function NewCTN(agv)
    local ctn = {}
    --设置状态
    ctn.frame = LoadObject(M3D,"container.3ds",true)
    LoadTexture(M3D,ctn.frame,"CtnBrown.jpg")
    ctn.t0 = GetSimTime()
    ctn.s0 = -dis
    ctn.state = "arriving"
    agv.ctn = ctn--添加ctn到当前agv上
    SetParent(ctn.frame, agv.vehicle)
    SetPosition(ctn.frame,0,2.5,0)
    
    Print("new CTN at time: ", ctn.t0)
    function ctn.grasp ()
        ctn.state = "grasping"
        Print("CTN grasp at time: ", ctn.t0)
    end
    
    return ctn
end

function GenerateAGV()
    local agv = NewAGV(rmg1)
    local ctn = NewCTN(agv)
    imax = imax + 1
    agvs[imax] = agv
    local t = GetSimTime()
    local ta = GetNextRandom(arrivernd)
    CreateEvent(t + ta, GenerateAGV)
end

local sim_x = 32
local real_t0 = os.clock()

function Refresh()
    local real_t1 = os.clock()
    local real_dt = real_t1 - real_t0
    local sim_dt = real_dt*sim_x
    local sim_t0 = GetSimTime()
    local sim_t1 = sim_t0 + sim_dt
    
    for i = imin, imax do
        agvs[i].pos(sim_t0)
    end
    
    rmg1.pos(sim_t0)

    if Update(M3D) then
        CreateEvent(sim_t1, Refresh)
    end
    real_t0 = real_t1
end

CreateEvent(0, GenerateAGV)
CreateEvent(0, Refresh)
ExecAllEvents()
