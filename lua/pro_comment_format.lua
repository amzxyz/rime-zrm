--由于comment_format不管你的表达式怎么写，只能获得一类输出，导致的结果只能用于一个功能类别
--如果依赖lua_filter载入多个lua也只能实现一些单一的、不依赖原始注释的功能，有的时候不可避免的发生一些逻辑冲突
--所以此脚本专门为了协调各式需求，逻辑优化，实现参数自定义，功能可开关，相关的配置跟着方案文件走，如下所示：
--将如下相关位置完全暴露出来，注释掉其它相关参数--
--  comment_format: {comment}   #将注释以词典字符串形式完全暴露，通过pro_comment_format.lua完全接管。
--  spelling_hints: 10          # 将注释以词典字符串形式完全暴露，通过pro_comment_format.lua完全接管。
--在方案文件顶层置入如下设置--
--#Lua 配置: 超级注释模块
--pro_comment_format:                     # 超级注释，子项配置 true 开启，false 关闭
--  corrector: true                       # 启用错音错词提醒，例如输入 geiyu 给予 获得 jǐ yǔ 提示
--  corrector_type: "{comment}"           # 新增一个提示类型，比如"【{comment}】" 

--  fuzhu_code: true                      # 启用辅助码提醒，用于辅助输入练习辅助码，成熟后可关闭（预留型开关）
--  candidate_length: 1                   # 候选词辅助码提醒的生效长度，0为关闭      
--  fuzhu_type: "zrm"                     # 用于匹配对应的辅助码类型

-- #########################
-- # 错音错字提示模块 (Corrector)
-- #########################
local CR = {}
function CR.init(env)
    local config = env.engine.schema.config
    local delimiter = config:get_string('speller/delimiter')
    if delimiter and #delimiter > 0 and delimiter:sub(1,1) ~= ' ' then
        env.delimiter = delimiter:sub(1,1)
    end
    env.settings.corrector_type = env.settings.corrector_type:gsub('^*', '')
    CR.style = config:get_string("pro_comment_format/corrector_type") or '{comment}'
    CR.corrections = {
        -- 错音
        ["hp dp"] = { text = "馄饨", comment = "hún tun" },
        ["vu jc"] = { text = "主角", comment = "zhǔ jué" },
        ["jc se"] = { text = "角色", comment = "júe sè" },
        ["pi sa"] = { text = "比萨", comment = "bǐ sà" },
        ["ii pi sa"] = { text = "吃比萨", comment = "chī bǐ sà" },
        ["pi sa bn"] = { text = "比萨饼", comment = "bǐ sà bǐng" },
        ["uv fu"] = { text = "说服", comment = "shuō fú" },
        ["dk hh"] = { text = "道行", comment = "dào héng" },
        ["mo yh"] = { text = "模样", comment = "mú yàng" },
        ["yb mo yb yh"] = { text = "有模有样", comment = "yǒu mú yǒu yàng" },
        ["yi mo yi yb"] = { text = "一模一样", comment = "yī mú yī yàng" },
        ["vd mo zo yh"] = { text = "装模作样", comment = "zhuāng mú zuò yàng" },
        ["rf mo gb yh"] = { text = "人模狗样", comment = "rén mú góu yàng" },
        ["mo bj"] = { text = "模板", comment = "mú bǎn" },
        ["aa mi to fo"] = { text = "阿弥陀佛", comment = "ē mí tuó fó" },
        ["na mo aa mi to fo"] = { text = "南无阿弥陀佛", comment = "nā mó ē mí tuó fó" },
        ["nj wu aa mi to fo"] = { text = "南无阿弥陀佛", comment = "nā mó ē mí tuó fó" },
        ["nj wu ee mi to fo"] = { text = "南无阿弥陀佛", comment = "nā mó ē mí tuó fó" },
        ["gz yu"] = { text = "给予", comment = "jǐ yǔ" },
        ["bn lh"] = { text = "槟榔", comment = "bīng láng" },
        ["vh bl vi"] = { text = "张柏芝", comment = "zhāng bó zhī" },
        ["tg mj"] = { text = "藤蔓", comment = "téng wàn" },
        ["ns th"] = { text = "弄堂", comment = "lòng táng" },
        ["xn kr ti ph"] = { text = "心宽体胖", comment = "xīn kūan tǐ pán" },
        ["ml yr"] = { text = "埋怨", comment = "mán yuàn" },
        ["xu yu wz ue"] = { text = "虚与委蛇", comment = "xū yǔ wēi yí" },
        ["mu na"] = { text = "木讷", comment = "mù nè" },
        ["du le le"] = { text = "独乐乐", comment = "dú yuè lè" },
        ["vr le le"] = { text = "众乐乐", comment = "zhòng yuè lè" },
        ["xp ma"] = { text = "荨麻", comment = "qián má" },
        ["qm ma vf"] = { text = "荨麻疹", comment = "xún má zhěn" },
        ["mo ju"] = { text = "模具", comment = "mú jù" },
        ["ck vi"] = { text = "草薙", comment = "cǎo tì" },
        ["ck vi jy"] = { text = "草薙京", comment = "cǎo tì jīng" },
        ["ck vi jm"] = { text = "草薙剑", comment = "cǎo tì jiàn" },
        ["jw py ao"] = { text = "贾平凹", comment = "jià píng wā" },
        ["xt fo lj"] = { text = "雪佛兰", comment = "xuě fú lán" },
        ["qd jn"] = { text = "强劲", comment = "qiáng jìng" },
        ["ts ti"] = { text = "胴体", comment = "dòng tǐ" },
        ["li ng kh dy"] = { text = "力能扛鼎", comment = "lì néng gāng dǐng" },
        ["ya lv jd"] = { text = "鸭绿江", comment = "yā lù jiāng" },
        ["da fu bm bm"] = { text = "大腹便便", comment = "dà fù pián pián" },
        ["ka bo zi"] = { text = "卡脖子", comment = "qiǎ bó zi" },
        ["vi vg"] = { text = "吱声", comment = "zī shēng" },
        ["ij ho"] = { text = "掺和", comment = "chān huo" },
        ["ij he"] = { text = "掺和", comment = "chān huo" },
        ["vg vi"] = { text = "称职", comment = "chèn zhí" },
        ["lo vi ff"] = { text = "螺蛳粉", comment = "luó sī fěn" },
        ["tc hr"] = { text = "调换", comment = "diào huàn" },
        ["tk xy vj"] = { text = "太行山", comment = "tài háng shān" },
        ["jx si di li"] = { text = "歇斯底里", comment = "xiē sī dǐ lǐ" },
        ["nr he"] = { text = "暖和", comment = "nuǎn huo" },
        ["mo ly ld ke"] = { text = "模棱两可", comment = "mó léng liǎng kě" },
        ["pj yh hu"] = { text = "鄱阳湖", comment = "pó yáng hú" },
        ["bo jy"] = { text = "脖颈", comment = "bó gěng" },
        ["bo jy er"] = { text = "脖颈儿", comment = "bó gěng er" },
        ["jx va"] = { text = "结扎", comment = "jié zā" },
        ["hl uf wz"] = { text = "海参崴", comment = "hǎi shēn wǎi" },
        ["hb pu"] = { text = "厚朴", comment = "hòu pò " },
        ["da wj ma"] = { text = "大宛马", comment = "dà yuān mǎ" },
        ["ci ya"] = { text = "龇牙", comment = "zī yá" },
        ["ci ve ya"] = { text = "龇着牙", comment = "zī zhe yá" },
        ["ci ya lx zv"] = { text = "龇牙咧嘴", comment = "zī yá liě zuǐ" },
        ["tb pi xt"] = { text = "头皮屑", comment = "tóu pi xiè" },
        ["lw an ui"] = { text = "六安市", comment = "lù ān shì" },
        ["lw an xm"] = { text = "六安县", comment = "lù ān xiàn" },
        ["an hv ug lq an ui"] = { text = "安徽省六安市", comment = "ān huī shěng lù ān shì" },
        ["an hv lq an"] = { text = "安徽六安", comment = "ān huī lù ān" },
        ["an hv lq an ui"] = { text = "安徽六安市", comment = "ān huī lù ān shì" },
        ["nj jy lq he"] = { text = "南京六合", comment = "nán jīng lù hé" },
        ["nj jy ui lq he"] = { text = "南京六合区", comment = "nán jīng lù hé qū" },
        ["nj jy ui lq he qu"] = { text = "南京市六合区", comment = "nán jīng shì lù hé qū" },
        ["wj bo ln"] = { text = "万柏林", comment = "wàn bǎi lín" },
        -- 错字
        ["pu jx"] = { text = "扑街", comment = "仆街" },
        ["pu gl"] = { text = "扑街", comment = "仆街" },
        ["pu jx zl"] = { text = "扑街仔", comment = "仆街仔" },
        ["pu gl zl"] = { text = "扑街仔", comment = "仆街仔" },
        ["cg jn"] = { text = "曾今", comment = "曾经" },
        ["an nl"] = { text = "按耐", comment = "按捺(nà)" },
        ["an nl bu vu"] = { text = "按耐不住", comment = "按捺(nà)不住" },
        ["bx jx"] = { text = "别介", comment = "别价(jie)" },
        ["bg jx"] = { text = "甭介", comment = "甭价(jie)" },
        ["xt ml pf vh"] = { text = "血脉喷张", comment = "血脉贲(bēn)张 | 血脉偾(fèn)张" },
        ["qi ke fu"] = { text = "契科夫", comment = "契诃(hē)夫" },
        ["vk ia"] = { text = "找茬", comment = "找碴" },
        ["vk ia er"] = { text = "找茬儿", comment = "找碴儿" },
        ["da jw ll vk va"] = { text = "大家来找茬", comment = "大家来找碴" },
        ["da jw ll vk ia er"] = { text = "大家来找茬儿", comment = "大家来找碴儿" },
        ["cb ho"] = { text = "凑活", comment = "凑合(he)" },
        ["ju hv"] = { text = "钜惠", comment = "巨惠" },
        ["mo xx zo"] = { text = "魔蝎座", comment = "摩羯(jié)座" },
        ["no da"] = { text = "诺大", comment = "偌(ruò)大" },
    }
end

function CR.run(cand, env, initial_comment)
    -- 使用正则表达式提取拼音部分并记录结果
    local pinyin_segments = {}
    for match in initial_comment:gmatch("([^%[%s]+)%[") do
        table.insert(pinyin_segments, match)
    end
    local pinyin = table.concat(pinyin_segments, " ")       
    if pinyin and #pinyin > 0 then
        if env.delimiter then
            pinyin = pinyin:gsub(env.delimiter, ' ')
        end
        local c = CR.corrections[pinyin]
        if c and cand.text == c.text then
            -- 使用 CR.style 模板构建最终的注释内容
            local final_comment = CR.style:gsub("{comment}", c.comment)
            return final_comment  -- 返回正确注释
        end
    end
    return nil  -- 没有修改注释，返回 nil
end
-- #########################
-- # 辅助码提示模块 (Fuzhu)
-- #########################

local FZ = {}

function FZ.run(cand, env, initial_comment)
    local length = utf8.len(cand.text)
    local final_comment = nil

    -- 确保候选词长度检查使用从配置中读取的值
    if env.settings.fuzhu_code_enabled and length <= env.settings.candidate_length then
        if env.settings.fuzhu_type == "zrm" then
            local fuzhu_comments = {}
            for match in initial_comment:gmatch("%[([^%[ ]+)") do
                table.insert(fuzhu_comments, match)
            end
            if #fuzhu_comments > 0 then
                final_comment = table.concat(fuzhu_comments, " ")  -- 拼接辅助码注释
            end
        end
    else
        -- 如果候选词长度超过指定值，返回空字符串
        final_comment = ""
    end
    return final_comment or ""  -- 确保返回最终值
end

-- #########################
-- 主函数：根据优先级处理候选词的注释
-- #########################
local C = {}
function C.init(env)
    local config = env.engine.schema.config

    -- 获取 pro_comment_format 配置项
    env.settings = {
        jiancode_priority = config:get_bool("pro_comment_format/jiancode_priority") or false,  -- 简码前置功能
        jiancode_identifier = config:get_string("pro_comment_format/jiancode_identifier") or "⚡",  -- 简码标识符
        corrector_enabled = config:get_bool("pro_comment_format/corrector") or false,  -- 错音错词提醒功能
        corrector_type = config:get_string("pro_comment_format/corrector_type") or "{comment}",  -- 提示类型
        fuzhu_code_enabled = config:get_bool("pro_comment_format/fuzhu_code") or false,  -- 辅助码提醒功能
        candidate_length = tonumber(config:get_string("pro_comment_format/candidate_length")) or 1,  -- 候选词长度
        fuzhu_type = config:get_string("pro_comment_format/fuzhu_code/fuzhu_type") or "zrm"  -- 辅助码类型
    }
function C.func(input, env)
    -- 调用全局初始共享环境
    C.init(env)
    CR.init(env)
    local processed_candidates = {}  -- 用于存储处理后的候选词

    -- 遍历输入的候选词
    for cand in input:iter() do
        local initial_comment = cand.comment  -- 保存候选词的初始注释
        local final_comment = initial_comment  -- 初始化最终注释为初始注释

        -- 处理辅助码提示
        if env.settings.fuzhu_code_enabled then
            local fz_comment = FZ.run(cand, env, initial_comment)
            if fz_comment then
                final_comment = fz_comment
            end
        else
            -- 如果辅助码显示被关闭，则清空注释
            final_comment = ""
        end

        -- 处理错词提醒
        if env.settings.corrector_enabled then
            local cr_comment = CR.run(cand, env, initial_comment)
            if cr_comment then
                final_comment = cr_comment
            end
        end

        -- 更新最终注释
        if final_comment ~= initial_comment then
            cand:get_genuine().comment = final_comment
        end

        table.insert(processed_candidates, cand)  -- 存储其他候选词
    end

    -- 输出处理后的候选词
    for _, cand in ipairs(processed_candidates) do
        yield(cand)
    end
end

return {
    CR = CR,
    FZ = FZ,
    C = C,
    func = C.func
}