-- html-extra.lua
-- Pandoc Lua filter for enhanced HTML output:
--   1. Apply syntax highlighting to lstlisting code blocks
--   2. Render code captions
--   3. Prepend header bar with dark/light theme toggle
--   4. Inject Monokai dark-mode style for pygments code colors

local header_added = false

function CodeBlock(block)
  local style = block.attributes['style']
  if style == 'cstyle' then
    block.classes:insert('c')
    block.attributes['style'] = nil
  end

  local caption = block.attributes['data-caption'] or block.attributes['caption']
  if caption then
    block.attributes['data-caption'] = nil
    block.attributes['caption'] = nil
    local caption_span = pandoc.Span(
      {pandoc.Strong(caption)},
      {class = 'code-caption'}
    )
    local caption_para = pandoc.Para({caption_span})
    return {block, caption_para}
  end

  return block
end

function Pandoc(doc)
  if header_added then return doc end
  header_added = true

  local block = pandoc.RawBlock("html", [[
<div class="site-header">
  <button class="theme-toggle" onclick="toggleTheme()" title="Alternar tema claro/escuro">&#9790;</button>
  <span>Clube de Matem&aacute;tica @ 42 S&atilde;o Paulo</span>
</div>
<style>
:root.dark-mode .sourceCode span.kw { color: #66d9ef; font-weight: bold; }
:root.dark-mode .sourceCode span.dt { color: #f92672; }
:root.dark-mode .sourceCode span.st { color: #e6db74; }
:root.dark-mode .sourceCode span.cf { color: #66d9ef; font-weight: bold; }
:root.dark-mode .sourceCode span.op { color: #f8f8f2; }
:root.dark-mode .sourceCode span.dv { color: #ae81ff; }
:root.dark-mode .sourceCode span.co { color: #75715e; font-style: italic; }
:root.dark-mode .sourceCode span.pp { color: #f92672; font-weight: bold; }
:root.dark-mode .sourceCode span.im { color: #a6e22e; font-weight: bold; }
:root.dark-mode .sourceCode span.ch { color: #e6db74; }
:root.dark-mode .sourceCode span.sc { color: #ae81ff; }
:root.dark-mode .sourceCode span.fu { color: #a6e22e; }
:root.dark-mode .sourceCode span.ot { color: #a6e22e; }
:root.dark-mode .sourceCode span.al { color: #f92672; font-weight: bold; }
:root.dark-mode .sourceCode span.bn { color: #ae81ff; }
:root.dark-mode .sourceCode span.cn { color: #f92672; }
:root.dark-mode .sourceCode span.do { color: #75715e; font-style: italic; }
:root.dark-mode .sourceCode span.er { color: #f92672; font-weight: bold; }
:root.dark-mode .sourceCode span.fl { color: #ae81ff; }
:root.dark-mode .sourceCode span.in { color: #75715e; font-weight: bold; font-style: italic; }
:root.dark-mode .sourceCode span.ss { color: #e6db74; }
:root.dark-mode .sourceCode span.va { color: #f8f8f2; }
:root.dark-mode .sourceCode span.vs { color: #e6db74; }
:root.dark-mode .sourceCode span.wa { color: #75715e; font-weight: bold; font-style: italic; }
:root.dark-mode .sourceCode span.at { color: #a6e22e; }
:root.dark-mode .sourceCode span.an { color: #75715e; font-weight: bold; font-style: italic; }
:root.dark-mode .sourceCode span.cv { color: #75715e; font-weight: bold; font-style: italic; }
:root.dark-mode .sourceCode span.ex { color: #f8f8f2; }
:root.dark-mode .sourceCode span.kc { color: #66d9ef; font-weight: bold; }
:root.dark-mode .sourceCode span.kp { color: #66d9ef; }
:root.dark-mode .sourceCode span.kr { color: #66d9ef; font-weight: bold; }
:root.dark-mode .sourceCode span.kt { color: #66d9ef; }
:root.dark-mode .sourceCode span.mi { color: #ae81ff; }
:root.dark-mode .sourceCode span.mf { color: #ae81ff; }
:root.dark-mode .sourceCode span.mh { color: #ae81ff; }
:root.dark-mode .sourceCode span.mo { color: #ae81ff; }
:root.dark-mode .sourceCode span.na { color: #a6e22e; }
:root.dark-mode .sourceCode span.nb { color: #f8f8f2; }
:root.dark-mode .sourceCode span.nc { color: #a6e22e; }
:root.dark-mode .sourceCode span.nd { color: #a6e22e; }
:root.dark-mode .sourceCode span.ne { color: #f92672; }
:root.dark-mode .sourceCode span.nf { color: #a6e22e; }
:root.dark-mode .sourceCode span.nl { color: #f8f8f2; }
:root.dark-mode .sourceCode span.nn { color: #f8f8f2; }
:root.dark-mode .sourceCode span.no { color: #66d9ef; }
:root.dark-mode .sourceCode span.nt { color: #a6e22e; }
:root.dark-mode .sourceCode span.nv { color: #f8f8f2; }
:root.dark-mode .sourceCode span.nx { color: #a6e22e; }
:root.dark-mode .sourceCode span.py { color: #f8f8f2; }
:root.dark-mode .sourceCode span.sa { color: #e6db74; }
:root.dark-mode .sourceCode span.si { color: #e6db74; }
:root.dark-mode .sourceCode span.sx { color: #e6db74; }
:root.dark-mode .sourceCode span.vc { color: #f8f8f2; }
:root.dark-mode .sourceCode span.vl { color: #f8f8f2; }
</style>
<script>
(function() {
  if (localStorage.getItem('theme') === 'dark') {
    document.documentElement.classList.add('dark-mode');
  }
})();
function toggleTheme() {
  var html = document.documentElement;
  var isDark = html.classList.toggle('dark-mode');
  localStorage.setItem('theme', isDark ? 'dark' : 'light');
}
</script>
]])

  doc.blocks:insert(1, block)
  return doc
end

function Div(div)
  if div.classes:includes('minipage') then
    div.classes:insert('minipage-wrapper')
  end
  return div
end
