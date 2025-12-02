local java21 = vim.fn.expand('~/.sdkman/candidates/java/21.0.6-tem/bin/java')

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

local config = {
  cmd = {
    java21,
    '-javaagent:' .. lombok_path,
    '-jar', jdtls_launcher,
    '-configuration', vim.fs.normalize(jdtls_path .. '/' .. get_config_dir()),
    '-data', vim.fn.expand('~/.cache/jdtls-workspace/') .. workspace_dir
  },
  root_dir = require('jdtls.setup').find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
}
require('jdtls').start_or_attach(config)
