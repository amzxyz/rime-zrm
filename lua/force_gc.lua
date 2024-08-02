-- 暴力 GC
-- 详情 https://github.com/hchunhui/librime-lua/issues/307
-- 这样也不会导致卡顿，那就每次都调用一下吧，内存稳稳的
function force_gc()
    -- collectgarbage()
    collectgarbage("step")
end

-- 临时用的
function debug_checker(input, env)
    for cand in input:iter() do
        yield(ShadowCandidate(
            cand,
            cand.type,
            cand.text,
            env.engine.context.input .. " - " .. env.engine.context:get_preedit().text .. " - " .. cand.preedit
        ))
    end
end