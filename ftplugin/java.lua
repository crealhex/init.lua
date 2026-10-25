-- jdtls itself needs Java 21+: pick the newest SDKMAN JDK with major >= 21,
-- else fall back (unchecked) to JAVA_HOME, else PATH
local function find_jdtls_java()
  local best, best_major = nil, 20
  for _, dir in ipairs(vim.fn.glob('~/.sdkman/candidates/java/*', false, true)) do
    local major = tonumber(vim.fn.fnamemodify(dir, ':t'):match('^(%d+)'))
    local bin = dir .. '/bin/java'
    if major and major > best_major and vim.fn.executable(bin) == 1 then
      best, best_major = bin, major
    end
  end
  if best then
    return best
  end
  if vim.env.JAVA_HOME then
    return vim.env.JAVA_HOME .. '/bin/java'
  end
  return 'java'
end

local jdtls_java = find_jdtls_java()

local jdtls_path = require('mason-registry').get_package('jdtls'):get_install_path()
local jdtls_launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
local lombok_path = jdtls_path .. '/lombok.jar'
local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

local function get_config_dir()
  if vim.fn.has('linux') == 1 then
    return 'config_linux'
  elseif vim.fn.has('mac') == 1 then
    return 'config_mac'
  else
    return 'config_win'
  end
end

local root_dir = require('jdtls.setup').find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

-- Reuse the project's VS Code "java.*" settings (e.g. java.project.sourcePaths
-- for build-tool-less projects), nesting the dotted keys the way jdtls expects.
-- outputPath is skipped: VS Code's own jdtls already builds there, and jdtls
-- refuses to adopt a non-empty output folder.
local function vscode_java_settings(dir)
  local settings = {}
  local path = dir and (dir .. '/.vscode/settings.json')
  if not path or vim.fn.filereadable(path) == 0 then
    return settings
  end
  local ok, flat = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
  if not ok or type(flat) ~= 'table' then
    return settings
  end
  for key, value in pairs(flat) do
    if key:match('^java%.') and key ~= 'java.project.outputPath' then
      local node = settings
      local parts = vim.split(key, '.', { plain = true })
      for i = 1, #parts - 1 do
        node[parts[i]] = node[parts[i]] or {}
        node = node[parts[i]]
      end
      node[parts[#parts]] = value
    end
  end
  return settings
end

-- jdtls only offers static-import completions from this list, and setting it
-- replaces its JUnit-only default, so the JUnit entries are repeated here. A
-- project's own .vscode value still wins
local settings = vscode_java_settings(root_dir)
settings.java = settings.java or {}
settings.java.completion = settings.java.completion or {}
settings.java.completion.favoriteStaticMembers = settings.java.completion.favoriteStaticMembers or {
  'org.assertj.core.api.Assertions.*',
  'org.junit.jupiter.api.Assertions.*',
  'org.junit.jupiter.api.Assumptions.*',
  'org.mockito.Mockito.*',
  'org.mockito.ArgumentMatchers.*',
  'org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*',
  'org.springframework.test.web.servlet.result.MockMvcResultMatchers.*',
}

local config = {
  cmd = {
    jdtls_java,
    -- Keep .project/.classpath/.settings in the jdtls workspace, not the
    -- project root, so they never land in git or synced trees. jdtls only
    -- reads this as a system property at startup, not from LSP settings
    '-Djava.import.generatesMetadataFilesAtProjectRoot=false',
    '-javaagent:' .. lombok_path,
    '-jar', jdtls_launcher,
    '-configuration', vim.fs.normalize(jdtls_path .. '/' .. get_config_dir()),
    '-data', vim.fn.expand('~/.cache/jdtls-workspace/') .. workspace_dir
  },
  root_dir = root_dir,
  settings = settings,
}
require('jdtls').start_or_attach(config)

-- Toggle between a class and its mirrored test (src/main/.../Foo.java <->
-- src/test/.../FooTest.java), creating the test's package dirs if missing
local function mirror(path)
  if path:find('/src/main/') then
    return (path:gsub('/src/main/', '/src/test/', 1):gsub('%.java$', 'Test.java'))
  elseif path:find('/src/test/') then
    return (path:gsub('/src/test/', '/src/main/', 1):gsub('Test%.java$', '.java'))
  end
end

vim.keymap.set('n', '<leader>tm', function()
  local target = mirror(vim.fn.expand('%:p'))
  if not target then
    return vim.notify('not under src/main or src/test', vim.log.levels.WARN)
  end
  vim.fn.mkdir(vim.fn.fnamemodify(target, ':h'), 'p')
  vim.cmd.edit(vim.fn.fnameescape(target))
end, { buffer = true, desc = 'Java: toggle class <-> mirrored test' })
