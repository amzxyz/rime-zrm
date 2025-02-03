-- 在英文单词后添加空格的函数
local function add_space_to_english_word(input)
    -- 匹配纯英文单词（don't 算纯英文单词）并在单词后添加空格
    input = input:gsub("(%a+'?%a*)", "%1 ")
    return input
end

-- 在候选项上屏时触发的函数
local function en_spacer(input, env)
    for cand in input:iter() do
        if cand.text:match("^[%a']+[%a']*$") then
            -- 如果候选项是纯英文单词，则在输入后添加一个空格，并去掉注释
            cand = cand:to_shadow_candidate(cand.type, add_space_to_english_word(cand.text), "")
        end
        yield(cand)
    end
end

return en_spacer
