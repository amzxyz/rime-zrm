local charsfilter = {}

function charsfilter.init(env)
   -- 使用 ReverseLookup 方法加载字符集
   env.charset = ReverseLookup("charset")
   env.memo = {}
   -- 从配置中读取是否需要过滤英文
   env.filter_abc = env.engine.schema.config:get_bool("charset_filter_abc") or false
end

function charsfilter.fini(env)
   env.charset = nil
   env.memo = nil
   env.filter_abc = nil
   collectgarbage()
end

function charsfilter.func(t_input, env)
   local extended = env.engine.context:get_option("charset_filter")

   if extended or env.charset == nil or charsfilter.IsReverseLookup(env) then
      for cand in t_input:iter() do
         yield(cand)
      end
   else
      for cand in t_input:iter() do
         if charsfilter.InCharset(env, cand.text) then
            yield(cand)
         end
      end
   end
end

-- 检查字符是否在字符集内
function charsfilter.InCharset(env, text)
   -- 如果配置要求放行英文，且文本包含字母，则放行
   if env.filter_abc and charsfilter.ContainsAlpha(text) then
      return true
   end

   -- 否则继续逐字符检查
   for i, codepoint in utf8.codes(text) do
      if not charsfilter.CodepointInCharset(env, codepoint) then
         return false
      end
   end
   return true
end

function charsfilter.CodepointInCharset(env, codepoint)
   -- 如果已经缓存过该字符的处理结果，直接返回
   if env.memo[codepoint] ~= nil then
      return env.memo[codepoint]
   end

   -- 如果配置允许放行英文，且字符是字母（大写或小写），直接返回 true
   if env.filter_abc and (codepoint >= 0x41 and codepoint <= 0x5A or codepoint >= 0x61 and codepoint <= 0x7A) then
      env.memo[codepoint] = true
      return true
   end

   -- 查询字符是否在 charset 中
   local char = utf8.char(codepoint)
   local res = env.charset:lookup(char) ~= ""
   env.memo[codepoint] = res
   return res
end

-- 判断文本是否包含字母（包括大小写）
function charsfilter.ContainsAlpha(text)
   return string.match(text, "%a") ~= nil
end

function charsfilter.IsReverseLookup(env)
   local seg = env.engine.context.composition:back()
   if not seg then
      return false
   end
   return seg:has_tag("radical_lookup")
      or seg:has_tag("reverse_stroke")
      or seg:has_tag("add_user_dict")
end

return charsfilter
